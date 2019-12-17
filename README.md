# SafeGuard-Installer
This is a SafeGuard Installer written by Gilad Ben-Nun.
Pre-requisits: 

-A Machine with a clean installation of Ubuntu 18.04.1/2
-SSD as boot drive
-HDD to be used as storage drive (Will be deleted completly)

***Please Note: This Script will delete the HDD, do not have important data on the machine! ***

### here to get the Token
In AnVision's Jenkins theres a job called "docker_registery_generate_token"
when it complete copy the "Password" as the token
example Token:
> "ya29.c.KmO1B76DZSu7vn0jTngVJuOfRVrG7yDwO1sqpC5FKusU1CyJgO1Gg2H_k2TYziPwrfsQlGJxZ04aaSlaVtENLU7z-M-ULlDIteWTbKLJk07aAgbiMUOsqPuk4l3_l-FwC1dpkn0"
![Build Token](https://i.ibb.co/BqwSjMV/docker-registery-genereate-token.png)
![Example output](https://i.ibb.co/WGQYjq5/Token.png)
### Run The Script
Run this as root with the generated token (lasts for 1 hour)

```bash
wget -qO- https://raw.githubusercontent.com/ANVSupport/SafeGuard-Installer/master/main.sh | bash -s -- <TOKEN>
```

### Errors:
If after the reboot A terminal window doesnt open and run the second part of the script, There is a script on the desktop to run that will continue deployment (DO NOT RUN AS ROOT).