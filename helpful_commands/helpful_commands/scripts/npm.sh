#!/bin/bash

echo "docker network create -d overlay --attachable proxy"
docker network create -d overlay --attachable proxy
sleep 5

echo "docker config create npm_hsts"
docker config create npm_hsts ./npm_hsts.txt
sleep 5

echo "docker stack deploy --compose-file proxy-npm.yml proxy"
docker stack deploy --compose-file proxy-npm.yml proxy

docker stack ls

docker service ls
