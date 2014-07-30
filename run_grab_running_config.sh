#!/usr/bin/env bash

##
## Author: thesubtlety
## Usage:  ./run_grab_running_config  device_list.txt
## 
## This script calls the expect script "grab_running_config.exp", uses your
## current logged in username and asks for your password. It then uses those 
## credentials to log into each device and does a show run. That output 
## is logged into a file named <device_name>-<date>.txt
## Errors are output to error_log-<date>.txt
##

USAGE="Usage: ${0} device_list.txt"
PASSWORD=""
DATE=$(date "+%Y-%m-%d")
FULL_DATE=$(date)
EXPECT_SCRIPT_NAME="grab_running_config.exp"

if [ "$#" != "1" ]; then
	echo "$USAGE"
	exit 1
fi

if [ ! -e "$EXPECT_SCRIPT_NAME" ]; then
	echo "Missing expect script: "$EXPECT_SCRIPT_NAME". Exiting\n"
	exit 1
fi

if [ -e "$1" ]; then
	echo -n "Enter SSH password for $(whoami): "
	read -s -e PASSWORD
	echo -ne "\n"
else
	echo "Filename "$1" does not exist"
	exit 1
fi

for wlc in $(cat $1); do 
	echo -ne "\n======================$wlc=======================\n"
 	./$EXPECT_SCRIPT_NAME $wlc $PASSWORD $DATE
 	
 	# If expect is given an incorrect password, it returns error code 3,
 	# causing the script to immediately exit so as not to lockout an account.
 	exit_status=$?
	if [ $exit_status -eq 3 ]; then
		exit 1;
	fi
done

