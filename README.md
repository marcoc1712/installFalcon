# Falcon Installer

The installer for squeezelite-R2 and falcon, the web interface to Squeezelite (R2).

Install and controll your squeezelite box from any browser in your network, even from your phone.

PLEASE SEE:

https://github.com/marcoc1712/falcon

 
https://github.com/marcoc1712/squeezelite-R2

and 

https://github.com/marcoc1712/C-3PO

for further informations.

DISCLAIMER:

This release was tested only for: Debian, Ubuntu and Gentoo, could be easily 
adapted for any other LINUX distribution with minimal effort.

Please contact me if interested in porting Falcon in your distro.

INSTALLATION GUIDE:

Please login to your system as root and download setup.pl

from here: https://raw.githubusercontent.com/marcoc1712/installFalcon/master/setup.pl

PLEASE COPY THE LINK, NOT THE DISPLAYED TEXT

i.e. 'wget https://raw.githubusercontent.com/marcoc1712/installFalcon/master/setup.pl';

Remember to chmod +x setup.pl

then run it 

./ setup.pl

use:

--remove to remove falcon instead of install it.

--clean  to remove and install from scratch.

--noinfo to reduce messages to minimum (no effects on OS and third party software messages).

--debug  to get some more verbose messages (try this before submit an error, and attach it please).

--git  installs and uses git client to download and install the code (safer for updates).

PLEASE NOTE: 

Will use Apache2 or Lighttpd if installed, else Lighttpd  will be installed and configured  for falcon.

At the end of the installation, if nothing went wrong, you should reach your squeezelite-R2 installation by any browser in your network at the ip address of your player (you could check it in OS or in Squeezebox server -> settings -> player).

--remove will remove everything related to falcon from your computer, but not git, the webserver and squeezelite. 

Users will remain untouched, same services but disabled, www folder and webserver configuration file are removed, so webserver could be started but remains unreacheable.

You'll may have to reconfigure your webserver and recreate the www directory if needed.

Please reports any bugs.

