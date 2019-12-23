#! /bin/bash

#This is the second Iteration of the SafeGuard Installation Script.
# Meant to be run automatically on startup after the first part has rebooted.
# Written By Gilad Ben-Nun

export printCyan=$'\e[1;36m'
export printWhite=$'\e[0m'
export printRed=$'\e[1;31m'
export printGreen=$'\e[1;32m'
export HOME_DIR
HOME_DIR=$(eval echo ~"$(logname)")
SecondIteration(){
	dockerfile=/home/user/docker-compose/1.20.0/docker-compose.yml
	echo "Dockerfile set as:"
	echo ${dockerfile}
	local isMoxaInBroadcaster
	isMoxaInBroadcaster=$( < ${HOME_DIR}/docker-compose/1.20.0/env/broadcaster.env grep -c "/moxa_e1214.sh")
	##check if script has been run before, to not add duplicates
	if [ "$isMoxaInBroadcaster" -eq 0 ]; then
		tee -a /home/user/docker-compose/1.20.0/env/broadcaster.env <<'EOF'
		## Modbus plugin integration
		BCAST_MODBUS_IS_ENABLED=true
		BCAST_MODBUS_CMD_PATH=/home/user/moxa-config/moxa_e1214.sh
		BCAST_MODBUS_CAMERA_LIST_PATH=/home/user/moxa-config/cameraList.json
EOF
	else
		echo "It seems the script has been run already, skipping broadcaster edits..."
	fi
	##doesnt hurt to run again since it's replacing not appending.
	host=$(hostname)
	local isMoxaInYaml
	isMoxaInYaml=$( < "${HOME_DIR}"/docker-compose/1.20.0/docker-compose.yml grep -c "moxa-config")
	if ["${isMoxaInYaml}" -eq 0]; then
		line=$(grep -nF broadcaster.tls.ai {HOME_DIR}/docker-compose/1.20.0/docker-compose.yml  | awk -F: '{print $1}') ; line=$((line+2))
		sed -i "${line}i \      - \/home\/user\/moxa-config:\/home\/user\/moxa-config" ${dockerfile}
	else
		echo "${printRed}""Moxa Edit already in Yml, skipping...""${printWhite}"
	fi

	sed -i "s|nginx-\${node_name:-localnode}.tls.ai|nginx-$host.tls.ai|g" ${dockerfile}
	sed -i "s|api.tls.ai|api-$host.tls.ai|g" ${dockerfile} && SuccesfulPrint "Modify docker files"
	cd /home/user/docker-compose/1.20.0/ || exit 1
	if docker-compose -f docker-compose-local-gpu.yml up -d ; then
		SuccesfulPrint "Image pull"
	else
		echo FailedPrint "docker-compose image pull"
		echo "Images failed to pull, Perhaps the token timed out?"
		echo "${printRed}""Generate a new token and login manually, then run runThisAsRoot.sh from the desktop""${printWhite}"
		exit 1
	fi

	sleep 10
	footprint=$(docker exec -it "$(docker ps | grep backend | awk '{print $1}')" license-ver -o)
	echo "Footprint: ""${printCyan}""${footprint}""${printWhite}"
	echo "2" > /opt/sg.f && SuccesfulPrint "Remove flag" ##marks second iteration has happened
	rm -f "${HOME_DIR}"/.config/autostart/secondIteration.desktop && SuccesfulPrint "Remove Startup"
	rm "${HOME_DIR}"/Desktop/runThisAsRoot.sh
	cat << "EOF"
	 _____   ____  _   _ ______ 
	|  __ \ / __ \| \ | |  ____|
	| |  | | |  | |  \| | |__   
	| |  | | |  | | . ` |  __|  
	| |__| | |__| | |\  | |____ 
	|_____/ \____/|_| \_|______|

EOF
exit 0
}

SuccesfulPrint(){
	echo -e "=================================================================="
	echo -e "                    $1 ....${printGreen}Success${printWhite}                  "
	echo -e "=================================================================="
}

FailedPrint(){
	echo -e "=================================================================="
	echo -e "                    $1 ....${printRed}Failed!${printWhite}                  "
	echo -e "=================================================================="
}
if [ "$EUID" -ne 0 ]; then
	echo "Could not obtain root access.."
	echo "Is your password set correctly?"
	echo "Please change your password and run the script manually"
	echo "${printCyan}""${HOME_DIR}""/SafeGuard-Installer/SafeGuard-Assets/SecondIteration.sh""${printWhite}"
	echo "Exiting..."
	exit 1
fi
if [[ -f "/home/user/docker-compose/1.20.0/docker-compose.yml" ]]; then
		SecondIteration && exit 0
else
	echo "App not installed, please Install it and try again"
	echo "Exiting..."
	exit 1
fi
