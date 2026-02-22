#!/bin/sh

###########################################################################
# This script can be used to remotely install the FlexNet inventory agent
# software on OS X, Linux, Solaris, AIX and HP-UX computers via SSH.
#
# Note that multiple SSH logons for each target computer are performed by
# this script. If SSH access requires passwords to be entered, be
# prepared to do lots of typing of passwords! The script will work
# best when you can connect to SSH without having to enter a password
# (e.g. with certificate authentication).
#
# The installation is done by executing the flexia-setup.sh script (which
# is associated with this script) using the sudo command on each
# target computer. The user is required to enter a password for
# invoking sudo at the start of the execution of this script.
#
#
# Usage examples:
#
# Install the FlexNet inventory agent on server1 and server2, logging on
# to server1 using the "root" account (rather than the current user):
#
# sh flexia-rollout.sh -t root@server1,server2
#
#
# Copyright (C) 2018 Flexera Software
###########################################################################


BASEDIR=`dirname $0`

TARGETS=

while getopts t: o
do
	case "$o" in
	t) 	TARGETS="$OPTARG" ;;
	[?])	echo "Usage: $0 -t <target1,target2,...>" 1>&2; exit 1 ;;
	esac
done


if [ -z "$TARGETS" ]; then
	echo "Error: Target computers to install on must be specified with the '-t' command line option" 1>&2
	exit 1
fi

IFS=, set -- $TARGETS

ret=0
for target in $@; do
	echo "****** Installing on $target ******"

	uname=`ssh $target uname -s -p`

	echo "OS of target computer is '$uname'"

	installer=
	case "$uname" in
	"SunOS i"*)
		installer="Solaris (x86)"
		;;
	"SunOS sparc")
		installer="Solaris (sparc)"
		;;
	"Linux i"*)
		installer="Linux (i386)"
		;;
	"Linux x86_64")
		installer="Linux (x86_64)"
		;;
	"AIX "*)
		installer="AIX"
		;;
	"HP-UX")
		installer="HP-UX"
		;;
	"Darwin")
		installer="Mac OS X"
		;;
	*)
		echo "ERROR: Unknown OS '$uname' on target $target" 1>&2
		ret=1
		;;
	esac

	if [ -n "$installer" ]; then
		echo "Extracting FlexNet inventory agent setup files" &&
		( cd $BASEDIR && tar -cf - flexia-setup.sh "Bootstrap Machine Schedule."* "Bootstrap Failover Settings."* UNIXConfig.ini "$installer" cert.pem) |
		ssh -C $target "
			mkdir /tmp/flexia-setup.$$ &&
			cd /tmp/flexia-setup.$$ &&
			tar xvf - &&
			chmod +rwx \"$installer\"
		" &&
		echo "Installing FlexNet inventory agent software" &&
		ssh -Ct $target "
			r=1

			echo \"cd /tmp/flexia-setup.$$ && sh ./flexia-setup.sh\" | sudo su - &&
			r=0

			cd /tmp && rm -rf flexia-setup.$$

			exit \$r
		" &&
		echo && echo "****** Installation on $target SUCCEEDED ******" ||
		{
			echo "****** Installation on $target FAILED ******" 1>&2
			ret=1
		}
	fi

	echo
done

exit $ret
