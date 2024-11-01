#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update the package list and install required packages
apt update
apt install -y apt-transport-https curl xdotool openbox xinit xserver-xorg

# Add the Brave browser repository and install Brave
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
apt update
apt install -y brave-browser

# Create Brave startup script
cat << 'EOF' > ~/start_brave_fullscreen.sh
#!/bin/bash
export DISPLAY=:0
brave-browser --force-device-scale-factor=1.5 &

# Wait for Brave to load fully
sleep 15

# Try sending F11 key press to enter full-screen mode
xdotool keydown F11; xdotool keyup F11
EOF

# Make the Brave startup script executable
chmod +x ~/start_brave_fullscreen.sh

# Configure Openbox autostart to run the Brave script
mkdir -p ~/.config/openbox
echo "~/start_brave_fullscreen.sh &" > ~/.config/openbox/autostart

# Configure .bash_profile to start X and Openbox on login
BASH_PROFILE=~/.bash_profile
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