#!/bin/bash

# Update raspi things
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get upgrade

# Install some required python libraries for shutdown script
sudo apt-get install python-dev python-pip python-gpiozero
sudo pip install psutil pyserial
sudo apt install pigpio

# Install additional workflow tools
sudo apt-get install vim                # 1st fav text editor
sudo apt-get install emacs              # 2nd fav text editor
sudo apt-get install gh                 # github
sudo apt-get install silversearcher-ag  # Great, fast search tool
sudo apt-get install tmux               # Terminal multiplexer
sudo apt-get install sl                 # Punishes the user for typing too quickly

# Install testing tools
sudo apt-get install iostat    # Network stuff
sudo apt-get install sysbench  # Stress testing and benchmarking tool
sudo apt-get install xclip     # Pipe things to your clipboard
sudo apt install nmon          # Excellent interactive system monitor

# Install Retroflag NesPi safe shutdown script
cd ~
wget -O - "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/install_gpi.sh" | sudo bash

exit
