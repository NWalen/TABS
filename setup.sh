#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# Variables
USERNAME="nwalen"
USER_HOME="/home/$USERNAME"
BASH_PROFILE="$USER_HOME/.bash_profile"

# Update the package list and install required packages
apt update
apt install -y apt-transport-https curl xdotool openbox xinit xserver-xorg

# Add the Brave browser repository and install Brave
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
apt update
apt install -y brave-browser

# Create Brave startup script
cat << 'EOF' > $USER_HOME/start_brave_fullscreen.sh
#!/bin/bash
export DISPLAY=:0
brave-browser --force-device-scale-factor=1.5 &

# Wait for Brave to load fully
sleep 15

# Try sending F11 key press to enter full-screen mode
xdotool keydown F11; xdotool keyup F11
EOF

# Make the Brave startup script executable
chmod +x $USER_HOME/start_brave_fullscreen.sh
chown $USERNAME:$USERNAME $USER_HOME/start_brave_fullscreen.sh

# Ensure Openbox configuration directory exists
mkdir -p $USER_HOME/.config/openbox

# Create Openbox autostart configuration to run the Brave script
echo "$USER_HOME/start_brave_fullscreen.sh &" > $USER_HOME/.config/openbox/autostart
chown -R $USERNAME:$USERNAME $USER_HOME/.config/openbox

# Check and fix ownership of .bash_profile if needed
if [ -f "$BASH_PROFILE" ]; then
  chown $USERNAME:$USERNAME "$BASH_PROFILE"
else
  # Create .bash_profile if it doesn't exist
  touch "$BASH_PROFILE"
  chown $USERNAME:$USERNAME "$BASH_PROFILE"
fi

# Add commands to .bash_profile to start X and Openbox on login
if ! grep -q "startx" "$BASH_PROFILE"; then
  echo '
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  startx
  exec openbox-session
fi
' >> "$BASH_PROFILE"
fi

# Clean up any unused dependencies
apt autoremove -y

echo "Setup complete! Reboot to apply changes."
