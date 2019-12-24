#!/bin/bash

# create folders
mkdir misp-db
mkdir dev_intelmq

# clone intelmq dev
git clone https://github.com/tux78/intelmq.git ./dev_intelmq

# build intelMQ image
docker build \
    --rm=true --force-rm=true \
    -t intelmq:PROD \
    -f ./Dockerfile.intelmq .

docker build \
    --rm=true --force-rm=true \
    -t misp:PROD \
    -f ./Dockerfile.misp .

#    --build-arg MYSQL_MISP_PASSWORD=ChangeThisDefaultPassworda9564ebc3289b7a14551baf8ad5ec60a \
#    --build-arg POSTFIX_RELAY_HOST=localhost \
#    --build-arg MISP_FQDN=localhost \
#    --build-arg MISP_EMAIL=admin@localhost \
#    --build-arg MISP_GPG_PASSWORD=ChangeThisDefaultPasswordXuJBao5Q2bps89LWFqWkKgDZwAFpNHvc \

# create containers
docker-compose up --no-start --force-recreate intelmq
docker-compose up --no-start --force-recreate misp

# start containers
docker-compose start intelmq
docker-compose start misp

# Init MISP DB
docker-compose exec misp /init-db
