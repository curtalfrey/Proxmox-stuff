#!/bin/bash

set -euo pipefail

# Step 1: Set the backup file name and directories
backup_date=$(date +%F_%T) # Get the current date and time in YYYY-MM-DD_HH:MM:SS format
remote_user="root" # Set the remote user name
remote_host="curtisalfrey.com" # Set the remote host name
remote_dir="/" # Set the remote backup directory
local_dir="/opt/cloud_backups/" # Set the local backup directory
key_path="/home/n4s1/.ssh/id_rsa" # Set the path of the SSH key file

# Step 2: Connect to the remote server via SSH key and stop non-system services
ssh -i "$key_path" "$remote_user@$remote_host" << EOF
systemctl stop docker
exit
EOF

# Step 3: Rsync, Tar, GPG, and Checksum the backup file
rsync -avz -e "ssh -i $key_path" "$remote_user@$remote_host:$remote_dir" "$local_dir" --exclude="/sys/*" --exclude="/proc/*" --exclude="/dev/*" --exclude="/snap/*" --exclude="/tmp/*" --exclude="/log/*" --exclude="/dev/*" --exclude="/dev/*" --exclude="/lib/*" --exclude="/srv/*" --exclude="/bin/*" --exclude="/mnt/*" --exclude="/boot/*" --exclude="/media/*" --exclude="/run/*" --exclude="/sbin/*"

# Step 5: Restart non-system services on the remote server
ssh -i "$key_path" "$remote_user@$remote_host" << EOF
systemctl restart docker
exit
EOF
