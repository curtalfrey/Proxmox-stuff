#!/bin/bash

# Stop the ClamAV daemon
systemctl stop clamav-freshclam

# Update the virus definitions
freshclam -d

# Start the ClamAV daemon after updating definitions
systemctl start clamav-freshclam

# Start the ClamAV scan without requiring Enter key press
yes | clamscan -r / --log=/var/log/clamav/clamscan.log

# Update rkhunter's properties
rkhunter --propupd

# Start rkhunter check without requiring Enter key press
yes | rkhunter --check


##################################################

# once you save the above script then make it executable with this command
#chmod +x clam-rk-update-scan.sh

#put the clam-rk-update-scan.sh in the usres .bashrc
#/clam-rk-update-scan.sh
