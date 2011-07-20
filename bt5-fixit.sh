#!/bin/bash
#__________________________________________________________
# Authors:    	phillips321 (matt@phillips321.co.uk)
# License:    	CC BY-SA 3.0
# Use:        	Brings tools on BackTrack5 to bleeding edge 
#               and adds missing tools
# Released:   	www.phillips321.co.uk
#__________________________________________________________
version="1.2" #July/2011
# Changelog:
# v1.2 - Added mz, scapy, FernWifiCracker
# v1.1 - Added -u flag to allow skipping to updates function
# v1.0 - Official Release
# v0.4 - Cleaned up and added TUI checklist
# v0.3 - Added nipper, fwbuilder and routerdefense
# v0.2 - Clean with more missing apps
# v0.1 - First release
# 
# ToDo:
# - Let me know what you want
# - 
welcome_msg() { #Introduction messagebox
	dialog --title "bt5-fixit.sh" \
	--msgbox "Authors: phillips321 (matt@phillips321.co.uk)
License: CC BY-SA 3.0
Use: Brings tools on BackTrack5 to bleeding edge and adds missing tools
Released: www.phillips321.co.uk
Version: ${version}" 10 60
}
netcheck() { #checks the internet is working
	if [ `ping -c 1 -s 1000 google.com |grep received | awk -F, '{print $2}' |awk '{print $1}' ` -eq 1 ]
	then
		echo "Net connection working"
	else
		dialog --title "EPIC FAIL" --msgbox "You need a net connection to continue..." 8 60
		clear
		echo "You need a net connection to continue..."
		exit 1
	fi	;}
extra_repositories() { #this adds extra repos allowing more software to be installed
		cd /tmp
	grep fwbuilder /etc/apt/sources.list ; addrepos=$?
	if [ ${addrepos} = "1" ] #check to see if repos have already been added
	then
		dialog --title "Extra Repositiories"  --yesno "We are now going to install extra repositories and update from them in order for this tool to function. Do you want to continue?" 8 60
		return=$?
		if [ ${return} == 1 ]
		then
			dialog --title "EPIC FAIL" --msgbox "If you're worried about adding extra repo's please check the code to see which ones are added, the function is called extra_repositories funily enough..." 8 60
			clear
			echo "If you're worried about adding extra repo's please check the code to see which ones are added, the function is called extra_repositories funily enough"
			exit 1
		fi
		apt-get install -y python-software-properties
	    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 4E5E17B5
		add-apt-repository ppa:chromium-daily/stable
		wget -q -O – https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
		rm -
		echo "deb http://packages.fwbuilder.org/deb/stable/ maverick contrib" >> /etc/apt/sources.list
		wget http://www.fwbuilder.org/PACKAGE-GPG-KEY-fwbuilder.asc && apt-key add PACKAGE-GPG-KEY-fwbuilder.asc
		rm PACKAGE-GPG-KEY-fwbuilder.asc
		echo "deb http://dl.google.com/linux/chrome/deb/ stable main #Google Stable Source" >> /etc/apt/sources.list
		wget -O - http://deb.opera.com/archive.key | apt-key add -
		echo "deb http://deb.opera.com/opera/ lenny non-free #Opera Official Source" >> /etc/apt/sources.list
		add-apt-repository ppa:sevenmachines/flash
		add-apt-repository ppa:shutter/ppa
		add-apt-repository ppa:tualatrix/ppa
		add-apt-repository ppa:ubuntu-wine/ppa
		apt-get update
		apt-get -y dist-upgrade
		apt-get -y autoclean
		dialog --title "bt5-fixit.sh" --msgbox "Repositories have been added and standard updates applied, moving on" 10 60
	else
		dialog --title "bt5-fixit.sh" --msgbox "Repositories already added, moving on" 10 60
	fi
}
configuration_stuff(){ #changes small things that have been overlooked in BackTrack
	dialog --title "Configuration Changes Selection" --separate-output --output-fd 2 --checklist "What minor changes do you wish to make?" 0 0 0 \
		fixsplash "fix the broken splash after an install" on \
		bashcompletion "allow bash completition" on \
		kernelsources "Install kernel sources" on \
		2> /tmp/answer
	result=`cat /tmp/answer` && rm /tmp/answer ; clear
	for opt in ${result}
	do
		clear
		sleep 2
		echo "###############################################"
		echo "Now running ${opt} changes"
		echo "###############################################"
		case ${opt} in
			fixsplash) : do ; fix-splash ;;
			bashcompletion) : do ; sed -i '/# enable bash completion in/,+3{/enable bash completion/!s/^#//}' /etc/bash.bashrc ;;
			kernelsources) : do ; prepare-kernel-sources ; cd /usr/src/linux ; cp -rf include/generated/* include/linux/ ;;
		esac
	done
}
missing_stuff(){ #installs software that is missing that many people rely on!
	dialog --separate-output --output-fd 2 --title "Missing Tools" --checklist "What do you want to add to BackTrack? (This is missing stuff that for some reason they didn't include!)" 0 0 0 \
		build-essential "contains the tools required for building software" on \
		network-manager-gnome "gnome network manager in taskbar(top right)" off \
		linux-headers "includes the header files for the kernel" on \
		linux-source "includes the source files for the kernel" on \
		filezilla "an FTP client" on \
		synaptic "gui for aptitude" on \
		geany "Text editor for programmers" on \
		netsed "changes network packets off the fly" on \
		arp-scan "allows anumeration of devices off subnet" on \
		shutter "great screenshot untility for gnome" on \
		gnome-web-photo "allows screenshots to be taken of URLs" on \
		vino "Gnome VNC server" on \
		etherape "grpahical network monitor" on \
		gufw "gnome frontend for UbuntuFireWall" on \
		htop "like top but more functions" on \
		libssl-dev "SSL develop[ment libraries" on \
		scapy "packet manipulation program" on \
		python-dev "python development libraries" on \
		chromium-codecs-ffmpeg-extra "chromium extras" on \
		chromium-codecs-ffmpeg-nonfree "chromium extras" on \
		opera "another web browser, the more the merrier" on \
		flashplugin-nonfree-extrasound "adobe flash plugin extras" on \
		flashplugin-nonfree "adobe flash plugin " on \
		p7zip-full "7zip archive utility" on \
		p7zip-rar "7zip archive rar capabilities" on \
		file-roller "gnome based archive mounter" on \
		giplet "Gnome applet to display IP (Rightclick toolbar-> add to panel)" on \
		ubuntu-tweak "configure gnome (max,min,close button location)" on \
		python-vte "python terminal emulator libraries" on \
		compiz-plugins "compiz plugins for the matrix effect" on \
		screen "allows multiple terminals in one session" on \
		fwbuilder "allows creation/import of firewall rulesets" on \
		mz "allows creation of packets" on \
		scapy "allows creation of packets" on \
		2> /tmp/answer
	result=`cat /tmp/answer` && rm /tmp/answer ; clear
	apt-get install -y ${result}
	apt-get -y autoclean
	}
install_stuff(){ #removes existing packages and replaces them with svn versions
	dialog --title "Install from SVN"  --yesno "We are now going to remove packages and then replace them with their SVN countertparts. This will allow updating to the latest versions.If this is the first time you haved run this tool you will need to select NO. Do you wish to skip?" 8 60
		return=$?
		if [ ${return} == 1 ]
		then
			dialog --separate-output --output-fd 2 --title "Convert to SVN" --checklist "What packages do you want to install/convert to SVN installs?" 0 0 0 \
			wifite "mass wep/wpa cracker" on \
			w3af "Web Application Attack and Audit Framework" on \
			openvas "Open Vulnerability Assessment System" on \
			set "Social engineering Toolkit" on \
			blindelephant "Web Application Fingerprinter" on \
			sqlmap "Automatic SQL injection" on \
			nikto "Web server scanner" on \
			routerdefense "Cisco auditer" on \
			pyrit "Install pyrit!" off \
			fernwificracker "GUI based wifi cracker" on \
			2> /tmp/answer
			result=`cat /tmp/answer` && rm /tmp/answer ; clear
			for opt in ${result}
			do
				clear
				echo "###############################################"
				echo "Now installing: ${opt}"
				echo "###############################################"
				sleep 2
				case ${opt} in
					wifite) : do ; i_wifite ;;
					w3af) : do ; i_w3af ;;
					openvas) : do ; i_openvas ;;
					set) : do ; i_set ;;
					blindelephant) : do ; i_blindelephant ;;
					sqlmap) : do ; i_sqlmap ;;
					exploitdb) : do ; i_exploitdb ;;
					routerdefense) : do ; i_routerdefense ;;
					pyrit) : do ; i_pyrit ;;
					fernwificracker) : do ; i_fernwificracker ;;
				esac
				sleep 2
			done
		else
				echo "skipped svn install"
		fi
}
update_stuff(){ #updates packages previously converted to svn
	dialog --separate-output --output-fd 2 --title "Tool Updater" --checklist "What packages do you want to update?" 0 0 0 \
		msf3 "update me?" on \
		w3af "update me?" on \
		openvas "update me?" on \
		set "update me?" on \
		fasttrack "update me?" on \
		blindelephant "update me?" on \
		sqlmap "update me?" on \
		nikto "update me?" on \
		exploitdb "update me?" on \
		nessus "update me?" on \
		routerdefense "update me?" on \
		warvox "update me?" on \
		aircrack "update me?" on \
		giskismet "update me?" on \
		nmap "update nmap fingerprints?" on \
		fimap "update me?" on \
		wifite "update me?" on \
		fernwificracker "update me?" on \
		2> /tmp/answer
	result=`cat /tmp/answer` && rm /tmp/answer ; clear
	for opt in ${result}
	do
		clear
		echo "###############################################"
		echo "Now updating: ${opt}"
		echo "###############################################"
		sleep 2
		case ${opt} in
			wifite) : do ; u_wifite ;;
			msf3) : do ; u_msf3 ;;
			w3af) : do ; u_w3af ;;
			openvas) : do ; u_openvas ;;
			set) : do ;u_set ;;
			fasttrack) : do ;u_fasttrack ;;
			blindelephant) : do ;u_blindelephant ;;
			sqlmap) : do ; u_sqlmap ;;
			nikto) : do ; u_nikto ;;
			exploitdb) : do ; u_exploitdb ;;
			nessus) : do ; u_nessus ;;
			routerdefense) : do ; u_routerdefense ;;
			warvox) : do ; u_warvox ;;
			aircrack) : do ; u_aircrack ;;
			giskismet) : do ; u_giskismet ;;
			nmap) : do ; u_nmap ;;
			fimap) : do ; u_fimap ;;
			fernwificracker) : do ; u_fernwificracker ;;
		esac
		sleep 2
	done	
}
goodbye_msg() {
	dialog --title "bt5-fixit.sh" --msgbox "Updates Complete!
In the future you can run this command with the -u flag" 10 60
	clear
}

### Installers for each program ########################################################################################
i_wifite() {
	cd /pentest/wireless/
	wget -O wifite.py http://wifite.googlecode.com/svn/trunk/wifite.py
	chmod +x wifite.py ; }
i_w3af() { 
	cp /usr/share/applications/backtrack-w3af-gui.desktop /tmp/.
	cp /usr/share/applications/backtrack-w3af-console.desktop /tmp/.
	cp /usr/share/app-install/desktop/w3af.desktop /tmp/.
	apt-get purge -y w3af
	cd /pentest/web
	svn co https://w3af.svn.sourceforge.net/svnroot/w3af/trunk w3af 
	cp /tmp/backtrack-w3af-gui.desktop /usr/share/applications/.
	cp /tmp/backtrack-w3af-console.desktop /usr/share/applications/. 
	cp /tmp/w3af.desktop /usr/share/applications/. ; }
i_openvas() {
	dialog --title "OpenVAS install" \
	--msgbox "You are about to install OpenVAS. These are the install instructions, read them!
During install a certificate will be created - Just press [Enter] 7 times
Enter the username - most people use root[Enter]
Tell OpenVas you want to use a password - Just press [Enter]
Enter the password - most people use toor
Enter blank rules if you wish - Ctrl-D when done
Tell OpenVas you're happy with the settings - Just press [Enter]" 20 70
	apt-get install -y openvas-scanner
	openvas-mkcert
	openvas-adduser  
	}
i_blindelephant() {
	cp /usr/share/applications/backtrack-blindelephant.desktop /tmp/.
	apt-get purge -y blindelephant
	cd /pentest/web
	svn co https://blindelephant.svn.sourceforge.net/svnroot/blindelephant/trunk blindelephant
	cd blindelephant/src
	python setup.py install
	cp /tmp/backtrack-blindelephant.desktop /usr/share/applications/. ; }
i_sqlmap() {
	cp /usr/share/applications/backtrack-sqlmap.desktop /tmp/.
	apt-get purge -y sqlmap
	svn co https://svn.sqlmap.org/sqlmap/trunk/sqlmap sqlmap
	cp /tmp/backtrack-sqlmap.desktop /usr/share/applications/. ; }
i_nikto() {
	cp /usr/share/applications/backtrack-nikto.desktop /tmp/.
	apt-get purge -y nikto
	cd /pentest/web/
	svn co http://svn2.assembla.com/svn/Nikto_2/trunk/ nikto
	cd nikto
	./nikto.pl -update
	cp /tmp/backtrack-nikto.desktop /usr/share/applications/. ; }
i_routerdefense() { svn checkout http://routerdefense.googlecode.com/svn/trunk/ /vaw/www/routerdefense ;}
i_pyrit() {
	apt-get -y install libssl-dev scapy python-dev
	cd /tmp/
	svn checkout http://pyrit.googlecode.com/svn/trunk/ pyrit_svn
	cd pyrit_svn/pyrit && python setup.py build && python setup.py install
	cd /tmp/
	rm -rf /tmp/pyrit_svn
}
i_fernwificracker() {
	cd /pentest/wireless/
	svn checkout http://fern-wifi-cracker.googlecode.com/svn/Fern-Wifi-Cracker/
	chmod +x /pentest/wireless/Fern-Wifi-Cracker/execute.py
	}
### Update commands for each program ###################################################################################
u_wifite() { /pentest/wireless/wifite.py -upgrade ; }
u_msf3() { /pentest/exploits/framework3/msfupdate ; }
u_w3af() { svn up /pentest/web/w3af/ ;}
u_openvas() { openvas-nvt-sync ;}
u_set() { cd /pentest/exploits/set/ ; ./set-update ;}
u_fasttrack() { 
	apt-get -y update fasttrack
	cd /pentest/exploits/fasttrack/ 
	./fast-track.py -c 1 1 ;}
u_blindelephant() {
	 cd /pentest/web/blindelephant
	svn up
	cd src
	python setup.py install ; }
u_sqlmap() { svn up --trust-server-cert --non-interactive /pentest/database/sqlmap/ ;}
u_nikto() { cd /pentest/web/nikto/ ; svn up ; ./nikto.pl -update ;}
u_exploitdb() { svn up /pentest/exploits/exploitdb ;}
u_nessus() { 
	ps -A | grep nessus > /dev/null
	if [ $? != 0 ]; then
    		/etc/init.d/nessusd start
			sleep 10
	fi
	/opt/nessus/sbin/nessus-update-plugins ;}
u_routerdefense() { svn up /vaw/www/routerdefense/ ;}
u_warvox() { svn up /pentest/telephony/warvox/ ;}
u_aircrack() {
		cd /pentest/wireless/aircrack-ng/ && svn up
		cd /pentest/wireless/aircrack-ng/scripts/ && chmod a+x airodump-ng-oui-update && ./airodump-ng-oui-update
		cd /tmp/
}
u_giskismet() { svn up /pentest/wireless/giskismet/ ;}
u_nmap() { wget http://nmap.org/svn/nmap-os-db -O /usr/local/share/nmap/nmap-os-db ;}
u_fimap() { cd /pentest/web/fimap/ && ./fimap.py --update-def ;}
u_fernwificracker() { svn up /pentest/wireless/Fern-Wifi-Cracker/ ; chmod +x /pentest/wireless/Fern-Wifi-Cracker/execute.py ;}

help_msg() { # help message
	clear
	echo -e "Usage: $0 [options]
 Options:
  -u : Update packages (only use me after you have run run normally)
  -h : This help message!
 Example:
        $0 fiu"
        exit 1
}

main(){ #default block of code
startdir=`pwd` ; cd /tmp/
if [ "$#" == 0 ]
then # default run to include everything
	welcome_msg ;netcheck; extra_repositories; configuration_stuff; missing_stuff; install_stuff; update_stuff; goodbye_msg
else # only run me if i recieve a command line value
	while getopts "uh" execute; do
		case ${execute} in
			u) welcome_msg ; netcheck; update_stuff; goodbye_msg ;;
			h) help_msg ;;
			?) help_msg ;;
		esac
	done
fi
cd ${startdir}
}
main
exit 0

# 
