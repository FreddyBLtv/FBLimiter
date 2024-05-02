#!/bin/bash

overwrite_prompt=false

# Check if the script already exists in the target location
if [ -e ~/FBLimiter/FBLimiter.sh ]; then
    overwrite_prompt=true
fi

# Check if a symlink already exists on the desktop
if [ -L ~/Desktop/FBLimiter ]; then
    overwrite_prompt=true
fi

# If either file exists, prompt the user to confirm overwriting
if $overwrite_prompt; then
    zenity --question --text="FBLimiter is already installed. Do you want to reinstall?"
    response=$?
    if [ $response != 0 ]; then
        zenity --info --text="Installation aborted."
        exit 1
    fi
fi

# Create the directory structure
mkdir -p ~/FBLimiter

# Move the script to the desired location
cp FBLimiter.sh ~/FBLimiter

# Make the script executable
chmod +x ~/FBLimiter/FBLimiter.sh

# Create a symbolic link on the desktop
ln -sf ~/FBLimiter/FBLimiter.sh ~/Desktop/FBLimiter

# Display a notification using Zenity
zenity --notification --text="FBLimiter has been installed successfully"
