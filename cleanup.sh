#!/bin/bash

docker stack rm LEGA
sleep 10
# shellcheck disable=SC2046
docker rm -f $(docker ps -aq)
# shellcheck disable=SC2046
docker volume rm $(docker volume list -q)
# shellcheck disable=SC2046
docker config rm $(docker config list -q)

# shellcheck disable=SC2035
# shellcheck disable=SC2216
rm elasticsearch.yml kibana.yml logstash.yml logstash.conf conf.ini rootCA.pem rootCA-key.pem localhost+*.pem *.p12 localhost+*.der docker-stack.yml ega*.pem ega*.pass
