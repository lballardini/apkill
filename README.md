# ApKill
Script for Aircrack-ng that makes deauthing clients + capturing handshakes from WiFi + DHCP pool flooding simple and fast.

FUNCTIONALITIES: Deauth single client, deauth all clients, find hidden AP, catch specific handshake, catch all handshakes,    
                 flood victims dhcp pool (dhcp starvation attack)

The script is optimized for debianesque systems. If you are on a system with APT installed, dependecies will be automatically installed during first run. (For more information about dependencies view the first lines of the script.) 

INSTALLATION: 

Just mark the script as executable and run it. 
chmod +x apkill.sh && ./apkill.sh

Load and run with one line: 

sudo apt install git && cd ~/ && git clone https://github.com/deadport/apkill && cd apkill && chmod +x apkill.sh && ./apkill.sh

Non Debian: 
Check source and edit the few bits that need to be changed. All systems that are somewhat similiar Distros to Debian work as well.

WARNING: Please check your local laws - never mess with devices you're not allowed to.

DHCP starvation attack may not work with some sticks or chipsets. While nearly every common PCI network card should work, some sticks have
trouble being fast enough. Until this can (maybe) be patched, there will be a list of sticks and cards that are known to cause such problems:
(please contribute your findings.)

AVM FritzWLAN v2 - can be used in all attacks but dhcp starvation 


