#!/bin/sh

###########################################################################
# This file can be used as the basis for preparing a script to install the
# FlexNet inventory agent on non-Windows platforms.
#
# Expected directory structure relative to this script:
#
# ./flexia-setup.sh: This script
# ./Solaris (x86)/*: Agent installation package files to be used on Solaris x86
# ./Solaris (sparc)/*: Agent installation package files to be used on Solaris SPARC
# ./Linux (i386)/*: Agent installation package files to be used on Linux (x86 32 bit)
# ./Linux (x86_64)/*: Agent installation package files to be used on Linux (x86 64 bit)
# ./AIX/*: Agent installation package files to be used on AIX
# ./HP-UX/*: Agent installation package files to be used on HP-UX
# ./Mac OS X/*: Agent installation package files to be used on Mac OS X
# ./UNIXConfig.ini: (Optional) Config file containing any specific configuration settings to be applied using with mgsconfig
# ./Bootstrap Failover Settings.osd: (Optional) Package containing failover settings for bootstraping the agent
# ./Bootstrap Machine Schedule.nds: (Optional) Schedule to be installed with the agent
#
# Usage to install the FlexNet inventory agent:
#
# $ ./flexia-setup.sh
#
# Before using this script, you may wish to review and modify the settings
# used for bootstrapping the agent configuration specified below where the
# mgsft_rollout_response file is generated.
#
# See the "FlexNet Inventory Agent and Managed Devices" document for more
# details about the agent installation process.
#
# Copyright (C) 2018-2016 Flexera Software
###########################################################################

BASEDIR=`dirname $0`


# Create a secure temporary directory
TMPDIR=/var/tmp/tempdir.$RANDOM.$RANDOM.$$
( umask 077 && mkdir $TMPDIR ) || {
	echo "ERROR: $0 could not create a temporary directory" 1>&2
	exit 1
}


# ----------------------------------------------------------------------
# ----- Bootstrap configuration details for all UNIX clients -----
cat << EOF > $TMPDIR/mgsft_rollout_response

# The initial download location(s) for the installation.
# For example, http://myhost.mydomain.com/ManageSoftDL/
# Refer to the documentation for further details.
#MGSFT_BOOTSTRAP_DOWNLOAD=http://beacon.mydomain.com:8080/ManageSoftDL/

# The initial reporting location(s) for the installation.
# For example, http://myhost.mydomain.com/ManageSoftRL/
# Refer to the documentation for further details.
#MGSFT_BOOTSTRAP_UPLOAD=http://beacon.mydomain.com:8080/ManageSoftRL/

# The initial proxy configuration. Uncomment these to enable proxy configuration.
# Note that setting values of NONE disables this feature.
#MGSFT_HTTP_PROXY=http://webproxy.local:3128
#MGSFT_HTTPS_PROXY=https://webproxy.local:3129
#MGSFT_PROXY=socks:socks.socksproxy.local:19121,direct
#MGSFT_NO_PROXY=internal1.local,internal2.local

# Check the HTTPS server certificate's existence, name, validity period,
# and issuance by a trusted certificate authority (CA). This is enabled
# by default and can be disabled with false.
#MGSFT_HTTPS_CHECKSERVERCERTIFICATE=true

# Check that the HTTPS server certificate has not been revoked. This is
# enabled by default and can be disabled with false.
#MGSFT_HTTPS_CHECKCERTIFICATEREVOCATION=true
EOF


# Set owner to install or nobody or readable by all so pre 8.2.0 Solaris
# clients checkinstall script can read it.
if [ "`uname -s`" = "SunOS" ]; then
	chown install $TMPDIR/mgsft_rollout_response 2>/dev/null \
	|| chown nobody $TMPDIR/mgsft_rollout_response 2>/dev/null \
	|| chmod a+r $TMPDIR/mgsft_rollout_response
fi


# Move response file from the secure directory to the fixed path
# expected by the installation
ret=0
mv -f $TMPDIR/mgsft_rollout_response /var/tmp/mgsft_rollout_response || ret=1
rm -rf $TMPDIR

if [ $ret -ne 0 ]; then
	echo "ERROR: $0 could not create mgsft_rollout_response answer file" 1>&2
	exit 1
fi


#----------------------------------------
# Do the agent installation
#----------------------------------------
echo "Installing the FlexNet inventory agent"

if [ "`uname -s`" = "SunOS" ]; then
	cat <<EOF >$TMP/admin.$$
mail=
instance=overwrite
partial=nocheck
runlevel=nocheck
idepend=nocheck
rdepend=nocheck
space=quit
setuid=nocheck
conflict=nocheck
action=nocheck
basedir=default
EOF

	if [ "`uname -p`" = "i386" ] || [ "`uname -p`" = "i586" ] || [ "`uname -p`" = "i686" ]; then
		( cd "$BASEDIR/Solaris (x86)" && /usr/sbin/pkgadd -n -a "$TMP/admin.$$" -r /dev/null -d managesoft-*.x86.pkg ManageSoft) || ret=1
	elif [ "`uname -p`" = "sparc" ]; then
		( cd "$BASEDIR/Solaris (sparc)" && /usr/sbin/pkgadd -n -a "$TMP/admin.$$" -r /dev/null -d managesoft-*.sparc.pkg ManageSoft) || ret=1
	fi

	rm -f $TMP/admin.$$

elif [ "`uname -s`" = "Linux" ] && ( [ "`uname -p`" = "i386" ] || [ "`uname -p`" = "i586" ] || [ "`uname -p`" = "i686" ] )
then
	( cd "$BASEDIR/Linux (i386)" && rpm --upgrade --oldpackage --verbose --hash managesoft-*.i386.rpm ) || ret=1

elif [ "`uname -s`" = "Linux" ] && [ "`uname -p`" = "x86_64" ]
then
	( cd "$BASEDIR/Linux (x86_64)" && rpm --upgrade --oldpackage --verbose --hash managesoft-*.x86_64.rpm ) || ret=1

elif [ "`uname -s`" = "AIX" ]
then
	( cd "$BASEDIR/AIX" && /usr/sbin/installp -aYFq -d managesoft.*.bff managesoft.rte) || ret=1

elif [ "`uname -s`" = "HP-UX" ]
then
	( cd "$BASEDIR/HP-UX" && /usr/sbin/swinstall -v -x mount_all_filesystems=false -x allow_downdate=true -s managesoft-*.depot managesoft) || ret=1

elif [ "`uname -s`" = "Darwin" ] 
then
        ( cd "$BASEDIR/Mac OS X" && /usr/sbin/installer -verbose -dumplog -pkg managesoft-*.pkg -target / ) || ret=1
fi


if [ $ret -ne 0 ]; then
	echo 1>&2
	echo "ERROR: Failed to install the FlexNet inventory agent" 1>&2
	exit 1
fi

#
# Installing CA certificate(s) file.
#
if [ -e $BASEDIR/cert.pem ] 
then
	SSLDIR="/var/opt/managesoft/etc/ssl"
	[ ! -d $SSLDIR ] && {
	  ( mkdir $SSLDIR ) || {
		echo "ERROR: $0 could not create the $SSLDIR directory" 1>&2
		exit 1
	  }
	}

	( cp -f $BASEDIR/cert.pem $SSLDIR ) || {
		echo "ERROR: $0 unable to copy the file $BASEDIR/cert.pem to $SSLDIR" 1>&2
		exit 1
	}
fi


if [ -f "$BASEDIR/UNIXConfig.ini" ]; then
	echo
	echo "Applying custom configuration from UNIXConfig.ini into config.ini"
	/opt/managesoft/bin/mgsconfig -i $BASEDIR/UNIXConfig.ini || {
		ret=1
		echo "ERROR: Failed to apply custom configuration settings" 1>&2
	}
fi

if [ -f "$BASEDIR/Static Failover Settings.osd" ]; then
	echo
	echo "Installing static failover settings"
	/opt/managesoft/bin/ndlaunch -r "file://`cd $BASEDIR && pwd`/Static Failover Settings.osd" -o PkgType=ClientSettings || {
		   ret=1
		   echo "ERROR: Failed to install static failover settings details (inspect /var/opt/managesoft/log/installation.log for details)" 1>&2
	}
fi

echo
echo "Updating failover settings"
/opt/managesoft/bin/ndlaunch -r '$(DownloadRootURL)/ClientSettings/Default%20Failover%20Settings/Default%20Failover%20Settings.osd' -o PkgType=ClientSettings || {
	echo "WARNING: Failed to update failover settings (inspect /var/opt/managesoft/log/installation.log for details); will rely on bootstrap schedule details to try again later" 1>&2
}

echo
echo "Generating and uploading inventory"
/opt/managesoft/bin/ndtrack -t Machine || {
	echo "WARNING: Failed to generate and upload inventory (inspect /var/opt/managesoft/log/tracker.log for details); a later attempt at generating inventory will be made according to schedule settings" 1>&2
}

if [ -f "$BASEDIR/Bootstrap Machine Schedule.nds" ]; then
	echo
	echo "Installing bootstrap schedule"
	/opt/managesoft/bin/ndschedag "$BASEDIR/Bootstrap Machine Schedule.nds" || {
		ret=1
		echo "ERROR: Failed to install bootstrap schedule (inspect /var/opt/managesoft/log/schedule.log for details)" 1>&2
	}
fi

echo
echo "Applying machine policy"
/opt/managesoft/bin/mgspolicy -t Machine || {
	echo "WARNING: Failed to apply machine policy (inspect /var/opt/managesoft/log/policy.log and installation.log for details); will rely on bootstrap schedule details to try again later" 1>&2
}

echo
test $ret -eq 0 && echo "FlexNet inventory agent installation completed successfully" || echo "FlexNet inventory agent installation FAILED" 1>&2

exit $ret
