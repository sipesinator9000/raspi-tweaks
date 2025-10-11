#!/bin/bash

# Update raspi things
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get upgrade

# Install Retropie
cd ~
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
sudo ./retropie_setup.sh

# Install additional workflow tools
sudo apt-get install vim
sudo apt-get install emacs
sudo apt-get install silversearcher-ag
sudo apt-get install tmux
sudo apt-get install sl

# Install testing tools
sudo apt-get install iostat
sudo apt-get install sysbench
sudo apt-get install xclip

# Install Retroflag NesPi safe shutdown script
cd ~
wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/install_gpi.sh" | sudo bash

exit
