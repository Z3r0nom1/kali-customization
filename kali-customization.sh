# Function to customize the terminal
customize_terminal() {
    read -p "Enter your username: " username

    # Check if username is empty
    if [ -z "$username" ]; then
        echo "Error: Username cannot be empty."
        return 1
    fi

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo "Error: User '$username' does not exist."
        return 1
    fi

    qterminal_config="/home/$username/.config/qterminal.org/qterminal.ini"

    if [ -f "$qterminal_config" ]; then
        backup_file="$qterminal_config.bak"
        echo "Backing up the qterminal.ini file to $backup_file..."
        cp "$qterminal_config" "$backup_file"

        # Customize qterminal.ini
        echo "Customizing the qterminal.ini file..."
        cp -f ./qterminal.ini "/home/$username/.config/qterminal.org/qterminal.ini"

        # Warn user before closing QTerminal
        echo "Warning: This script will close QTerminal to apply changes. Save any unsaved work!"

        # Ask for confirmation
        read -p "Do you want to continue? (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            echo "Aborted by user. Changes not applied."
            return 1
        fi

        # Close QTerminal
        echo "Closing QTerminal..."
        pkill qterminal  # Adjust the process name if needed
        sleep 2  # Adjust the sleep duration based on how long it takes for QTerminal to close

        # Open QTerminal
        echo "Opening QTerminal to apply changes..."
        qterminal &  # Adjust the command to start QTerminal if needed
    else
        echo "Warning: qterminal.ini not found. Skipping customization."
    fi
}
