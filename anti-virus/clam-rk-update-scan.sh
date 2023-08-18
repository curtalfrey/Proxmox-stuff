#!/bin/bash

# Stop the ClamAV daemon
systemctl stop clamav-freshclam;

# Update the virus definitions
freshclam -d;

# Start the ClamAV daemon
systemctl start clamav-freshclam;

# Start the scan
clamscan -r /;

#update rkhunter
rkhunter --propupd;

#check
rkhunter --check;

##################################################

# once you save the above script then make it executable with this command
#chmod +x clam-rk-update-scan.sh
