#!/bin/bash

# process flags for commit message and remote repo url
c_flag=''
o_flag=''

OPTSTRING=":co"

while getopts ${OPTSTRING} opt; do
  case ${opt} in
    c)
      c="${OPTARG}"
      ;;
    o)
      o="${OPTARG}"
      ;;
    :)
      echo "Option -${OPTARG} requires an argument."
      exit 1
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;;
  esac
done

# Check if current directory or any parent directories are Git repositories
while [[ ! -d .git && $PWD != '/' ]]; do
    cd ..
done

if [[ $PWD == '/' ]]; then
    echo "No Git repository found."
    exit 1
fi

# Check if there are any changes to commit
if [[ -n $(git status -s) ]]; then
    
    # Add remote repository if not already added
    if [[ -z $(git remote) ]]; then
        if [[ -z o_flag ]]; then
            echo "No remote repository specified."
            exit 1
        else
            git remote add origin "$o"
        fi
    fi

    # Check if the repository is empty
    if [[ -z $(git log -1 2>/dev/null) ]]; then
        # Initialize the repository with a commit
        git commit --allow-empty -m "Initial commit"
    fi

    # Get the current branch name
    branch=$(git rev-parse --abbrev-ref HEAD)

    # Create upstream branch if doesn't exist
    git push -u origin $branch

    # Git pull to get the latest changes
    git pull origin $branch

    # Add all changes
    git add .

    # Default commit message
    commit_message="WIP"

    if [[ -n $c_flag ]]; then
        commit_message="$c"
    fi

    # Commit with a default message or you can customize it
    git commit -m "$commit_message"  

    # Push to the remote repository
    git push origin $branch
else    
    echo "No changes to commit."
fi
