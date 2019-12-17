# SafeGuard-Installer
This is an automatic SafeGuard Installer written by Gilad Ben-Nun.    
This script uses the [compose-oneliner](https://github.com/anyvisionltd/compose-oneliner) by Ori Ben-Hur

Pre-requisits: 

- A Machine with a clean installation of Ubuntu 18.04.1/2
- SSD as boot drive
- HDD to be used as storage drive (Will be deleted completly)

<span style="color:red">**Please Note: This Script will delete the HDD, do not run this if you have important data on the machine!**</span>

## Run The Script
1. Run this as root with the generated token (lasts for 1 hour)

```shellscript
	wget -qO- https://raw.githubusercontent.com/ANVSupport/SafeGuard-Installer/master/main.sh | bash -s -- <TOKEN>
```
2. The machine will reboot, and when prompted with the login screen, login to Ubuntu.    
A terminal Window should pop up and continue the second half. If it doesn't, Please refer to the Known Issues section.

3. Launch the SafeGuard Application and change the Logo (with the Password)

_Please Note: More Info can be found at the [SafeGuard Installation Confluence Page](https://anyvision.atlassian.net/wiki/spaces/INTEGRATION/pages/858030101/SafeGuard+installation) Since it's sensitive information_

<br></br>

### How Do I Get A Token?
In AnVision's Jenkins theres a job called "docker\_registery\_generate\_token"
when it complete copy the "Password" as the token
example Token:

> "ya29.c.KmO1B76DZSu7vn0jTngVJuOfRVrG7yDwO1sqpC5FKusU1CyJgO1Gg2H_k2TYziPwrfsQlGJxZ04aaSlaVtENLU7z-M-ULlDIteWTbKLJk07aAgbiMUOsqPuk4l3_l-FwC1dpkn0"

![Build Token Button](https://i.ibb.co/BqwSjMV/docker-registery-genereate-token.png)

![Example output](https://i.ibb.co/WGQYjq5/Token.png)


### Known Issues:

- If after the reboot A terminal window doesnt open and run the second part of the script, There is a script on the desktop to run that will continue deployment (**Must be run as root**).

- The script failed due to dpkg being locked:
Run the Following Commands after closing any update center windows and finishing other apt-get commands::
```shellscript
  sudo rm /var/lib/dpkg/lock
  sudo rm /var/lib/apt/lists/lock
  sudo rm /var/cache/apt/archives/lock
  sudo rm /var/lib/dpkg/lock
  sudo dpkg --configure -a
```
Then Run the script again