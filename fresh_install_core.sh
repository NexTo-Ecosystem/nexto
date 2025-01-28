#!/bin/bash
# Copyright (c) 2010-2022 Nur1Labs
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

#function start
#systems
function prepare_system() {
echo -e "Preparing the VPS to setup. ${CYAN}$COIN_NAME${NC} ${RED}Central Nodes${NC}"
#running autoinstall
cd ~/coins/nexto/builder && chmod 755 -R plugins.sh && ./plugins.sh && cd ..
cd ~/coins/nexto/builder && chmod 755 -R core.sh && ./core.sh && cd ..
}

function important_information() {
 echo
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "${BLUE}================================================================================================================================${NC}"
 echo -e "$COIN_NAME Central Nodes is up and running listening on port ${GREEN}$COIN_PORT${NC}."
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "Check Status: ${RED}systemctl status $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${GREEN}$NODEIP:$COIN_PORT${NC}"
 echo -e "Check ${RED}$COIN_CLI getblockcount${NC} and compare to ${GREEN}$COIN_EXPLORER${NC}."
 echo -e "Use ${RED}$COIN_CLI help${NC} for help."
}

#function_end
function setup_node() {
  important_information
}

##### Main #####
clear

prepare_system
setup_node
