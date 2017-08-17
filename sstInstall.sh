#!/bin/bash

echo -e "\nThis Script will install SST\n"
echo -e "Checking for Dependencies\n"

Kernel=$(uname -s)
DEPEND=true
prefix=/usr/bin

# Kernel Specific tests
if [[ $Kernel == "Linux" ]]; then
	OS=$(cat /etc/*-release | grep "^ID=" | tr -d '"' | tr -d 'ID=')
	version=$(cat /etc/*-release | grep "^VERSION_ID=" | tr -d '"' | tr -d 'VERSION_ID=')
	bashrc=~/.bashrc
	sed -i '/# BEGIN sstInstall.sh Environment Variables/,/# END sstInstall.sh Environment Variables/d' $bashrc
	
	# libtoolize test
	if test -f $prefix/libtoolize; then
		echo "libtoolize is installed ..."
	else
		echo "libtoolize is missing ..."
		DEPEND=false
	fi
	# libltdl test
	if test -d /usr/share/libtool/libltdl; then
		echo "Libtool is installed and configured properly ..."
	else
		echo "Libtool may be missing development packages ..."
		DEPEND=false
	fi
	# OpenMPI test
	if [[ "${OS,,}" == "ubuntu" ]]; then
		if test -f $prefix/ompi_info; then
			echo "OpenMPI is installed ..."
		else
			echo "OpenMPI is missing ..."
			DEPEND=false
		fi
	elif [[ "${OS,,}" == "centos" ]]; then
		if test -f /usr/lib64/openmpi/bin/ompi_info; then
			echo "OpenMPI is installed ..."
		else
			echo "OpenMPI is missing ..."
			DEPEND=false
		fi
	fi
	
elif [[ $Kernel == "Darwin" ]]; then
	prefix=/usr/local/bin
	version=$(sw_vers -productVersion)
	bashrc=~/.bash_profile
	sed -i '' '/# BEGIN sstInstall.sh Environment Variables/,/# END sstInstall.sh Environment Variables/d' $bashrc
	
	if (( $(hostname | wc -c) > 15 )); then
		echo -e "\n!!! Hostname can only be 14 characters on Mac !!!"
		INPUT=""
		while [[ -z "$INPUT" ]] || (( ${#INPUT} > 14 )); do
			read -p "Please enter a new hostname that is 14 characters or less >> " INPUT
		done
		sudo scutil --set HostName $INPUT
	fi
	
	if [[ $(xcodebuild -version 2>&1 | grep -i "error") != "" || $(xcodebuild -version 2>&1 | grep -i "note") != "" ]]; then
		echo -e "\n!!! Xcode Needs to be installed !!!"
		echo "If a window pops up please select 'Get Xcode'"
		echo "Please install Xcode from the App Store, then re-run this script"
		exit
	fi
	
	# glibtoolize test
	if test -f $prefix/glibtoolize;	then
		echo "glibtoolize is installed ..."
	else
		echo "glibtoolize is missing ..."
		DEPEND=false
	fi
	# OpenMPI test
	if test -f $prefix/ompi_info; then
		echo "OpenMPI is installed ..."
	else
		echo "OpenMPI is missing ..."
		DEPEND=false
	fi
	
else
	echo "UNKNOWN OS <$Kernel> ! EXITING"
	exit
fi

# gcc test
if test -f /usr/bin/gcc; then
	echo "gcc is installed ..."
else
	echo "gcc is missing ..."	
	DEPEND=false
fi
# g++ test
if test -f /usr/bin/g++; then
	echo "g++ is installed ..."
else
	echo "g++ is missing ..."
	DEPEND=false
fi
# git test
if test -f /usr/bin/git; then
	echo "git is installed ..."
else
	echo "git is missing ..."
	DEPEND=false
fi
# m4 test
if test -f /usr/bin/m4; then
	echo "m4 is installed ..."
else
	echo "m4 is missing ..."
	DEPEND=false
fi
# python-config test
if test -f /usr/bin/python-config; then
	echo "python-config is installed ..."
else
	echo "python-config is missing ..."
	DEPEND=false
fi
# autoconf test
if test -f $prefix/autoconf; then
	echo "autoconf is installed ..."
else
	echo "autoconf is missing ..."
	DEPEND=false
fi
# autoconf test
if test -f $prefix/automake; then
	echo "automake is installed ..."
else
	echo "automake is missing ..."
	DEPEND=false
fi
# python3 test
if test -f $prefix/python3; then
	echo "python3 is installed ..."
else
	echo "python3 is missing ..."
	DEPEND=false
fi
# graphviz test
if test -f $prefix/dot; then
	echo "graphviz is installed ..."
else
	echo "graphviz is missing ..."
	DEPEND=false
fi
# PyQt5 test
if [[ -z "$(python3 -c 'import PyQt5' 2>&1)" ]]; then
	echo "PyQt5 is installed ..."
else
	echo "PyQt5 is missing ..."
	DEPEND=false
fi



if $DEPEND; then
	echo -e "\nProceeding with SST Install\n"
else
	echo -e "\n!!! Missing Dependencies !!!"
	read -p "Do you want to install dependencies? [y/n DEFAULT is yes] NEED SUDO! >> " INPUT
	if [[ -n "$INPUT" || "$INPUT" == "y" || "$INPUT" == "Y" ]]; then
		echo -e "Attempting to install them now, running sstDepend.sh\n"
		./sstDepend.sh
		if (( $? != 0 )); then
			echo -e "\nInstalling Dependencies Failed! EXITING\n"
			exit 1
		fi
	else
		echo -e "Exiting\n"
	fi
fi



echo
read -p "Where do you want to install SST? Full path required [DEFAULT is ~/sst] >> " INPUT
if [ -n "$INPUT" ]; then
	dir=$INPUT
else
	dir=$HOME/sst
fi

source $bashrc
mkdir -p $dir/scratch
mkdir -p $dir/local

export SST_CORE_HOME=$dir/local/sst-core
export SST_ELEMENTS_HOME=$dir/local/sst-elements
export PATH=$PATH:$SST_CORE_HOME/bin:$SST_ELEMENTS_HOME/bin
echo "# BEGIN sstInstall.sh Environment Variables" >> $bashrc
echo "export SST_CORE_HOME=$dir/local/sst-core" >> $bashrc
echo "export SST_ELEMENTS_HOME=$dir/local/sst-elements" >> $bashrc
echo "export PATH=\$PATH:\$SST_CORE_HOME/bin:\$SST_ELEMENTS_HOME/bin" >> $bashrc
echo "# END sstInstall.sh Environment Variables" >> $bashrc

echo "Building sst-core from github"
git clone https://github.com/sstsimulator/sst-core.git $dir/scratch/sst-core
cd $dir/scratch/sst-core
./autogen.sh
echo "./configure --prefix=$SST_CORE_HOME"
./configure --prefix=$SST_CORE_HOME
make all install
cd

echo "Building sst-elements from github"
git clone https://github.com/sstsimulator/sst-elements.git $dir/scratch/sst-elements
cd $dir/scratch/sst-elements
./autogen.sh
echo "./configure --prefix=$SST_ELEMENTS_HOME --with-sst-core=$SST_CORE_HOME $@"
./configure --prefix=$SST_ELEMENTS_HOME --with-sst-core=$SST_CORE_HOME "$@"
make all install
cd

if test -x $SST_CORE_HOME/bin/sst; then
	echo "*****SST INSTALLATION WAS SUCCESSFUL*****"
	echo "Your ~/.bashrc(Linux) or ~/.bash_profile(Mac) has been updated"
	echo "with the correct environment variables including PATH variable"
	echo "Please source your ~/.bashrc(Linux) or ~/.bash_profile(Mac) now"
else
	echo "*****SST INSTALLATION WAS UNSUCCESSFUL*****"
	echo "Cleaning up directories ..."
	rm -rf $dir
	echo "Cleaning up ~/.bashrc(Linux) or ~/.bash_profile(Mac) ..."
	if [[ $Kernel == "Linux" ]]; then
		sed -i '/# BEGIN sstInstall.sh Environment Variables/,/# END sstInstall.sh Environment Variables/d' ~/.bashrc
	elif [[ $Kernel == "Darwin" ]]; then
		sed -i '' '/# BEGIN sstInstall.sh Environment Variables/,/# END sstInstall.sh Environment Variables/d' $bashrc
	fi
fi

