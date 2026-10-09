#!/bin/bash

set -euo pipefail

# Step 1: Set the directories
remote_user="root" # Set the remote user name
remote_host="curtisalfrey.com" # Set the remote host name
remote_dir="/" # Set the remote backup directory
local_dir="/opt/cloud_backups/" # Set the local backup directory
key_path="/home/n4s1/.ssh/id_rsa" # Set the path of the SSH key file

# Step 2: Connect to the remote server via SSH key and stop non-system services.
# The trap starts docker again even when rsync fails (set -e would otherwise exit
# here and leave every container on the remote host stopped).
restart_docker() {
  ssh -i "$key_path" "$remote_user@$remote_host" systemctl restart docker
}
ssh -i "$key_path" "$remote_user@$remote_host" systemctl stop docker
trap restart_docker EXIT

# Step 3: Rsync the remote filesystem into local_dir
rsync -avz -e "ssh -i $key_path" "$remote_user@$remote_host:$remote_dir" "$local_dir" --exclude="/sys/*" --exclude="/proc/*" --exclude="/dev/*" --exclude="/snap/*" --exclude="/tmp/*" --exclude="/log/*" --exclude="/lib/*" --exclude="/srv/*" --exclude="/bin/*" --exclude="/mnt/*" --exclude="/boot/*" --exclude="/media/*" --exclude="/run/*" --exclude="/sbin/*"

# Step 4: docker on the remote server is restarted by the EXIT trap above
