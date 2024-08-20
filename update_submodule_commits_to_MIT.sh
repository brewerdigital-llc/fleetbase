#!/bin/bash

# Check if the .gitmodules file exists in the current directory
if [ ! -f .gitmodules ]; then
    echo ".gitmodules file not found in the current directory."
    exit 1
fi

# Date to check out closest commits before or at this time, this is the last commit where fleetbase is MIT
TARGET_DATE="2024-02-24T16:02:05+0700"

# Extract and update each submodule
while read -r line; do
    # If the line contains 'submodule'
    if [[ "$line" =~ \[submodule\ \"(.*)\"\] ]]; then
        submodule_name="${BASH_REMATCH[1]}"
    fi

    # Look for lines that start with 'url ='
    if [[ "$line" =~ url\ =\ (.*) ]]; then
        # Construct the path for the submodule in the target directory
        submodule_path="$submodule_name"
        
        if [ -d "$submodule_path" ]; then
            echo "Updating submodule in $submodule_path"

            # Change to the submodule directory
            cd "$submodule_path" || exit

            # Find the closest commit before or at the target date
            commit_hash=$(git rev-list -1 --before="$TARGET_DATE" HEAD)

            if [ -n "$commit_hash" ]; then
                echo "Checking out commit $commit_hash in $submodule_name"
                git checkout "main" && git checkout "$commit_hash" && git checkout -b mit-branch && git push -f
            else
                echo "No commits found before $TARGET_DATE in $submodule_name"
            fi

            # Return to the main directory
            cd - || exit
        else
            echo "Directory $submodule_path does not exist. Skipping."
        fi
    fi
done < .gitmodules

echo "All submodules have been checked out to the closest commits before $TARGET_DATE."

