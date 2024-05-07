#!/bin/bash
HOME=/root
cd /root

if [ ! -d $HOME/source ]
then
  mkdir $HOME/source
  echo INFORMATION: $HOME/source does not exist. Creating....
fi

if [ ! -d $HOME/Desktop ]
then
  mkdir $HOME/Desktop
  echo INFORMATION: $HOME/Desktop does not exist. Creating...
fi

if [ ! -d $HOME/vRMS ]
then
  virtualenv --system-site-packages $HOME/vRMS
  echo INFORMATION: Virtual Python environment doest not exist. Creating...
fi

if [ ! -d $HOME/.ssh ]
then
  mkdir $HOME/.ssh
  chmod 700 $HOME/.ssh
  ssh-keygen -t rsa -m PEM -N "" -f $HOME/.ssh/id_rsa
  chmod 600 $HOME/.ssh/id_rsa
fi

source $HOME/vRMS/bin/activate
cd $HOME/source

if [ ! -d RMS ]
then
  echo INFORMATION: RMS is not present. Downloading...
  git clone https://github.com/CroatianMeteorNetwork/RMS.git
  cd $HOME/source/RMS
  pip install -r requirements.txt
  python setup.py install
  cd $HOME/source/RMS/Scripts
  ./GenerateDesktopLinks.sh

  echo 1 > $HOME/.rmsautorunflag
  echo STOPPING: Please edit \~/rms_container/CAMERANAME/source/RMS/.config
  echo STOPPING: and put platepar and maskfiles also in that directory
  echo STOPPING: .ssh files go into \~/rms_container/CAMERANAME/.ssh
  exit
fi

chmod 700 $HOME/.ssh
chmod 600 .ssh/*

echo INFORMATION: Starting RMS
cd $HOME/source/RMS
$HOME/Desktop/RMS_FirstRun.sh
