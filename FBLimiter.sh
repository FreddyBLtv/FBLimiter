#!/bin/bash

# Function to check if profiles already exist in the install location
check_existing_profiles() {
    local SCRIPTS_DIR="$1"

    if [ -d "$SCRIPTS_DIR" ] && [ "$(ls -A "$SCRIPTS_DIR")" ]; then
        zenity --question --title="Existing Profiles Detected" --text="Existing profiles are found in the install location. Overwrite them?" --width=300
        return $?
    else
        return 1
    fi
}

# Function to install the script
install_script() {
    # Specify the directory where the scripts will be placed
    local SCRIPTS_DIR="/home/deck/FBLimiter"

    # Check if the directory exists, otherwise create it
    if [ ! -d "$SCRIPTS_DIR" ]; then
        mkdir -p "$SCRIPTS_DIR" || { zenity --error --title="Error" --text="Failed to create directory: $SCRIPTS_DIR"; exit 1; }
    fi

    # Check if profiles already exist
    check_existing_profiles "$SCRIPTS_DIR"
    local EXISTING_PROFILES=$?

    if [ $EXISTING_PROFILES -eq 0 ]; then
        rm -rf "$SCRIPTS_DIR"/* || { zenity --error --title="Error" --text="Failed to remove existing profiles."; exit 1; }
    elif [ $EXISTING_PROFILES -eq 1 ]; then
        true
    else
        zenity --error --title="Error" --text="Error occurred while checking existing profiles."
        exit 1
    fi

    # Use zenity to get the password securely (hidden input)
    local PASSWORD=$(zenity --entry --title="FBLimiter" --text="Enter your password:" --hide-text)

    # Check if password entry was cancelled
    if [ -z "$PASSWORD" ]; then
        zenity --error --title="Error" --text="Password entry cancelled. Exiting installation."
        exit 1
    fi

    # Use zenity to get the number of profiles (1-3)
    local NUM_PROFILES=$(zenity --entry --title="FBLimiter" --text="Enter the number of profiles (1-3):" --width=200)

    # Check if number entered is valid (numeric, between 1 and 3)
    if ! [[ "$NUM_PROFILES" =~ ^[1-3]$ ]]; then
        zenity --error --title="Error" --text="Invalid number of profiles. Please enter a number between 1 and 3."
        exit 1
    fi

    # Loop through each profile using zenity to get battery limits
    for ((i = 1; i <= NUM_PROFILES; i++)); do
        local BATTERY_LIMIT=$(zenity --entry --title="FBLimiter - Profile $i" --text="Enter the battery limit percentage (1-100):" --width=250)

        # Check if battery limit entered is valid (numeric, between 1 and 100)
        if ! [[ "$BATTERY_LIMIT" =~ ^[1-9][0-9]?$ || "$BATTERY_LIMIT" -eq 100 ]]; then
            zenity --error --title="Error" --text="Invalid battery limit. Please enter a number between 1 and 100."
            exit 1
        fi

        # Write the script content directly to the file
        local SCRIPT_FILENAME="$SCRIPTS_DIR/fblimiter_profile_${i}_${BATTERY_LIMIT}%.sh"
        cat > "$SCRIPT_FILENAME" <<EOF
#!/bin/bash

# Define the password
PASSWORD="$PASSWORD"

# Define the battery limit percentage
BATTERY_LIMIT=$BATTERY_LIMIT

# Run the command with the password
command_to_run_with_password() {
  echo "\$PASSWORD" | sudo -S bash -c 'echo '\$BATTERY_LIMIT' > /sys/class/hwmon/hwmon3/max_battery_charge_level'
}

# Call the function to run the command
command_to_run_with_password

zenity --info --text "Battery Limit set to $BATTERY_LIMIT%" --width 300 2>/dev/null
EOF

        # Set executable permissions
        chmod +x "$SCRIPT_FILENAME"
    done

    # Write the script to disable the limiter
    local DISABLE_SCRIPT="$SCRIPTS_DIR/fblimiter_disable.sh"
    cat > "$DISABLE_SCRIPT" <<EOF
#!/bin/bash

# Define the password
PASSWORD="$PASSWORD"

# Run the command with the password
command_to_run_with_password() {
  echo "\$PASSWORD" | sudo -S bash -c 'echo 0 > /sys/class/hwmon/hwmon3/max_battery_charge_level'
}

# Call the function to run the command
command_to_run_with_password

zenity --info --text "Battery Limit OFF" --width 300 2>/dev/null
EOF

    # Set executable permissions for the disable script
    chmod +x "$DISABLE_SCRIPT"

    # Add scripts to Steam Deck (if command available)
    if command -v steamos-add-to-steam >/dev/null 2>&1; then
        for SCRIPT_FILENAME in "$SCRIPTS_DIR"/*.sh; do
            steamos-add-to-steam "$SCRIPT_FILENAME"
            sleep 7  # Add a 7-second pause
        done
        zenity --info --text "Profiles added to Steam" --width 300
    else
        zenity --error --text="Error: steamos-add-to-steam command not found. Profiles were not added to Steam"
        exit 1
    fi
}

# Function to uninstall the script
uninstall_script() {
    # Specify the directory where the scripts are located
    local SCRIPTS_DIR="/home/deck/FBLimiter"

    # Validate SCRIPTS_DIR
    if [ ! -d "$SCRIPTS_DIR" ]; then
        zenity --error --title="Error" --text="Error: $SCRIPTS_DIR does not exist."
        exit 1
    fi

    # Remove the scripts directory and its contents
    rm -rf "$SCRIPTS_DIR"
    rm -rf ~/Documents/FBlimiter
    rm /home/deck/Desktop/FBLimiter

    zenity --info --title="Uninstallation Complete" --text="FBLimiter uninstalled successfully!" --width=300
}

# Display GUI with options
CHOICE=$(zenity --list --title="FBLimiter" --text="Choose an action:" --column="Action" "Make Profile(s)" "Uninstall" --width=200 --height=200)

case $CHOICE in
    "Make Profile(s)")
        install_script
        ;;
    "Uninstall")
        uninstall_script
        ;;
    *)
        # No action needed if the user closes the window
        ;;
esac
