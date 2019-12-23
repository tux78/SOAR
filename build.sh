#!/bin/bash

# build image
docker build -t intelmq:PROD -f ./Dockerfile .

# re-create intelmq container
docker-compose up --no-start --force-recreate intelmq

# restart intelmq instance
docker-compose restart intelmq
