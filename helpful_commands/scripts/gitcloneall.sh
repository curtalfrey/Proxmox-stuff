#!/bin/bash
# Clone every public repository of a GitHub user: gitcloneall.sh [username]
# GitHub returns at most 100 repos per page (per_page=1000 is capped at 100), so page
# through until a page comes back empty.
set -euo pipefail

username="${1:-clusterednetworks}"

page=1
while :; do
  urls=$(curl -fsSL "https://api.github.com/users/$username/repos?per_page=100&page=$page" |
    grep -o '"clone_url":[[:space:]]*"[^"]*' |
    awk '{print $2}' |
    tr -d '"' || true)
  [ -z "$urls" ] && break
  while read -r url; do
    dir=$(basename "$url" .git)
    if [ -d "$dir" ]; then
      echo "skip $dir (already here)"
    else
      git clone "$url"
    fi
  done <<< "$urls"
  page=$((page + 1))
done
