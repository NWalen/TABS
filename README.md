TABS Setup

This repository contains a setup script (setup.sh) that configures a PC to:

 •	Automatically log in a specified user.
 
 •	Launch the Brave browser in full-screen mode using Openbox.
 
 •	Set up the environment for kiosk or display applications.

Note: This script was created with the assistance of ChatGPT.

Requirements

 •	A PC running Debian or a Debian-based distribution (e.g., Ubuntu Server).
 
 •	Internet connection for downloading packages.
 
 •	An existing user account to configure for auto-login and application launch.

Installation

1.	Clone this repository to your PC:
```
git clone https://github.com/NWalen/TABS-Website-Viewer.git
cd TABS-Website-Viewer
```

2.	Run the setup script with root privileges:

```
sudo chmod +x setup.sh
sudo ./setup.sh
```
 •	The script will prompt you to enter the username you wish to configure.
 
 •	Ensure that the user account exists on your system. If not, create it before running the script.

 3.	Reboot the system to apply changes:
```
sudo reboot now
```


Usage

After rebooting, the system will:

 •	Automatically log in the specified user.
 
 •	Start an X session using Openbox.
 
 •	Launch the Brave browser in full-screen mode.

This setup is ideal for kiosk applications where you need a web browser to display content without user interaction.

Notes

 •	Security Consideration:
 
 •	Enabling auto-login bypasses the login prompt, which can be a security risk.
 
 •	Ensure the system is in a secure environment where unauthorized access is not a concern.

Troubleshooting

 •	User Does Not Exist:
 
 •	If the script reports that the user does not exist, create the user with:
```
sudo adduser username
```

 •	Auto-Login Not Working:
 
 •	Check the status of the getty service:
```
systemctl status getty@tty1.service
```

 •	Ensure that the override configuration is correctly placed in:
```
/etc/systemd/system/getty@tty1.service.d/override.conf
```

 •	Brave Browser Not Launching:
 
 •	Verify that the start_brave_fullscreen.sh script is executable and owned by the specified user:
```
ls -l /home/username/start_brave_fullscreen.sh
```
The permissions should include x (executable), and the owner should be the specified user.

 •	X Session Fails to Start:
 
 •	Check the .xinitrc file in the user’s home directory to ensure it exists and is executable:
```
ls -l /home/username/.xinitrc
```


Uninstallation

To reverse the changes made by the script:

1.	Disable Auto-Login:
Remove or rename the override configuration:
```
sudo rm /etc/systemd/system/getty@tty1.service.d/override.conf
sudo systemctl daemon-reload
```
2.	Remove Startup Scripts:
```
sudo rm /home/username/start_brave_fullscreen.sh
sudo rm /home/username/.xinitrc
sudo rm -r /home/username/.config/openbox
```

3.	Revert .bash_profile:
 •	Open /home/username/.bash_profile and remove the block that starts startx on login.
4.	Uninstall Installed Packages (Optional):
```
sudo apt remove --purge brave-browser openbox xinit xserver-xorg
sudo apt autoremove
```
3. Updating
To update Applications you can just use the usual updating method:
```
sudo apt update & sudo apt upgrade -y
```
