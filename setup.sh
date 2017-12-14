#!/bin/bash
#
# Template Script
# ====================
#


# External Variables (that the user may change)


# Internal Variables (that the user may not change)
SERVICE="PiCam.sh"
EXEC="PiCam.sh"
DEPENDENCIES="dependencies.txt"
GREEN=`tput setaf 2`
RED=`tput setaf 9`
L_GREY=`tput setaf 7`
D_GREY=`tput setaf 8`
LIME=`tput setaf 10`
YELLOW=`tput setaf 11`
L_BLUE=`tput setaf 12`
PINK=`tput setaf 13`
TEAL=`tput setaf 14`
WHITE=`tput setaf 15`
NC=`tput sgr0`


# Opening Function
function main(){

  clear
  echo "${L_BLUE}$0:${PINK} Start ${SERVICE} Setup${NC}"
  greeting
  echo ""

  echo "${L_BLUE}$0:${PINK} Verify root Access ${NC}"
  verify_root
  echo ""

  echo "${L_BLUE}$0:${PINK} Setup ${SERVICE}${NC}"
  install_dependencies
  echo ""

  echo "${L_BLUE}$0:${PINK} Copy Boot Script ${SERVICE}${NC}"
  copy_boot_script
  echo ""

  echo "${L_BLUE}$0:${PINK} Initialize ${SERVICE}${NC}"
  initialize
  echo ""

  exit 0
}

function greeting(){
  echo "${WHITE} ##########################${NC}"
  echo "${WHITE} ###                    ###${NC}"
  echo "${WHITE} ###       Setup        ###${NC}"
  echo "${WHITE} ###     $SERVICE      ###${NC}"
  echo "${WHITE} ###                    ###${NC}"
  echo "${WHITE} ##########################${NC}"

}

# Install Dependency Software
function install_dependencies(){
  echo "${D_GREY}${FUNCNAME}:${D_GREY} Installing Dependencies...${NC}"
  if [ "`cat $DEPENDENCIES`" != "" ];  then
    pacman -S --noconfirm - < $DEPENDENCIES || panic
  else
    echo "${D_GREY}${FUNCNAME}:${RED} No dependencies specified in file $DEPENDENCIES. Continuing with script.${NC}"
  fi
  echo "${D_GREY}${FUNCNAME}:${LIME} Dependencies Installed.${NC}"

}

# Verify script has been run with root level access
function verify_root(){
  echo "${D_GREY}${FUNCNAME}:${D_GREY} Checking root...${NC}"
  if [ "$UID" != "0" ]; then
    echo "${D_GREY}${FUNCNAME}:${RED} Script not running with root access. Please run with root access.${NC}"
    exit -1
  elif [ "$UID" == "0" ]; then
    echo "${D_GREY}${FUNCNAME}:${LIME} Script running with root level access!${NC}"
  fi
}

# Error Exit
function panic(){
  echo "${D_GREY}${FUNCNAME}:${RED} Fatal Error, Aborting Program!${NC}"
  exit -1
}

function copy_boot_script(){
  echo "${D_GREY}${FUNCNAME}:${D_GREY} Copying script to init.d for autostart... ${NC}"
  cp PiCam.sh /etc/init.d/PiCam.sh
  chmod 755 /etc/init.d/PiCam.sh
  chown root:root /etc/init.d/PiCam.sh
  update-rc.d PiCam.sh defaults
  echo "${D_GREY}${FUNCNAME}:${Green} Script Configured for Autostart. ${NC}"

}

# Core Functions
function initialize(){
  echo "${D_GREY}${FUNCNAME}:${D_GREY} Initializing ${SERVICE}...${NC}"
  echo "${D_GREY}${FUNCNAME}:${D_GREY} Command: 'bash ./${EXEC}'${NC}"
  echo ""
  bash ./${EXEC} || panic
}

main $0
#
