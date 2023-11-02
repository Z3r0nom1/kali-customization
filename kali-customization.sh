#!/bin/bash

# Function to install Hack Nerd Font
install_hack_nerd_font() {
    echo "Installing Hack Nerd Font..."

    # Download the font zip file
    font_zip_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip"
    temp_dir=$(mktemp -d)
    font_zip_file="$temp_dir/Hack.zip"
    wget -q -O "$font_zip_file" "$font_zip_url" || { echo "Failed to download the font file."; return 1; }

    # Unzip the font
    unzip -q "$font_zip_file" -d "$temp_dir"

    # Move the font files to /usr/share/fonts and show the progress bar
    find "$temp_dir" -type f -exec sh -c 'pv "$1" > "/usr/share/fonts/$(basename "$1")"' _ {} \;

    # Update font cache
    sudo fc-cache -f

    # Clean up temporary files
    rm -rf "$temp_dir"

    echo "Hack Nerd Font installed successfully."
}

# Function to customize the terminal
customize_terminal() {
    read -p "Enter your username: " username

    if [ -z "$username" ]; then
        echo "Error: Username cannot be empty."
        return 1
    fi

    qterminal_config="/home/$username/.config/qterminal.org/qterminal.ini"

    if [ -f "$qterminal_config" ]; then
        backup_file="$qterminal_config.bak"
        echo "Backing up the qterminal.ini file to $backup_file..."
        cp "$qterminal_config" "$backup_file"

        # Customize qterminal.ini
        echo "Customizing the qterminal.ini file..."
        sed -i 's/^fontFamily=.*/fontFamily=Hack Nerd Font/g' "$qterminal_config"
        sed -i 's/^highlightCurrentTerminal=.*/highlightCurrentTerminal=true/g' "$qterminal_config"
        sed -i 's/^ApplicationTransparency=.*/ApplicationTransparency=0/g' "$qterminal_config"

        echo "qterminal.ini file customized successfully."
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
    if [ "$(whoami)" != "root" ]; then
        echo "This function requires root privileges. Please run with sudo."
        exit 1
    fi

    read -p "Enter your username: " username

    if [ -z "$username" ]; then
        echo "Error: Username cannot be empty."
        return 1
    fi

    echo "Installing p10k with root privileges..."

    if [ ! -f "./.zshrc" ] || [ ! -f "./.p10k.zsh" ]; then
        echo "Error: .zshrc or .p10k.zsh files not found in the current directory."
        echo "Please make sure you have both .zshrc and .p10k.zsh files present in the same directory as this script."
        exit 1
    fi

    # Clone the powerlevel10k repository as root
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k

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
