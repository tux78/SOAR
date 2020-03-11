#!/bin/bash

clear_output()
{
  tput cup 7 0 && tput ed
}

execute_command()
{
  printf "$1"
  columns=$(expr `tput cols` - ${#1})

  printf '%s %s\n' "$(date)" "Running command \'$2\'" >>install.log 
  echo "Start command output" >>install.log
  eval $2 &>>install.log

  if [ $? -ne 0 ]
  then
    printf "%${columns}s\n" "[FAILED]"
    return 1
  fi
  printf "%${columns}s\n" "[Done]"
  return 0
}

#########################
# Start installation
#########################

# Clear Screen
clear
echo "#####################"
echo
echo "Welcome to SOAR setup"
echo
echo "#####################"
echo

# Check prerequisites
docker &> /dev/null && docker-compose ps &> /dev/null

if [ $? -ne 0 ]
then
  echo "Please install prerequisites"
  echo "docker and docker-compose are required components"
  exit 1
fi

# Set some variables
# Docker Host IP address
HOST_IP=$(ping -q -c 1 -t 1 `hostname` | grep PING | sed -e "s/).*//" | sed -e "s/.*(//")

# intelMQ
read -p "Install intelMQ (y|N): " INTELMQ_INSTALL || INTELMQ_INSTALL = "n"

# Integrate intelMQ with ePO
if [ "${INTELMQ_INSTALL,,}" == "y" ]
then
  read -p "Configure McAfee ePO (y|N): " EPO_CONFIG || EPO_CONFIG="n"
  if [ "${EPO_CONFIG,,}" == "y" ]
  then
    read -p "ePO IP address: " EPO_IP
    read -e -p "ePO Port [8443]: " -i "8443" EPO_PORT
    read -p "ePO Admin User: " EPO_ADMIN
    read -sp "ePO Admin password: " EPO_PW
    echo
  fi
fi

# MISP
read -p "Install MISP (y|N): " MISP_INSTALL || MISP_INSTALL = "n"

#########################
# intelMQ Installation
#########################

if [ "${INTELMQ_INSTALL,,}" == "y" ]
then
  # create folders
  execute_command "Create intelMQ dev directory" "mkdir dev_intelmq"

  # clone intelmq dev
  execute_command "Clone intelMQ DEV" "git clone https://github.com/tux78/intelmq.git ./dev_intelmq"

  # Build intelMQ image
  execute_command "Build intelMQ image" "\
    docker build \
      -t intelmq:PROD \
      -f ./intelmq/Dockerfile.intelmq .\
  "

  # create intelMQ container
  execute_command "Create intelMQ Container" "\
    docker-compose up --no-start --force-recreate intelmq\
  "

  # start intelMQ container
  execute_command "Start intelMQ" "\
    docker-compose start intelmq\
  "

  # Integrate intelMQ with ePO
  if [ "${EPO_CONFIG,,}" == "y" ]
  then
    execute_command "Integrate intelMQ with ePO: provision DXL certificate" "\
      docker-compose exec intelmq\
        /usr/local/bin/dxlclient\
        provisionconfig /etc/intelmq/openDXL $EPO_IP $HOST_IP -t $EPO_PORT -u $EPO_ADMIN -p $EPO_PW\
    "
    execute_command "Integrate intelMQ with ePO: change file permissions" "\
      docker-compose exec intelmq\
        chown intelmq:intelmq /etc/intelmq/openDXL/*\
    "
  fi

  # Incorporate DEV environment
  execute_command "Incorporate intelMQ DEV environment" "\
    docker-compose exec intelmq /update_dev.sh \
  "

fi

#########################
# MISP Installation
#########################

if [ "${MISP_INSTALL,,}" == "y" ]
then

  # create folders
  execute_command "Create MISP directories" "mkdir misp/misp-db"

  # Build MISP image
  execute_command "Build MISP image (may take a long time)" "\
    docker build \
      --build-arg MISP_FQDN=$HOST_IP \
      -t misp:PROD \
    -f ./misp/Dockerfile.misp .\
  "

  # create MISP container
  execute_command "Create MISP Container" "\
    docker-compose up --no-start --force-recreate misp\
  "

  # start MISP container
  execute_command "Start MISP" "\
    docker-compose start misp\
  "

  # Init MISP DB
  execute_command "Init MISP DB" "\
    docker-compose exec misp /init-db\
  "
fi

echo "Installation finished!"
