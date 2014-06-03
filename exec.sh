#################################################################################
#										#
#			OpenWRT Auto-Builder					#
#			Written by: LostFate					#
#			Tested on:						#
#				Debian 7.5 (LostFate)				#
#										#
#################################################################################

#!/bin/bash
#
#################################################################################
#				Constants					#
#################################################################################
DEBIAN_DEPENDENCIES=(git-core subversion build-essential asciidoc bash bc binutils bzip2 fastjar flex g++ gcc util-linux gawk libgtk2.0-dev intltool zlib1g-dev make genisoimage libncurses5-dev libssl-dev patch perl-modules python2.6-dev rsync ruby sdcc unzip wget gettext xsltproc zlib1g-dev libboost1.49-dev libxml-parser-perl libusb-dev bin86 bcc sharutils openjdk-7-jdk b43-fwcutter icedtea-7-jre-jamvm)
OPENSUSE_DEPENDENCIES=
FEDORA_DEPENDENCIES=
CENTOS_DEPENDENCIES=
UBUNTU_DEPENDENCIES=

#################################################################################
#			System Variables					#
#################################################################################
#Flag that indicates whether the script actually does any work or
#not.
#(0 = Disabled)
#(1 = Enabled)
#(Default: 0)
DEBUG=1

#SYS_CORES reads from the /proc/cpuinfo file to total up all
#processor cores. (Will total cores on multi-socket configurations)
SYS_CORES=$(cat /proc/cpuinfo | grep 'processor' | wc -l)

#Current user.
USERNAME=$(id -un)

#Tries to find out if the user is a sudoer.
CAN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)

#Do we have the git repo setup in the build dir?
HAVE_SOURCE=

#Reads OS Distribution title. Used for installing dependencies and
#for paths.
OS_DISTRIB=$(lsb_release -a | grep "Distributor ID" | awk '{print $3}')

#################################################################################
#				User Variables					#
#################################################################################
#Working directory for source files  and the compiler.
BUILD_DIR="/home/"$USERNAME"/Desktop/build/openwrt/"

#Path to project folders.
GIT_PATH="/home/"$USERNAME"/Desktop/build/"

#Location to save the output files.
OUTPUT_DIR="/home/"$USERNAME"/Desktop/OpenWrt"

#Number of threads to create if the user chooses to complie using
#multi-core.
JOB_THREADS=$((SYS_CORES + 1))

#Take advantage of multi-core CPU's while building. *MAY CAUSE
#BUILD TO FAIL*
#(0 = Disabled)
#(1 = Enabled)
#(Default: 1)
PARALLEL_BUILD=1

#################################################################################
#                         Functions                              		#
#################################################################################
#
getSYS_CORES()
	{
		SYS_CORES=$(cat /proc/cpuinfo | grep 'processor' | wc -l)
	}

debugOUTPUT()
	{
		echo ""OS_DISTRIB = " $OS_DISTRIB"
		echo ""DEBIAN_DEPENDENCIES = " ${DEBIAN_DEPENDENCIES[*]}"
		echo ""HAVE_SOURCE = " $HAVE_SOURCE"
		echo ""USER = " $USERNAME"
		echo ""CAN_SUDO = " $CAN_SUDO"
		echo ""PARALLEL_BUILD = " $PARALLEL_BUILD"
		echo ""SYS_CORES = " $SYS_CORES"
		echo ""JOB_THREADS = " $JOB_THREADS"
		echo ""GIT_PATH = " $GIT_PATH"
		echo ""BUILD_DIR = " $BUILD_DIR"
		echo ""OUTPUT_DIR = " $OUTPUT_DIR";

	}

main()
	{
		update
		installDEPENDENCIES
		if [ "$HAVE_SOURCE" = "1" ]
			then
				gitUPDATE
			else
				gitINITAL
		fi
		$BUILD_DIR/scripts/feeds update -a
		$BUILD_DIR/scripts/feeds install -a
		make prereq
		make -j $JOB_THREADS
		filename=`date '+%Y%m%d'`
		cp -f $BUILD_DIR/bin/ar71xx/openwrt-ar71xx-generic-wndr3700-squashfs-sysupgrade.bin $OUTPUT_DIR/OpenWRT-WNDR3700-SFS-${filename}.bin
	}

addSUDOER()
	{
		echo "Attempting to add user to sudoers."
		echo "This will require temporary su access."
		echo "Do you wish to continue?"
		if [  ];
			then
				su
				echo ''$USERNAME' ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
				exit
				echo "This change requires you to log out."
				echo "When you log back in, rerun the script."
				echo "Would you like to log off now?"
				if [  ];
					then
						logout
					else
						echo "This script cannot continue until user logs back in."
						echo "Exiting script..."
						exit
						pause
				fi
			else
				echo "Cannot add user to sudoer file."
				echo "Please manually add user to sudoer file."
				exit
				pause
		fi

	}

getCAN_SUDO()
	{
		if [ "$CAN_SUDO" = "0" ];
			then
				addSUDOER
			else
				main
		fi
	}

installDEPENDENCIES()
	{
		sudo apt-get install -y ${DEBIAN_DEPENDENCIES[*]}
	}

update()
	{
		sudo apt-get update -y
	}

getOS()
	{
		lsb_release -a | grep "Distributor ID" | awk '{print $3}'
	}

selectOS()
	{
		if [ "$OS_DISTRIBUTION" = "Debian" ];
		then
			:
		elif [ "$OS_DISTRIBUTION" = "Red Hat" ];
		then
			:
		elif [ "$OS_DISTRIBUTION" = "Fedora" ];
		then
			:
		elif [ "$OS_DISTRIBUTION" = "CentOS" ];
		then
			:
		else
			:
		fi

	}

gitINITIAL()
	{
		git clone git://git.openwrt.org/openwrt.git
	}

gitUPDATE()
	{
		git pull
	}

checkSOURCE()
	{
	:
	}


#################################################################################
#                         	Main Program                           		#
#################################################################################

if [ "$DEBUG" = "1" ];
	then
		debugOUTPUT
	else
		main
fi
