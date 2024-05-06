#!/bin/bash
############################################################################################################################################
#
# Author : Abhishek Veeramalla
# Repo : https://github.com/iam-veeramalla/shell-scripting-projects/blob/052ad7cb505bdcad7783e8002b471cf1f843321c/github-api/list-users.sh
#
# Modified : Anshul Awasthi
# Modified Date : 27 April 2024
# Modifications : 
# 1. Modified the "collaborators=" to take login name and role_name as an output from jq parser. 
# 2. Morover added a working helper # function and placed it in the required line for script execution.
#
############################################################################################################################################

# Helper function
function helper {
    local expected_cmd_args=2
    # Check the script arguments
    if [ $# -ne "$expected_cmd_args" ]; then
       echo "please execute the script with two arugments for Repo owner and Repo name"
       exit 1
    else
        echo "Provided valid input, continuing the script"
    fi
}

helper "$@"

# GitHub API URL
API_URL="https://api.github.com"

# GitHub username and personal access token
USERNAME=$username
TOKEN=$token

# User and Repository information
REPO_OWNER=$1
REPO_NAME=$2


# Function to make a GET request to the GitHub API
function github_api_get {
	local endpoint="$1"
	local url="${API_URL}/${endpoint}"
        # Send a GET request to the GitHub API with authentication
	curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    # Fetch the list of collaborators on the repository
    #collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')" #by Abhishek Veeramallah
    
    collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.admin == true) | "User::\(.login)  Role::\(.role_name)"')" #Modified by Anshul

    # Display the list of collaborators with read access
    if [[ -z "$collaborators" ]]; then
	echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
	echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
	echo "$collaborators"
    fi
}


# Main script

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."

list_users_with_read_access

