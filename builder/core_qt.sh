#!/bin/bash
# Copyright (c) 2010-2022 Nur1Labs.Ltd
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='nexto.conf'
CONFIGFOLDER='.nexto'
COIN_DAEMON='nextod'
COIN_CLI='nexto-cli'
COIN_PATH='/usr/local/bin/'
COIN_TGZ='http://nexto.club/lf/nexto.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='nexto'
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

#sentinel installer
function install_sentinel() {
  echo -e "${GREEN}Installing sentinel.${NC}"
  apt install -y python-virtualenv virtualenv >/dev/null 2>&1
  git clone $SENTINEL_REPO $CONFIGFOLDER/sentinel >/dev/null 2>&1
  cd $CONFIGFOLDER/sentinel
  virtualenv ./venv >/dev/null 2>&1
  ./venv/bin/pip install -r requirements.txt >/dev/null 2>&1
  echo  "* * * * * cd $CONFIGFOLDER/sentinel && ./venv/bin/python bin/sentinel.py >> $CONFIGFOLDER/sentinel.log 2>&1" > $CONFIGFOLDER/$COIN_NAME.cron
  crontab $CONFIGFOLDER/$COIN_NAME.cron
  rm $CONFIGFOLDER/$COIN_NAME.cron >/dev/null 2>&1
}

#get ip
function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}

#function start
#systems
function prepare_system() {
echo -e "Preparing the VPS to setup. ${CYAN}$COIN_NAME${NC} ${RED}Core Features${NC}"
#this for core
#chmod
cd ~/coins/nexto/core && chmod 755 -R build-aux && chmod 755 -R depends && chmod 755 -R share && chmod 755 -R mubdi.sh
cd ~/coins/nexto/core && chmod 755 -R src/leveldb && chmod 755 -R src/univalue
#main
cd ~/coins/nexto/core && ./mubdi.sh && ./configure --enable-cxx --with-incompatible-bdb --enable-mining-rpc && make && make install
}

function important_information() {
 echo
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "Core is installed"
 if [[ -n $SENTINEL_REPO  ]]; then
 echo -e "${RED}Sentinel${NC} is installed in ${RED}/root/sentinel_$COIN_NAME${NC}"
 echo -e "Sentinel logs is: ${RED}$CONFIGFOLDER/sentinel.log${NC}"
 fi
}

#function_end
function setup_node() {
  get_ip
  #install_sentinel
  important_information
}

##### Main #####
clear

prepare_system
setup_node
