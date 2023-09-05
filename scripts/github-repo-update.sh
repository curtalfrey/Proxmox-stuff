#!/bin/bash

# Enter the github repo's info here, you can add more if you need
repos=(
    "https://github.com/USERNAME/REPO1.git"
    "https://github.com/USERNAME/REPO2.git"
    "https://github.com/USERNAME/REPO3.git"
)
github_dir="/home/ansible/github"                # path where you want the repo to be on your PC
git_username="YOUR_GIT_USERNAME"                 # user name
git_email="YOUR_GIT_EMAIL"                       # your email you use for your repos


# do not change data below this line
#########################################################


# Ensure directory exists
mkdir -p "$github_dir"

# Loop through repositories
for repo_url in "${repos[@]}"; do
    repo_name=$(basename "$repo_url" .git)
    repo_path="$github_dir/$repo_name"

    # Check if repo directory exists
    if [ -d "$repo_path" ]; then
        echo "Updating repository: $repo_name"
        cd "$repo_path"
        git pull origin main
    else
        echo "Cloning repository: $repo_name"
        git clone "$repo_url" "$repo_path"
    fi

    # Configure safe.directory for the repository
    git config --local --add safe.directory "$repo_path"
done

# Set Git user identity (global)
git config --global user.name "$git_username"
git config --global user.email "$git_email"

# Configure Git to trust the directory
git config --global credential.helper store

echo "Script execution completed."
