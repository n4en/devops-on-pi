#!/bin/bash

# Define the file path
FILE="/boot/firmware/cmdline.txt"

# Check if the file exists
if [[ ! -f "$FILE" ]]; then
    echo "File $FILE does not exist. Creating it."
    # Create the file with necessary content if it does not exist
    echo "cgroup_enable=memory cgroup_memory=1" | sudo tee "$FILE" > /dev/null
else
    echo "File $FILE exists. Updating it."
    
    # Read current content
    CURRENT_CONTENT=$(cat "$FILE")

    # Check if parameters are already present
    if [[ "$CURRENT_CONTENT" != *"cgroup_enable=memory"* ]]; then
        CURRENT_CONTENT="$CURRENT_CONTENT cgroup_enable=memory"
    fi
    if [[ "$CURRENT_CONTENT" != *"cgroup_memory=1"* ]]; then
        CURRENT_CONTENT="$CURRENT_CONTENT cgroup_memory=1"
    fi

    # Write updated content back to the file
    echo "$CURRENT_CONTENT" | sudo tee "$FILE" > /dev/null

fi

echo "Setup complete."
