#!/bin/bash

#install portainer
echo "portainer install"
sudo curl -L https://downloads.portainer.io/ee2-16/portainer-agent-stack.yml -o portainer-agent-stack.yml
sleep 10

#wait on download
echo "waiting on download to complete"
sudo curl -L https://downloads.portainer.io/ee2-16/portainer-agent-stack.yml -o portainer-agent-stack.yml
sleep 10

#deploy stack
echo "deploy stack"
docker stack deploy -c portainer-agent-stack.yml portainer
sleep 10

#upgrading portainer server
docker stack deploy -c portainer-agent-stack.yml portainer
sleep 10
echo "upgrading"
docker pull portainer/portainer-ee:latest
sleep 10
docker service update --image portainer/portainer-ee:latest --publish-add 9443:9443 --force portainer_portainer
sleep 10
#upgrading agent
echo "upgrading agent"
docker pull portainer/agent:latest
sleep 10
docker service update --image portainer/agent:latest --force portainer_agent
echo "done with all"
