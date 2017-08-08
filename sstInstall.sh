#!/bin/bash

# This script will install SST

VERSION=7.1

echo "This Script will install SST Version $VERSION ..."
echo " "
echo "Let us set up the environment first ..."
echo " "
DEPEND=TRUE
if test -f /usr/bin/libtoolize;
then
   echo "libtoolize is installed ..... "
else
   echo "libtoolize is missing ...."
   echo "Please install libtoolize...."
   echo "CENTOS: sudo yum install libtool-bin" # Need to check CENTOS 
   echo "UBUNTU: sudo apt install libtool-bin"
   DEPEND=FALSE
fi
if test -d /usr/share/libtool/libltdl;
then
   echo "Libtool is installed and configured properly ...."
else
   echo "Libtool may be missing development packages ..."
   echo "Suggest the following....."
   echo "For CENTOS:"
   echo "sudo yum install libtool-ltdl-devel.x86_64"
   echo "or"
   echo "For UBUNTU"
   echo "sudo apt install libltdl-dev"
   echo " "
   DEPEND=FALSE
fi

if test -d /usr/share/libtool/libltdl;
then
   echo "Libtool is installed and configured properly ...."
else
   echo "Libtool may be missing development packages ..."
   echo "Suggest the following....."
   echo "For CENTOS:"
   echo "sudo yum install libtool-ltdl-devel.x86_64"
   echo "or"
   echo "For UBUNTU"
   echo "sudo apt install libltdl-dev"
   echo " "
   DEPEND=FALSE
fi

if test -f /usr/bin/git;
then
   echo "git is installed ..... "
else
   echo "git is missing ......"
   echo "Please install git...."
   echo "CENTOS: sudo yum install git"
   echo "UBUNTU: sudo apt install git"
   DEPEND=FALSE
fi

if test -f /usr/bin/gcc;
then
   echo "gcc is installed ..... "
else
   echo "gcc is missing ...."
   echo "Please install gcc...."
   echo "CENTOS: sudo yum install gcc"
   echo "UBUNTU: sudo apt install build-essential"
   DEPEND=FALSE
fi

if test -f /usr/bin/g++;
then
   echo "g++ is installed ..... "
else
   echo "g++ is missing ...."
   echo "Please install gcc...."
   echo "CENTOS: sudo yum install g++"
   echo "UBUNTU: sudo apt install g++"
   DEPEND=FALSE
fi

if [ $DEPEND == TRUE ]
then
   echo "Proceeding with SST Install......"
   echo " "
else
   echo "One or more dependencies are missing...."
   echo "Please follow the suggestions given above for missing dependencies....."
   exit
fi
# Request User input

echo -n "Where do you want to Download SST? [$HOME/scratch]>>"

read INPUT

if [ -n "$INPUT" ];then
    DOWNLOAD=$INPUT
    INPUT=""
else
    DOWNLOAD=$HOME/scratch
fi

echo -n "Where do you want to Install SST? [$HOME/local]>>"

read INPUT

if [ -n "$INPUT" ];then
    INSTALL=$INPUT
    INPUT=""
else
    INSTALL=$HOME/local
fi

echo -n "Do you want to install OpenMPI 1.8.8 (Highly Recommended) [Y]>>"

read INPUT

if [ -n "$INPUT" ];then
    MPIFLAG=$INPUT
else
    MPIFLAG=Y
fi

if [ $MPIFLAG == N ] ||[ $MPIFLAG == n ] || [ $MPIFLAG == No ] || [ $MPIFLAG == no ] || [ $MPIFLAG == NO ];then
   echo " "
   echo "With OpenMPI disabled you will be unable to run multi-node simulations"
fi

# Create Directories

echo " "
echo "Creating directory structure ....."
echo " "


mkdir $DOWNLOAD
mkdir $DOWNLOAD/src
mkdir $INSTALL
mkdir $INSTALL/packages

# Setup appropriate environment variables, and update .bashrc 

echo "Setting up environment variables in .bashrc ......"
echo " ">>$HOME/.bashrc
echo "# Below are the environment variables created by the SST install">>$HOME/.bashrc
echo " ">>$HOME/.bashrc
echo "export MPICC=mpicc">>$HOME/.bashrc
export MPICC=mpicc
echo "export MPICXX=mpicxx">>$HOME/.bashrc
export MPICXX=mpicxx
echo " ">>$HOME/.bashrc
if [ $MPIFLAG == Y ] ||[ $MPIFLAG == y ] || [ $MPIFLAG == Yes ] || [ $MPIFLAG == yes ] || [ $MPIFLAG == YES ];then
   echo " "
   echo "export MPIHOME=$INSTALL/packages/OpenMPI-1.8.8">>$HOME/.bashrc
   export MPIHOME=$INSTALL/packages/OpenMPI-1.8.8
   echo "export PATH=\$MPIHOME/bin:\$PATH">>$HOME/.bashrc
   export PATH=$MPIHOME/bin:$PATH
   echo "export LD_LIBRARY_PATH=\$MPIHOME/lib:\$LD_LIBRARY_PATH">>$HOME/.bashrc
   export LD_LIBRARY_PATH=$MPIHOME/lib:$LD_LIBRARY_PATH
   echo "export DYLD_LIBRARY_PATH=\$MPIHOME/lib:\$DYLD_LIBRARY_PATH">>$HOME/.bashrc
   export DYLD_LIBRARY_PATH=$MPIHOME/lib:$DYLD_LIBRARY_PATH
   echo "export MANPATH=\$MPIHOME/share/man:\$DYLD_LIBRARY_PATH">>$HOME/.bashrc
   export MANPATH=$MPIHOME/share/man:$DYLD_LIBRARY_PATH
   echo " ">>$HOME/.bashrc
fi
echo "export SST_CORE_HOME=$INSTALL/sstcore">>$HOME/.bashrc
export SST_CORE_HOME=$INSTALL/sstcore
echo "export PATH=\$SST_CORE_HOME/bin:\$PATH">>$HOME/.bashrc
export PATH=$SST_CORE_HOME/bin:$PATH
echo "export SST_ELEMENTS_HOME=$INSTALL/sstelements">>$HOME/.bashrc
export SST_ELEMENTS_HOME=$INSTALL/sstelements
echo "export PATH=\$SST_ELEMENTS_HOME/bin:\$PATH">>$HOME/.bashrc
export PATH=$SST_ELEMENTS_HOME/bin:$PATH


# Install OpenMPI

if [ $MPIFLAG == Y ] ||[ $MPIFLAG == y ] || [ $MPIFLAG == Yes ] || [ $MPIFLAG == yes ] || [ $MPIFLAG == YES ];then
   echo "Installing OpenMPI 1.8.8 ....."
   echo " "
   cd $DOWNLOAD/src
   wget https://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.8.tar.gz
   tar xfz openmpi-1.8.8.tar.gz
   cd openmpi-1.8.8
   ./configure --prefix=$MPIHOME
   make all install
   cd
fi

# Install SST Core

echo "Installing SST $VERSION Core ...."
echo " "
cd $DOWNLOAD/src
git clone -b master https://github.com/sstsimulator/sst-core.git
cd sst-core
./autogen.sh
if [ $MPIFLAG == Y ] ||[ $MPIFLAG == y ] || [ $MPIFLAG == Yes ] || [ $MPIFLAG == yes ] || [ $MPIFLAG == YES ];then
   ./configure --prefix=$SST_CORE_HOME 
else
   ./configure --prefix=$SST_CORE_HOME --disable-mpi
fi
make all install

# Install SST Elements

echo "Installing SST $Version Elements ...."
echo " "
cd $DOWNLOAD/src
git clone -b master https://github.com/sstsimulator/sst-elements.git
cd sst-elements
./autogen.sh
./configure --prefix=$SST_ELEMENTS_HOME --with-sst-core=$SST_CORE_HOME
make all install

if test -x "$SST_CORE_HOME/bin/sst" 
then
   echo "*****SST INSTALLATION WAS SUCCESSFUL*****"
else
   echo "*****SST INSTALLATION WAS UNSUCCESSFUL*****"
   echo "Cleaning up directories ...."
   echo " "
   rm -rf $DOWNLOAD
   rm -rf $INSTALL
   echo "Cleaning up .bashrc ....."
   sed -i "$(($(wc -l < ~/.bashrc)-14)),\$d" ~/.bashrc
fi

