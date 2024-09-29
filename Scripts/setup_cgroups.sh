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
    # Append the parameters if they are not already present
    if ! grep -q "cgroup_enable=memory" "$FILE"; then
        echo -n " " >> "$FILE"
        echo "cgroup_enable=memory" | sudo tee -a "$FILE" > /dev/null
    fi
    if ! grep -q "cgroup_memory=1" "$FILE"; then
        echo -n " " >> "$FILE"
        echo "cgroup_memory=1" | sudo tee -a "$FILE" > /dev/null
    fi
fi

echo "Setup complete."
