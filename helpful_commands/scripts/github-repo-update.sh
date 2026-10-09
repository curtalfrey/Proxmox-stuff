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
    if [ -d "$repo_path/.git" ]; then
        echo "Updating repository: $repo_name"
        # Pull the branch that is checked out (not always main); never merge.
        git -C "$repo_path" pull --ff-only || echo "WARN: $repo_name not updated" >&2
    else
        echo "Cloning repository: $repo_name"
        git clone "$repo_url" "$repo_path"
    fi

    # safe.directory is only read from global/system config, never from the repo's own
    # .git/config, so --local did nothing. Add it once, globally.
    if ! git config --global --get-all safe.directory | grep -qxF "$repo_path"; then
        git config --global --add safe.directory "$repo_path"
    fi
done

# Set Git user identity (global)
git config --global user.name "$git_username"
git config --global user.email "$git_email"

# Optional: remember HTTPS credentials. "store" keeps them in plain text in
# ~/.git-credentials; prefer SSH urls or a credential manager.
# git config --global credential.helper store

echo "Script execution completed."
