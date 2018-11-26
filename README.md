# ApKill
Script for Aircrack-ng that makes deauthing clients + capturing handshakes from WiFi simple and fast.

FUNCTIONALITIES: Deauth single client, deauth all clients, find hidden AP, catch specific handshake, catch all handshakes

The script is optimized for debianesque systems. If you are on a system with APT installed, dependecies will be automatically installed during first run. (For more information about dependencies view the first lines of the script.) 

INSTALLATION: 

Just mark the script as executable and run it. 
chmod +x apkill.sh && ./apkill.sh

Load and run with one line: 

sudo apt install git && cd ~/ && git clone https://github.com/deadport/apkill && cd apkill && chmod +x apkill.sh && ./apkill.sh

Non Debian: 
Check source and edit the few bits that need to be changed. All systems that are somewhat similiar Distros to Debian work as well.

WARNING: Please check your local laws - never mess with devices you're not allowed to.
