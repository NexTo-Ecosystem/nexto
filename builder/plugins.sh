#!/bin/bash
# Copyright (c) 2010-2022 Nur1Labs.Ltd
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='nexto.conf'
CONFIGFOLDER='/root/.nexto'
COIN_DAEMON='nextod'
COIN_CLI='nexto-cli'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='http://nexto.club/lf/nexto.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='NexTo-API'
COIN_EXPLORER='http://chain.nexto.club'
COIN_PORT=41031
RPC_PORT=41131

NODEIP=$(curl -s4 icanhazip.com)

BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m" 
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'

#function start
#purge_old
purgeOldInstallation() {
    echo -e "${GREEN}Searching and removing old $COIN_NAME files and configurations${NC}"
    #kill wallet daemon
    killall $COIN_DAEMON > /dev/null 2>&1
    #remove old ufw port allow
    ufw delete allow $COIN_PORT/tcp > /dev/null 2>&1
    #remove old files
    rm $COIN_CLI $COIN_DAEMON > /dev/null 2>&1
    rm -rf ~/.$COIN_NAME > /dev/null 2>&1
    #remove binaries and $COIN_NAME utilities
    cd /usr/local/bin && rm $COIN_CLI $COIN_DAEMON > /dev/null 2>&1 && cd
    echo -e "${GREEN}* Done${NONE}";
    echo "purge libevent old folder"
    rm -rf libevent
}

#firewall
function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}

#rebuild_node
function rebuild_node() {
  echo -e "${GREEN}Installing VPS $COIN_NAME Daemon${NC}"
  cd $TMP_FOLDER >/dev/null 2>&1
  cd linux
  chmod +x $COIN_DAEMON
  chmod +x $COIN_CLI
  cp $COIN_DAEMON $COIN_PATH
  cp $COIN_DAEMON /root/
  cp $COIN_CLI $COIN_PATH
  cp $COIN_CLI /root/
  cd ~ >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}

#config_system
function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}

#create_config
function create_config() {
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
txindex=1
rpcport=$RPC_PORT
rpcallowip=127.0.0.1
port=$COIN_PORT
daemon=1
listen=1
server=1
enableaccounts=1
staking=1
gen=0
EOF
}

#swapping memory
function create_swap() {
 echo -e "Checking if swap space is needed."
 PHYMEM=$(free -m|awk '/^Mem:/{print $2}')
 SWAP=$(free -m|awk '/^Swap:/{print $2}')
 if [ "$PHYMEM" -lt "1000" ] && [ -n "$SWAP" ]
  then
    echo -e "${GREEN}Server is running with less than 1G of RAM without SWAP, creating 2G swap file.${NC}"
    SWAPFILE=$(mktemp)
    dd if=/dev/zero of=$SWAPFILE bs=1024 count=2M
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon -a $SWAPFILE
 else
  echo -e "${GREEN}Server running with at least 1G of RAM, no swap needed.${NC}"
 fi
 clear
}

#compile_error
function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}

#checks
function checks() {
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already installed.${NC} Please Run again.."
  exit 1
fi
}

#function start
#systems
function prepare_system() {
echo -e "Preparing the VPS to setup. ${CYAN}$COIN_NAME${NC} ${RED}Plugins Features${NC}"
#this for autoinstall
sudo apt upgrade -y >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
sudo apt install -y software-properties-common net-tools build-essential >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
sudo apt install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" git ufw curl unzip >/dev/null 2>&1
sudo apt install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" libtool autotools-dev autoconf pkg-config automake libssl-dev libgmp-dev libboost-all-dev >/dev/null 2>&1
sudo apt install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" libminiupnpc-dev libzmq3-dev qtbase5-dev qttools5-dev qttools5-dev-tools libqt5charts5-dev libqt5svg5-dev libprotobuf-dev protobuf-compiler libqrencode-dev >/dev/null 2>&1
sudo apt install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" cargo libsodium-dev >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt update"
    echo "apt -y install software-properties-common net-tools build-essential"
    echo "apt update"
    echo "apt install -y git ufw curl &&
  apt install -y libtool autotools-dev autoconf pkg-config automake python3 libssl-dev libgmp-dev libboost-all-dev &&
  apt install -y libminiupnpc-dev libzmq3-dev qtbase5-dev qttools5-dev qttools5-dev-tools libqt5charts5-dev libqt5svg5-dev libprotobuf-dev protobuf-compiler libqrencode-dev &&
        apt install -y cargo libsodium-dev"
 exit 1
fi
clear
#this is plugin for needs
#libevent
git clone https://github.com/libevent/libevent
cd libevent
./autogen.sh && ./configure && sudo make install && cd ~
#libzmq
git clone https://github.com/zeromq/libzmq
cd libzmq
./autogen.sh && ./configure && sudo make install && cd ~

#db
sudo apt install libdb-dev libdb++-dev -y

#zipped simple
cd ~/coins/nexto_core/core && unzip -o plugin.zip && cd ~
}

function important_information() {
 echo
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "Plugins is installed and running"
}

#function_end
function setup_node() {
  enable_firewall
  create_config
  create_swap
  important_information
  configure_systemd
}

##### Main #####
clear

compile_error
purgeOldInstallation
checks
prepare_system
rebuild_node
setup_node
