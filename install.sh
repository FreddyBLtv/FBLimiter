#!/bin/bash

# Specify the directory where the scripts will be placed
mkdir -p "/home/deck/FBLimiter"
SCRIPTS_DIR="/home/deck/FBLimiter"

# Prompt the user for their password
read -s -p "Enter your password: " PASSWORD
echo

# Prompt the user to select the number of profiles
read -p "Enter the number of profiles (1-3): " NUM_PROFILES

# Check if the number of profiles is valid
if [ "$NUM_PROFILES" -lt 1 ] || [ "$NUM_PROFILES" -gt 3 ]; then
    echo "Error: Number of profiles must be between 1 and 3."
    exit 1
fi

# Create arrays to store battery limits and script filenames
declare -a BATTERY_LIMITS
declare -a SCRIPT_FILENAMES

# Loop through each profile to prompt the user for battery limit
for ((i = 1; i <= NUM_PROFILES; i++)); do
    read -p "Enter the battery limit percentage for profile $i (1-100): " BATTERY_LIMIT
    BATTERY_LIMITS+=("$BATTERY_LIMIT")

    # Write the script for the profile
    cat > "$SCRIPTS_DIR/fblimiter_profile_$i.sh" <<EOF
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

    # Set executable permissions for the script
    chmod +x "$SCRIPTS_DIR/fblimiter_profile_$i.sh"

    # Add the script filename to the array
    SCRIPT_FILENAMES+=("$SCRIPTS_DIR/fblimiter_profile_$i.sh")
done

# Write the script to disable the limiter
cat > "$SCRIPTS_DIR/fblimiter_disable.sh" <<EOF
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

# Set executable permissions for the limiter disable script
chmod +x "$SCRIPTS_DIR/fblimiter_disable.sh"

# Add the limiter disable script to the array
SCRIPT_FILENAMES+=("$SCRIPTS_DIR/fblimiter_disable.sh")

# Run steamos-add-to-steam to add all scripts to Steam Deck
for script in "${SCRIPT_FILENAMES[@]}"; do
    chmod +x "$script" # Set executable permissions for each profile script
    steamos-add-to-steam "$script"
    sleep 7  # Add a 7-second pause
done

echo "FBLimiter has been installed successfully!"

exit
