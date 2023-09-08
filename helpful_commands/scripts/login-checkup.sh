#!/bin/bash

# Display Docker containers, networks, and services
echo "Docker containers:"
echo ""
echo ""
docker ps -a
echo ""
echo ""
echo "Docker networks:"
echo ""
echo ""
docker network ls
echo ""
echo ""
echo "Docker services:"
echo ""
echo ""
docker service ls
echo ""
echo ""
echo "docker nodes:"
echo ""
echo ""
docker node ls
echo ""
echo ""
# Display last 5 successful IP logins
echo "Last 5 successful IP logins:"
echo ""
echo ""
last -5 -i
echo ""
echo ""
# Display any threats found by ClamAV and Rootkit Hunter
echo "Threats found by ClamAV:"
echo ""
echo ""
grep "Infected files" /var/log/clamav/clamav.log | tail -5
echo ""
echo ""
echo "Threats found by Rootkit Hunter:"
echo ""
echo ""
grep "ALERT" /var/log/rkhunter.log | tail -5
echo ""
echo ""
# Display other helpful system information
echo ""
echo ""
echo "System uptime:"
echo ""
echo ""
uptime
echo ""
echo ""
echo "Memory usage:"
echo ""
echo ""
free -h
echo ""
echo ""
echo "Disk usage:"
echo ""
echo ""
df -h
echo ""
echo ""
