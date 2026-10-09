#!/bin/bash

# Stop the ClamAV daemon
systemctl stop clamav-freshclam;

# Update the virus definitions
freshclam;

# Start the ClamAV daemon
systemctl start clamav-freshclam;

# Scan (skip the kernel/virtual filesystems). --remove DELETES infected files;
# use --move=/var/quarantine instead if you want to review them first.
clamscan -i -r --remove --exclude-dir='^/(proc|sys|dev|run)' /;

# No "rkhunter --propupd" here: it would bless changed binaries before the check.
# Run it by hand only after an upgrade you trust.

#check
rkhunter --check --skip-keypress;

