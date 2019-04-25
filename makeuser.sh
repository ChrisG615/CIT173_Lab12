#!/bin/bash

DEFAULT_PASSWORD=toor

function showHelp() {
	echo "USAGE: Make [username] [login name]"
}

function checkStatus() {
	if [ $? -ne 0 ]; then
		echo "ERROR: $1"
		exit 1
	fi
}

# check for root
if [ $EUID -ne 0 ]; then
	echo "You must run as root"
	exit 1
fi

# check to make sure the approprate number of arguements are present
if [ $# -lt 2 ] || [ $# -gt 2 ]; then
	showHelp
	echo "ERROR: Invalid number of arguments"
	echo "You must enter only two arguments."
	echo "ARG 1 = username (all lowercase and one word)"
	echo "ARG 2 = login name (enclose in double quotes if conatins a space"
	exit 1
fi

# set helper variables
Username=$1
Loginname=$2
Groupname=${Username}-group

# create a new user group for the user

groupadd $Groupname
checkStatus "Failed to create new group for user $Username"


# create new user
useradd -d /home/$Username -g $Groupname -c $Loginname $Username
checkStatus "Failed to create new user $Username"

echo "New user $Username created and added to new group $Groupname"
sleep 2s

# set default password for the new user
# this will be foced to be changed at initial loggin
echo $DEFAULT_PASSWORD | passwd --stdin $Username
checkStatus "Failed to set default password for new user $Username"

# force a new password at login for the new user
passwd -e $Username

echo "Default password set for user $Username; user must update password upon initial login"
sleep 2s

# create new user bash_profile
if [ -f /ect/profile ]; then
	cp /etc/profile /home/$Username/.bash_profile
else
	touch /home/$Username/.bash_profile
fi
echo "bash_profile created for new user $Username"
sleep 2s

# create new user bashrc file
if [ -f /etc/bashrc ]; then
	cp /etc/bashrc /home/$Username/.bashrc
else
	touch /home/$Username/.bashrc
fi
echo "bashrc file created for new user $Username"
sleep 2s

# Set the ownership of the new user home directory
chown $Username:$Groupname -R /home/$Username
echo "Ownership for new user $Username has been set"
stat -c "%U %G" /home/$Username
sleep 2s

echo "User creation complete for user $Username"

