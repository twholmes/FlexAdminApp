#!/bin/sh

###########################################################################
# Copyright (C) 2018-2016 Crayon Australia

# Usage to uninstall the FlexNet inventory agent:
#
# $ ./flexia-uninstall.sh <clean>
#
# This script will test for the existence of the "managesoft" RPM package
# and if it is installed it will execute the uninstall of it.
# If parameter 1 is provided and has the value "clean" then the script 
# will also remove all agent configuration and logs left behind after the
# uninstall.
###########################################################################

BASEDIR=`dirname $0`
ret=0

if [ "`uname -s`" = "Linux" ] && ( [ "`uname -p`" = "i386" ] || [ "`uname -p`" = "i586" ] || [ "`uname -p`" = "i686" ] )
then
	if rpm -q managesoft
	then	
		( rpm -e managesoft ) || ret=1
	else
		ret=1
	fi
elif [ "`uname -s`" = "Linux" ] && [ "`uname -p`" = "x86_64" ]
then
	if rpm -q managesoft
	then	
		( rpm -e managesoft ) || ret=1
	else
		ret=1
	fi
else
	echo "Unsupported platform (`uname -s` - `uname -p`) - uninstall script not yet developed for this platform"
fi

if [ $ret -ne 0 ]; then
	echo 1>&2
	echo "ERROR: Failed to install the FlexNet inventory agent" 1>&2
	exit 1
fi

if [ "$1" = "clean" ]; then 
	echo "Deleting all configuration and logs related to FNMS agents"
	rm -rf /var/opt/managesoft
fi



echo
test $ret -eq 0 && echo "FlexNet inventory agent uninstall completed successfully" || echo "FlexNet inventory agent uninstall FAILED" 1>&2

exit $ret



