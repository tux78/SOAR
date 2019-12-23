#!/bin/bash

# create folders
mkdir misp-db
mkdir dev_intelmq

# clone intelmq dev
https://github.com/tux78/intelmq.git ./dev_intelmq

# build image
docker build -t intelmq:PROD -f ./Dockerfile .

# re-create intelmq container
docker-compose up --no-start --force-recreate intelmq

# restart intelmq instance
docker-compose start intelmq
docker-compose start misp
