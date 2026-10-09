#!/bin/bash

# Stop the ClamAV daemon
systemctl stop clamav-freshclam

# Update the virus definitions once (-d would start a second freshclam daemon
# instead of updating and returning)
freshclam

# Start the ClamAV daemon after updating definitions
systemctl start clamav-freshclam

# Scan everything except the kernel/virtual filesystems (clamscan never prompts)
clamscan -r / --exclude-dir='^/(proc|sys|dev|run)' --log=/var/log/clamav/clamscan.log

# Do NOT run "rkhunter --propupd" here: it would accept any changed (possibly
# trojaned) binary as the new baseline right before the check. Run --propupd by hand
# only after an apt upgrade you trust (see 1_clamav_rkhunter_install).

# rkhunter check without requiring Enter key press
rkhunter --check --skip-keypress


##################################################

# once you save the above script then make it executable with this command
#chmod +x clam-rk-update-scan.sh

#put the clam-rk-update-scan.sh in the usres .bashrc
#/clam-rk-update-scan.sh
