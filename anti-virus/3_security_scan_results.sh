#!/bin/bash

# Path to the ClamAV scan log file
clamav_log="/var/log/clamav/clamscan.log"

# Path to the rkhunter scan log file
rkhunter_log="/var/log/rkhunter.log"

# Get the number of infected files from ClamAV log
clamav_infected=$(grep -o 'Infected files: [0-9]*' "$clamav_log" | awk '{print $3}')

# Get the number of rkhunter warnings from rkhunter log
rkhunter_warnings=$(grep -c 'Warning:' "$rkhunter_log")

# Display the results
echo "ClamAV Infected files: $clamav_infected"
echo "rkhunter Warnings: $rkhunter_warnings"

###############################################################

#make it executable with the following command
#chmod +x security_scan_results.sh


# Add the following line to your user's .bashrc file (located in your user's home directory):
#sudo /security_scan_results.sh

