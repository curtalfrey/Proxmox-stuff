#!/bin/bash

# set the username
username=clusterednetworks

# get a list of all repositories for the user
curl "https://api.github.com/users/$username/repos?per_page=1000" |
  grep -o '"clone_url":\s*"[^"]*' |
  awk '{print $2}' |
  tr -d '"' |
  xargs -L1 git clone
