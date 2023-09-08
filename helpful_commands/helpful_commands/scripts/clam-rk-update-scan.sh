#!/bin/bash

# Stop the ClamAV daemon
systemctl stop clamav-freshclam;

# Update the virus definitions
freshclam;

# Start the scan
clamscan -r /path/to/scan;

# Start the ClamAV daemon
systemctl start clamav-freshclam;

#scan
clamscan -i -r --remove /;

#update rkhunter
rkhunter --propupd;

#check
rkhunter --check;

