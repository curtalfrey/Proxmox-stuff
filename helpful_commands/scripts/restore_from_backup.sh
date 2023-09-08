#!/bin/bash

# Set the backup file name and directories
backup_file="backup_$(date +%F_%T).tar.gz.enc" # Set the backup file name with the date and time
local_dir="/opt/backups/" # Set the local backup directory
restore_dir="/my_restored_data/" # Set the directory to restore the data

# Decrypt and extract the backup file
gpg --decrypt --output "$backup_file.tar.gz" "$local_dir/$backup_file" # Decrypt the encrypted archive using GPG
tar -xzvf "$backup_file.tar.gz" -C "$restore_dir" # Extract the tar archive to the restore directory

# Remove the extracted files
rm "$backup_file.tar.gz" # Remove the extracted tar archive

# Verify the restored data
if [ -d "$restore_dir" ]; then
  echo "Data restore successful." # Print success message
  echo "Data successfully restored to $restore_dir" >> restore.log # Log the successful restore
else
  echo "Data restore failed." # Print failure message
  echo "Data restore failed" >> restore.log # Log the failed restore
fi
