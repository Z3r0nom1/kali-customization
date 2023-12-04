# Terminal Configuration Script

![Bash](https://img.shields.io/badge/language-bash-blue)

This is a Bash script that allows you to configure the initial settings of your terminal with various options. The script provides a simple menu where you can choose to install Hack Nerd Font, Sublime Text 3, bat and lsd, p10k theme for the current user, and p10k theme with root privileges.

## Prerequisites

Before running the script, ensure you have the following:

- Linux-based operating system (tested on Kali)
- `git` installed (for installing p10k themes)
- `wget` installed (for downloading font and GPG key)
- `unzip` installed (for unzipping the font)
- `gpg` installed (for importing GPG key)
- `pv` installed (for progress bar display)

## Usage

1. Clone the repository to your local machine:

```bash
git clone https://github.com/Z3r0nom1/kali-customization.git
cd kali-customization
```
2. Make the script executable:
```bash
chmod +x kali-customization.sh
```
3. Run the script:
```bash
./kali-customization.sh
```

## Menu Options

1. **Install Hack Nerd Font**: Installs the Hack Nerd Font, a patched font with extra glyphs for use in terminals.

2. **Install Sublime Text 3**: Installs Sublime Text 3, a popular cross-platform code editor.

3. **Install bat and lsd**: Installs `bat`, a cat clone with syntax highlighting, and `lsd`, an enhanced ls command.

4. **Install p10k**: Installs powerlevel10k theme for the current user.

5. **Install p10k with root privileges**: Installs powerlevel10k theme for the root user.

0. **Exit**: Exits the script.

## Note

- The `Install p10k` and `Install p10k with root privileges` options require `.zshrc` and `.p10k.zsh` files to be present in the current directory. Please make sure you have both files before running these options.
