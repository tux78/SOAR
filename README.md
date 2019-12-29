# Security Orchestration, Automation and Response 
This repository provides a docker-based installation of MISP and intelMQ. Using this, a fully operational installation can be set up within just a few steps

## Create working directory
As a first step it is recommended to create a working directory
```
# mkdir SOAR
# cd SOAR
```

## Clone repository
Cloning the repository is done by running the following command
```
# git clone https://github.com/tux78/SOAR.git
```

## Execute setup routine
The actual setup is initiated by executing the setup routine
```
# ./setup
```

The following setup will ask some questions:
- Install MISP
- Install intelMQ
- Integrate intelMQ with ePO (requires ePO IP, username and password)

Please note that especially the MISP setup requires some time. Depending on resources this can take up to 1/2 hour!

Integrating intelMQ with ePO actually generates a CSR, which is automatically forwarded to and signed by the McAfee ePO server. Once finished, all necessary files to operate openDXL are located in the following location within the docker container:
```
# ls -l /etc/intelmq/openDXL
```
This folder especially holds the client.config file, which has to be addressed when configuring the openDXL bot.

If McAfee ePO integration has been missed during setup, it can be executed at a later stage as well using below command:
```
# docker-compose exec intelmq\
        /usr/local/bin/dxlclient\
        provisionconfig /etc/intelmq/openDXL EPO_IP HOST_IP -t EPO_PORT -u EPO_ADMIN -p EPO_PW
```
Please replace the following variables with the respective values:
- EPO_IP: ip address of McAfee ePO server
- HOST_IP: IP address of docker host
- EPO_PORT: webUI port McAfee ePO server is listening on (Default: 8443)
- EPO_ADMIN/EPO_PW: credentials of admin user entitled to sign certificates

## intelMQ Development
Development of additinal intelMQ Bots takes place in the following directory on the docker host itself:
```
# cd ./dev_intelmq/intelmq/bots
```
Bots are located in the corresponding directories:
- collectors
- parsers
- experts
- outputs

Keep in mind that additional (new) bots have to be added to the following file as well:
```
# vi ./dev_intelmq/intelmq/bots/BOTS
```
In order to apply any changes to the running environment, the following command can be executed:
```
# ./docker-compose exec intelmq /update_dev.sh
```
For additional information, please visit the intelMQ development guide:

https://intelmq.readthedocs.io/en/latest/Developers-Guide/
