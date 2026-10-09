#!/bin/bash
# Restore a GPG-encrypted tar.gz backup.
# Usage: restore_from_backup.sh /opt/backups/backup_2026-01-27_02:00:00.tar.gz.enc [/my_restored_data/]
# (The old version built the file name from the current date, so it never found a backup.)
set -euo pipefail

backup_path="${1:?usage: $0 <backup.tar.gz.enc> [restore_dir]}"
restore_dir="${2:-/my_restored_data/}" # Directory to restore the data into
log_file="${RESTORE_LOG:-restore.log}"

if [ ! -f "$backup_path" ]; then
  echo "Backup file not found: $backup_path" >&2
  exit 1
fi

mkdir -p "$restore_dir"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
archive="$work_dir/backup.tar.gz"

# Decrypt, then extract. set -e stops at the first failure, so success below is real.
if gpg --decrypt --output "$archive" "$backup_path" && tar -xzvf "$archive" -C "$restore_dir"; then
  echo "Data restore successful."
  echo "$(date +%F_%T) restored $backup_path to $restore_dir" >> "$log_file"
else
  echo "Data restore failed." >&2
  echo "$(date +%F_%T) restore of $backup_path failed" >> "$log_file"
  exit 1
fi
