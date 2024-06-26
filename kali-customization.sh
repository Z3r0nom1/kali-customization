#!/bin/bash

# Function to install Hack Nerd Font
install_hack_nerd_font() {
  echo "Installing Hack Nerd Font..."

  # Enable error control
  set -e

  # Download the font zip file
  echo "Downloading Hack Nerd Font..."
  font_zip_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip"
  temp_dir=$(mktemp -d)
  font_zip_file="$temp_dir/Hack.zip"

  # Download and unzip with error handling
  wget -q -O "$font_zip_file" "$font_zip_url" && echo "Font download successful" || { echo "Error: Failed to download the font file."; rm -rf "$temp_dir"; exit 1; }
  unzip -q "$font_zip_file" -d "$temp_dir" && echo "Font unzipped successfully" || { echo "Error: Failed to unzip the font file."; rm -rf "$temp_dir"; exit 1; }

  # Check if any files were extracted
  if [[ ! $(find "$temp_dir" -type f) ]]; then
    echo "Error: No files found in temporary directory. Unzip might have failed."
    rm -rf "$temp_dir"
    exit 1
  fi

  # Find font files with flexible patterns and store in an array
  font_files=( $(find "$temp_dir" -type f -name "*.ttf") )

  # Install fonts with sudo (assuming script is run with sudo)
  echo "Installing fonts to system directory (/usr/share/fonts)..."

  # Loop through font files in the array and copy
  for font_file in "${font_files[@]}"; do
    sudo cp "$font_file" /usr/share/fonts
  done

  echo "Font files installed successfully!"

  # Update font cache (if applicable)
  if [[ -n "$(command -v fc-cache)" ]]; then
    echo "Updating font cache"
    fc-cache -f
  fi

  # Clean up temporary files
  echo "Cleaning temporary files: $temp_dir"
  rm -rf "$temp_dir"

  set +e

  echo "Hack Nerd Font installation complete!"
}


# Function to customize the terminal
customize_terminal() {
    username=$USER

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


# Function to install Sublime Text 3
install_sublime_text() {
    echo "Installing Sublime Text 3..."

    # Import Sublime Text GPG key
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null

    # Add Sublime Text repository to sources list
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    # Update package lists
    sudo apt-get update

    # Install Sublime Text
    sudo apt-get install -y sublime-text

    echo "Sublime Text 3 installed successfully."
}


# Function to install bat and lsd
install_bat_lsd() {
    echo "Installing bat and lsd..."

    # Update package lists and upgrade installed packages
    sudo apt update && sudo apt upgrade -y

    # Install bat and lsd packages
    sudo apt install -y bat lsd

    echo "bat and lsd installed successfully."
}


# Function to install p10k
install_p10k() {
    echo "Installing p10k..."

    echo "Current directory: $(pwd)"

    if [ ! -f "./.zshrc" ] || [ ! -f "./.p10k.zsh" ]; then
        echo "Error: .zshrc or .p10k.zsh files not found in the current directory."
        echo "Please make sure you have both .zshrc and .p10k.zsh files present in the same directory as this script."
        exit 1
    fi

    # Clone the powerlevel10k repository as the current user
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

    # Add the powerlevel10k theme to the .zshrc file
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

    # Overwrite ~/.p10k.zsh and ~/.zshrc with ./.p10k.zsh and ./.zshrc from the current directory
    cp -f ./.p10k.zsh ~/.p10k.zsh
    cp -f ./.zshrc ~/.zshrc

    echo "p10k installed successfully."
}


# Function to install p10k with root privileges
install_p10k_root() {
    if [ "$USER" != "root" ]; then
        echo "This function requires to be root user. Please run it as root."
        exit 1
    fi

    read -p "Enter the username that you want to copy the configuration from: " username

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

    echo "Installing p10k with root privileges..."

    if [ ! -f "./.zshrc" ] || [ ! -f "./.p10k.zsh" ]; then
        echo "Error: .zshrc or .p10k.zsh files not found in the current directory."
        echo "Please make sure you have both .zshrc and .p10k.zsh files present in the same directory as this script."
        exit 1
    fi

    # Clone the powerlevel10k repository as root
    #git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
    cp -r /home/$username/powerlevel10k /root/powerlevel10k
    
    # Add the powerlevel10k theme to root's .zshrc file
    echo 'source /root/powerlevel10k/powerlevel10k.zsh-theme' >> /root/.zshrc

    # Overwrite /root/.p10k.zsh with ./.p10k.zsh from the current directory
    cp -f ./.p10k.zsh /root/.p10k.zsh

    # Create a symbolic link for .zshrc in the home directory of the current user
    ln -sf /home/$username/.zshrc /root/.zshrc

    echo "p10k installed successfully for root."
}


# Main menu
while true; do
    echo "Terminal Configuration Menu"
    echo "1. Install Hack Nerd Font"
    echo "2. Customize Terminal"
    echo "3. Install Sublime Text 3"
    echo "4. Install bat and lsd"
    echo "5. Install p10k"
    echo "6. Install p10k with root privileges"
    echo "0. Exit"

    read -p "Enter your choice: " choice
    echo

    case $choice in
        1)
            install_hack_nerd_font
            ;;
        2)
            customize_terminal
            ;;
        3)
            install_sublime_text
            ;;
        4)
            install_bat_lsd
            ;;
        5)
            install_p10k
            ;;
        6)
            install_p10k_root
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac

    echo
done
