#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# Get the username from the first argument or prompt the user
if [ -n "$1" ]; then
    USERNAME="$1"
else
    read -p "Enter the username to configure: " USERNAME
fi

# Check if the user exists
if id "$USERNAME" >/dev/null 2>&1; then
    echo "Configuring for user: $USERNAME"
else
    echo "User '$USERNAME' does not exist. Please create the user and rerun the script."
    exit 1
fi

# Variables
USER_HOME="/home/$USERNAME"
BASH_PROFILE="$USER_HOME/.bash_profile"

# Update the package list and install required packages
apt update
apt install -y apt-transport-https curl openbox xinit xserver-xorg

# Add the Brave browser repository and install Brave
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
https://brave-browser-apt-release.s3.brave.com/ stable main" | \
tee /etc/apt/sources.list.d/brave-browser-release.list
apt update
apt install -y brave-browser

# Create Brave startup script
cat << 'EOF' > "$USER_HOME/start_brave_fullscreen.sh"
#!/bin/bash
export DISPLAY=:0
brave-browser --start-fullscreen --force-device-scale-factor=1.5 &
EOF

# Make the Brave startup script executable
chmod +x "$USER_HOME/start_brave_fullscreen.sh"
chown "$USERNAME:$USERNAME" "$USER_HOME/start_brave_fullscreen.sh"

# Ensure Openbox configuration directory exists
mkdir -p "$USER_HOME/.config/openbox"

# Create Openbox autostart configuration to run the Brave script
echo "$USER_HOME/start_brave_fullscreen.sh &" > "$USER_HOME/.config/openbox/autostart"
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config/openbox"

# Create .xinitrc file to start Openbox
cat << 'EOF' > "$USER_HOME/.xinitrc"
#!/bin/bash
exec openbox-session
EOF
chmod +x "$USER_HOME/.xinitrc"
chown "$USERNAME:$USERNAME" "$USER_HOME/.xinitrc"

# Check and fix ownership of .bash_profile if needed
if [ -f "$BASH_PROFILE" ]; then
  chown "$USERNAME:$USERNAME" "$BASH_PROFILE"
else
  # Create .bash_profile if it doesn't exist
  touch "$BASH_PROFILE"
  chown "$USERNAME:$USERNAME" "$BASH_PROFILE"
fi

# Add commands to .bash_profile to start X on login
if ! grep -q "startx" "$BASH_PROFILE"; then
  echo '
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  startx
fi
' >> "$BASH_PROFILE"
fi

# Enable auto-login for the specified user on tty1
mkdir -p /etc/systemd/system/getty@tty1.service.d

cat << EOF > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USERNAME --noclear %I \$TERM
Type=idle
EOF

# Reload the systemd daemon to apply changes
systemctl daemon-reload

# Clean up any unused dependencies
apt autoremove -y

echo "Setup complete for user '$USERNAME'! Reboot to apply changes and enable auto-login."
