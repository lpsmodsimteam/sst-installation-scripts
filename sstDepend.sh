#!/bin/bash

# This script will install SST Dependencies

Kernel=$(uname -s)
if [[ $Kernel == "Linux" ]]; then
	OS=$(cat /etc/*-release | grep "^ID=" | tr -d '"' | tr -d 'ID=')
	version=$(cat /etc/*-release | grep "^VERSION_ID=" | tr -d '"' | tr -d 'VERSION_ID=')
	
	if [[ "${OS,,}" == "ubuntu" ]]; then
		
		if (( $(echo $version | cut -d'.' -f1) >= 16 )); then
			sudo apt update
			sudo apt upgrade -y
			sudo apt install -y build-essential git libtool-bin automake python-dev mpi-default-dev python3-pyqt5 graphviz python3-pip
			sudo pip3 install --upgrade python-gitlab
		
		else
			echo "Un-supported Ubuntu version <$version> ! Must be 16.04 or higher. EXITING"
			exit 1
		fi
	
	elif [[ "${OS,,}" == "centos" ]]; then
		
		if (( $version == 7 )); then
			sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
			sudo yum update -y
			sudo yum groupinstall -y "Development Tools"
			sudo yum install -y libtool-ltdl-devel python-devel openmpi-devel python36u-pip graphviz
			sudo pip3.6 install --upgrade pyqt5 python-gitlab
			sudo ln -s /usr/bin/python3.6 /usr/bin/python3
			echo "export PATH=\$PATH:/usr/lib64/openmpi/bin/" >> ~/.bashrc
		
		else
			echo "Un-supported Centos version <$version> ! EXITING"
			exit 1
		fi
	
	else
		echo "UNKNOWN OS <$OS> ! EXITING"
		exit 1
	fi

elif [[ $Kernel == "Darwin" ]]; then
	version=$(sw_vers -productVersion)
	
	if (( $(echo $version | cut -d'.' -f1) == 10 && $(echo $version | cut -d'.' -f2) >= 13 )); then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		brew update
		brew upgrade
		brew install automake libtool openmpi python3 graphviz pyqt5
		sudo pip3 install --upgrade python-gitlab
		
	else
		echo "Un-supported MacOS version <$version> ! Must be 10.13 or higher. EXITING"
		exit 1
	fi
	
else
	echo "UNKNOWN OS <$Kernel> ! EXITING"
	exit 1
fi

exit 0

