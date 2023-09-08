#!/bin/bash

# Initialize a new Git repository
git init

# Set the user name and email
git config user.name "name"
git config user.email "email"

# Add a remote origin
git remote add docker-swarm https://github.com/curtalfrey/docker-swarm.git

# Set the remote as the upstream for the current branch
git push --set-upstream docker-swarm master
