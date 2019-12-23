#! /bin/bash

# This is where all the utility functions reside for the SafeGuard Installer


export printGreen=$'\e[1;32m'
export printWhite=$'\e[0m'
export printRed=$'\e[1;31m'
export printCyan=$'\e[1;36m'
# Absolute path to this script
SCRIPT=$(readlink -f "$0")
echo "SCRIPT  DIR:"
echo "${SCRIPT}"
# Absolute path to the script directory
BASEDIR=$(dirname "$SCRIPT")
echo "BASEDIR:"
echo "${BASEDIR}"
HOME_DIR=$(eval echo ~"$(logname)")
echo "HOME_DIR: "
echo "${HOME_DIR}"


firstIteration() {
	local token="$1"
	local repoPath="${HOME_DIR}"/SafeGuard-Installer
	echo "Repo Path:"
	echo "${printCyan}${repoPath}${printWhite}"
	echo "Token is:"
	echo -e "${printCyan}${token}${printWhite}"

	if [[ -z ${token} ]]; then 
	    echo
	    echo "You must provide a docker registry token!"
	    echo "Exiting...
"	    exit 1
	fi
	#dependencies and resources
	wget -q --show-progress -O "${repoPath}/Teamviewer.deb" "https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
	wget -q --show-progress -O "${HOME_DIR}/Desktop/SafeGuard.AppImage" https://github.com/ANVSupport/SafeGuard-Installer/releases/download/Appimage/FaceSearch-1.20.0-linux-x86_64.AppImage
	chmod +x "${HOME_DIR}/Desktop/SafeGuard.AppImage" && chown "$(logname)" "${HOME_DIR}/Desktop/SafeGuard.AppImage"
	echo "==========================================================="
	echo "                   ${printCyan}Installing Utilities...${printWhite}                "
	echo "==========================================================="
	chmod -R +x "${repoPath}"*
	rm -rf /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend
	dpkg -a --configure # fixes issues with dpkg preventing the script from running...
	if [[ -f /var/lib/dpkg/lock || -f /var/lib/dpkg/lock-frontend ]]; then
		echo "${printRed}""Lock Could not be deleted, is the update center open?""${printWhite}"
		read -p "Please close anything that uses apt and enter y when finished. Press N to abort: " -n 1 -r $cont
		case "$cont" in
		y|Y) installUtils;;
		n|N) echo "Exiting..."; exit 1;;
		*) echo "Invalid choice, Exiting.."; exit 1;;
		esac
	else
		installUtils
	fi
	cp "${repoPath}"/SafeGuard-Assets/SGLogo.jpg "${HOME_DIR}"/Desktop/SGLogo.jpg
	apt-get install "${repoPath}/Teamviewer.deb" > /dev/null && successfulPrint "TeamViewer" ## To test
	mv "${repoPath}/SafeGuard-Assets/secondIteration.sh" /opt/secondIteration.sh # prepare it to be run after reboot

	# Call storage mounting script
	if  bash "${repoPath}/SafeGuard-Assets/mount.sh" ; then
		successfulPrint "mounting"
	else
		Error=$?
		failedPrint "mounting"
		echo "Please mount manually and run this script again"
		echo "Error: ""${Error}"
		exit 1
	fi

	##moxa set up
	moxadir=${HOME_DIR}/moxa-config
	mkdir "${moxadir}"
	mv "${repoPath}/SafeGuard-Assets/moxa_e1214.sh" "${moxadir}"/moxa_e1214.sh
	mv "${repoPath}"/SafeGuard-Assets/cameraList.json "${moxadir}"/cameraList.json && successfulPrint "Moxa setup"
	chmod +x "${moxadir}"* && chown user "${moxadir}"*

	cat << "EOF"
	 _____              _          _  _  _                    _____          __        _____                         _          
	|_   _|            | |        | || |(_)                  / ____|        / _|      / ____|                       | |         
	  | |   _ __   ___ | |_  __ _ | || | _  _ __    __ _    | (___    __ _ | |_  ___ | |  __  _   _   __ _  _ __  __| |         
	  | |  | '_ \ / __|| __|/ _` || || || || '_ \  / _` |    \___ \  / _` ||  _|/ _ \| | |_ || | | | / _` || '__|/ _` |         
	 _| |_ | | | |\__ \| |_| (_| || || || || | | || (_| |    ____) || (_| || | |  __/| |__| || |_| || (_| || |  | (_| | _  _  _ 
	|_____||_| |_||___/ \__|\__,_||_||_||_||_| |_| \__, |   |_____/  \__,_||_|  \___| \_____| \__,_| \__,_||_|   \__,_|(_)(_)(_)
	                                                __/ |                                                                       
	                                               |___/                                                                        
EOF
	bash "${repoPath}"/compose-oneliner/compose-oneliner.sh -b 1.20.0 -k "${token}" && successfulPrint "SafeGuard Installed"
	 	ln -s "${HOME_DIR}/docker-compose/1.20.0/docker-compose-local-gpu.yml" "${HOME_DIR}/docker-compose/1.20.0/docker-compose.yml" && successfulPrint "Create Symbolic Link"
	echo "1" > /opt/sg.f ##flag if the script has been run 

	##make script auto run after login
	local startupFile
	local startupDir
	startupDir=${HOME_DIR}/.config/autostart
	mkdir -p "${startupDir}"
	startupFile="${startupDir}"/secondIteration.desktop
	> "${startupFile}" # create startup file
	tee -a ${startupFile} <<EOF && successfulPrint "Startup added" # EOF without quotations or backslash evaluates variables
[Desktop Entry]
Type=Application
Exec=gnome-terminal -- sh -c '${repoPath}/SafeGuard-Assets/launchAsRoot.sh'
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_NG]=Terminal
Name=Terminal
Comment[en_NG]=Start Terminal On Startup
Comment=Start Terminal On Startup
EOF
chmod +x ${startupFile}
ln -s "${repoPath}"/SafeGuard-Assets/secondIteration.sh "${HOME_DIR}"/Desktop/runThisAsRoot.sh
chmod +x "${HOME_DIR}"/Desktop/runThisAsRoot.sh
echo "xhost +" >> "${HOME_DIR}"/.profile
}
clean(){
	cat << "EOF"

	  _____  _                      _                  _____              _                   
	 / ____|| |                    (_)                / ____|            | |                  
	| |     | |  ___   __ _  _ __   _  _ __    __ _  | (___   _   _  ___ | |_  ___  _ __ ___  
	| |     | | / _ \ / _` || '_ \ | || '_ \  / _` |  \___ \ | | | |/ __|| __|/ _ \| '_ ` _ \ 
	| |____ | ||  __/| (_| || | | || || | | || (_| |  ____) || |_| |\__ \| |_|  __/| | | | | |
	 \_____||_| \___| \__,_||_| |_||_||_| |_| \__, | |_____/  \__, ||___/ \__|\___||_| |_| |_|
	                                           __/ |           __/ |                          
	                                          |___/           |___/                           
EOF
	apt-get remove --purge ./*docker* docker-compose nvidia-container-runtime nvidia-container-toolkit nvidia-docker nvidia* > /dev/null && successfulPrint "Purge drivers and docker"
	rm -rfv "${HOME_DIR}"/docker-compose/*
	rm -rfv "${HOME_DIR}"/Downloads/*
	rm -rfv /opt/sg.f && successfulPrint "remove flag" ##clear iteration flag because everything has been cleaned
	rm -rfv /ssd/*
	rm -rfv /storage/*
	successfulPrint "System Clean"
}
installUtils(){
	rm -f /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend
	dpkg -a --configure # fixes issues with dpkg preventing the script from running...
	apt-get install vlc curl vim htop net-tools expect > /dev/null &
	progressBar 15
}
successfulPrint(){
	echo -e "=================================================================="
	echo -e "                    $1 ....${printGreen}Success${printWhite}                  "
	echo -e "=================================================================="
}

failedPrint(){
	echo -e "=================================================================="
	echo -e "                    $1 ....${printRed}Failed!${printWhite}                  "
	echo -e "=================================================================="
}
progressBar() {
  local duration=${1}
    already_done() { for ((done=0; done<$elapsed; done++)); do printf "▇"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do printf " "; done }
    percentage() { printf "| %s%%" $(( (($elapsed)*100)/($duration)*100/100 )); }
    clean_line() { printf "\r"; }

  for (( elapsed=1; elapsed<=$duration; elapsed++ )); do
      already_done; remaining; percentage
      sleep 1
      clean_line
  done
  clean_line
}