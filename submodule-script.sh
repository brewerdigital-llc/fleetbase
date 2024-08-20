#!/bin/bash

# Check if the .gitmodules file exists in the current directory
if [ ! -f .gitmodules ]; then
    echo ".gitmodules file not found in the current directory."
    exit 1
fi


# Extract and add each submodule
while read -r line; do
    # If the line contains 'submodule'
    if [[ "$line" =~ \[submodule\ \"(.*)\"\] ]]; then
        submodule_name="${BASH_REMATCH[1]}"
    fi

    # Look for lines that start with 'url ='
    if [[ "$line" =~ url\ =\ (.*) ]]; then
        url="${BASH_REMATCH[1]}"
        # Construct the path for the submodule in the target directory
        submodule_path="$submodule_name"
        echo "Adding submodule: $url at $submodule_path"
        git submodule add "$url" "$submodule_path"
    fi
done < .gitmodules

echo "All submodules have been added to the $TARGET_DIR directory."
