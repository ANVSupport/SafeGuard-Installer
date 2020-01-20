#! /bin/bash
# s6NXKghuKb
# This is the main function of the Safeguard Installer..
# The PC has to have an ubuntu 18.04.1/2 installation with a user named "user"
# with 2 drives, 1 ssd and one HDD for storage
# Password has to be user1! or else second iteration will not be able to log itself in
# In that case, you can run second iteration manually from the repo folder...
# This script will delete the HDD, make sure you don't need ANYTHING
# Created By Gilad Ben-Nun

HOME_DIR=$(eval echo ~"$(logname)")
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
if [ "$EUID" -ne 0 ]; then
	echo "Please run this script as root"
	echo "Exiting..."
	exit 1
fi

command -v git >/dev/null 2>&1 ||
{ echo >&2 "Git is not installed. Installing..";
  apt install -y -qq git > /dev/null && echo "Git Installed"
}
source ${SCRIPTPATH}/SafeGuard-Assets/utilities.sh
mkdir "${HOME_DIR}"/docker-compose/
cp -r ${SCRIPTPATH}/SafeGuard-Assets/1.20.0 "${HOME_DIR}"/docker-compose/
rsync -av --progress "${SCRIPTPATH}"/SG.tar.gz /opt/ || echo "Failed to copy images, is the file SG.tar.gz present?" ; exit 1

if [[ ! -f "/opt/sg.f" ]]; then
	firstIteration "$1"
elif grep -q "1" /opt/sg.f; then
	echo "Second Iteration should have been run automatically upon startup"
	read -p "Do you wish to run it manually anyway? [Y/N]" -n 1 -r $yn1
	case "$yn1" in
		y|Y) bash /opt/secondIteration.sh && exit 0;;
		n|N) echo "Exiting..."; exit 0;;
		*) echo "Invalid choice, Exiting.."; exit 1;;
	esac
elif $(grep -q "2" /opt/sg.f) ; then
	echo "Script has been run fully already"
	read -p "Do you wish to clean this pc? [Y/N] ${red}(Warning! this will delete EVERYTHING)${white}" -n 1 -r $yn
	case "$yn" in
		y|Y) clean && exit 0;;
		n|N) echo "Not Cleaning..." ; echo "Exiting..."; exit 1;;
		*) echo "Invalid choice, Exiting.."; exit 1;;
	esac
fi