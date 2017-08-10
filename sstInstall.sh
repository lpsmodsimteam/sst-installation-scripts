#!/bin/bash

# This script will install SST

VERSION=7.1

OS=$(cat /etc/*-release | grep "^ID=" | tr -d '"' | tr -d 'ID=')

echo "This Script will install SST Version $VERSION ..."
echo " "
echo "Let us set up the environment first ..."
echo " "

# Check Known Dependencies from Clean Install Tests

DEPEND=true
gcctest=true
gpptest=true
libtoolizetest=true
libltdltest=true
gittest=true
m4test=true
autoconftest=true
pythontest=true
wgettest=true
graphviztest=true
python3test=true

if test -f /usr/bin/gcc;
then
   echo "gcc is installed ..... "
else
   echo "gcc is missing ...."   
   DEPEND=false
   gcctest=false
fi

if test -f /usr/bin/g++;
then
   echo "g++ is installed ..... "
else
   echo "g++ is missing ...."
   gpptest=false
   DEPEND=false
fi

if test -f /usr/bin/libtoolize;
then
   echo "libtoolize is installed ..... "
else
   echo "libtoolize is missing ...."
   DEPEND=false
   libtoolizetest=false
fi

if test -d /usr/share/libtool/libltdl;
then
   echo "Libtool is installed and configured properly ...."
else
   echo "Libtool may be missing development packages ..."
   DEPEND=false
   libltdltest=false
fi

if test -f /usr/bin/git;
then
   echo "git is installed ..... "
else
   echo "git is missing ......"
   DEPEND=false
   gittest=false
fi

if test -f /usr/bin/m4;
then
   echo "m4 is installed ..... "
else
   echo "m4 is missing ...."
   DEPEND=false
   m4test=false
fi

if test -f /usr/bin/autoconf;
then
   echo "auto tools are installed ..... "
else
   echo "auto tools are missing ...."
   DEPEND=false
   autoconftest=false
fi

if test -f /usr/bin/python-config;
then
   echo "python-config is installed ..... "
else
   echo "python-config is missing ...."
   DEPEND=false
   pythontest=false
fi

if test -f /usr/bin/python3;
then
   echo "python3 is installed ..... "
else
   echo "python3 is missing ...."
   DEPEND=false
   python3test=false
fi

if test -f /usr/bin/wget;
then
   echo "wget is installed ..... "
else
   echo "wget is missing ...."
   DEPEND=false
   wgettest=false
fi

if test -f /usr/bin/dot;
then
   echo "graphviz is installed ..... "
else
   echo "graphviz is missing ...."
   DEPEND=false
   graphviztest=false
fi
   
if [ $DEPEND == true  ]
then
   echo "Proceeding with SST Install......"
   echo " "
else
if [ $OS == centos ]
   then
      if [ $gcctest == false ] || [ $gpptest == false ] || [ $m4test == false ] || [ $autoconftest == false ] || [ $libtoolizetest == false ] 
      then
         echo "Try running sudo yum group install \"Development Tools\""
         echo " "
      fi
      if [ $pythontest == false ]
      then
         echo "Try running sudo yum install python-devel"
         echo " "
      fi
      if [ $python3test == false ]
      then
         echo "Try running:"
         echo "sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm"
         echo "sudo yum -y install python36u"
         echo "This will install python3.6...."
         echo "sudo yum -y install python36u-pip"
         echo "This will install python36u-pip....."
         echo "sudo pip3.6 install pyqt5"
         echo "This will install pyqt5...."
         echo "sudo ln -s /usr/bin/python3.6 /usr/bin/python3"
         echo "This will create a logical link to python3 ......"         
      fi

      if [ $libltdltest == false ]
      then
         echo "Try running sudo yum install libtool-ltdl-devel.x86_64"
         echo " "
      fi
      if [ $wgettest == false ]
      then
         echo "Try running sudo yum install wget"
         echo " "
      fi
      if [ $graphviztest == false ]
      then
         echo "Try running sudo yum install graphviz"
         echo " "
      fi
exit
fi
   if [ $OS == ubuntu ]
   then
      if [ $gcctest == false ] || [ $gpptest == false ] 
      then
         echo "Try running sudo apt install build-essential"
         echo " "
      fi
      if [ $m4test == false ]
      then
         echo "Try running sudo apt install m4"
         echo " "
      fi
      if [ $pythontest == false ]
      then
         echo "Try running sudo apt install python-dev"
         echo " "
      fi
      if [ $autoconftest == false ]
      then
         echo "Try running sudo apt install autoconf"
         echo " "
      fi
      if [ $libltdltest == false ] && [ $libtoolizetest == true ]
      then
         echo "Try running sudo apt install libltldl-dev"
         echo " "
      fi
      if [ $libtoolizetest == false ]
      then
         echo "Try running sudo apt install libtool-bin"
         echo " "
      fi
      if [ $gittest == false ]
      then
         echo "Try running sudo apt install git"
         echo " "
      fi
      if [ $graphviztest == false ]
      then
         echo "Try running sudo apt install graphviz"
         echo " "
      fi
   exit
   fi
   if [ $OS != centos ] || [ $OS != ubuntu ]
   then
      echo "Use your the package installation tool to install missing packages"
      exit
   fi  
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
   echo "Your .bashrc has been updated with the correct environment variables"
   echo "including PATH variable"
   echo "Please source your .bashrc (source .bashrc) before running SST."
   echo " "
   echo "The SST GUI uses PyQt5 to test if you have it installed simply run"
   echo "python3 -c \"import PyQt5\""
   echo "If it returns a Python error run the following to install PyQt5"
   if [ $OS == ubuntu ]
   then
      echo "sudo apt install python3-pyqt5"
   fi
   if [ $OS == centos ]
   then
      echo "sudo pip3 install pyqt5"
   fi
   if [ $OS != centos ] || [ $OS != ubuntu ]
   then
      echo "Use your the package installation tool to install PyQt5....."
   fi
else
   echo "*****SST INSTALLATION WAS UNSUCCESSFUL*****"
   echo "Cleaning up directories ...."
   echo " "
   rm -rf $DOWNLOAD
   rm -rf $INSTALL
   echo "Cleaning up .bashrc ....."
   sed -i "$(($(wc -l < ~/.bashrc)-14)),\$d" ~/.bashrc
fi

