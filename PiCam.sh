#!/bin/bash
#
# Template Script
# ====================
#


# External Variables (that the user may change)
identity_file=/home/$USER/.ssh/id_ecdsa
pi_username=pi
pi_hostname=dr-cm
stream_software_host=raspivid
vid_width=1920
vid_height=1080
vid_fps=25
vid_bitrate=15000000
vid_roi=0.3,0.12,0.36,0.65
vid_length="0"
vid_record_dir="/home/$USER/Videos/"
socket_port=3333
client=record
toggle_am="7"
toggle_pm="17"
continuous=0

# Internal Variables (that the user may not change)

SERVICE="PiCam"
CONFIG_FILE="picam.conf"

#Colors
NC=$(tput sgr0)

C_1=$(tput setaf 1) # Red
C_2=$(tput setaf 2) # TEXTA
C_3=$(tput setaf 3) # Orange
C_4=$(tput setaf 4) # Blue
C_5=$(tput setaf 5) # Pink
C_6=$(tput setaf 6) # Teal
C_7=$(tput setaf 7) # Grey
# echo "${C_1} 1 - Thesrs colsnfjwoefhwoefwekmf "
# echo "${C_2} 1 - Thesrs colsnfjwoefhwoefwekmf "
# echo "${C_3} 1 - Thesrs colsnfjwoefhwoefwekmf "
# echo "${C_4} 1 - Thesrs colsnfjwoefhwoefwekmf "
# echo "${C_5} 1 - Thesrs colsnfjwoefhwoefwekmf "
# echo "${C_6} 1 - Thesrs colsnfjwoefhwoefwekmf "


#Colors
FILE=$C_6
FUNC=$C_5
TITLE=$C_3
TEXTA=$C_7
TEXTB=$NC
GREETING=$NC
PANIC=$C_1

echo "$LIME $L_GREY $YELLOW"

#Header for console
FF="${FILE}$0:"


# Error Exit
function panic(){
  echo "$FF${PANIC} Fatal Error, Aborting Program! ${NC}"
  exit -1
}

# Core Program Functions

function greeting(){
  echo "$FF${GREETING} ##########################${NC}"
  echo "$FF${GREETING} ###                    ###${NC}"
  echo "$FF${GREETING} ###      Running       ###${NC}"
  echo "$FF${GREETING} ###       $SERVICE        ###${NC}"
  echo "$FF${GREETING} ###                    ###${NC}"
  echo "$FF${GREETING} ##########################${NC}"

}

function read_conf(){
  echo "$FF${TEXTA} Importing Config File... ${CONFIG_FILE}${NC}"
  source ./${CONFIG_FILE} || panic
  echo "$FF${TEXTA} Config File Sucessfully Sourced.${NC}"
}

function set_date(){
  echo "$FF${TEXTA} Acquireing Date...${NC}"
  YEAR=$(date +%Y)
  MONTH=$(date +%m)
  DAY=$(date +%d)
  HOUR=$(date +%H)
  MINUTE=$(date +%M)
  SECOND=$(date +%S)
  echo "$FF${TEXTA} Date: ${TEXTB}${YEAR}/${MONTH}/${DAY} ${HOUR}:${MINUTE}:${SECOND}${NC}"
}

function time_left(){
  if [ "$vid_length" -ne "0" ]; then
    echo "$FF${TEXTA} User has defined screen toggle time. ${NC}"
      REC_HOURS=0
      REC_MINUTES=0
      REC_SECONDS=$(( $vid_length / 1000 ))
  else
    overnight=$(( 24 - ${toggle_pm} + ${toggle_am} ))
    echo "$FF${TEXTA} Calculating time until stream toggle...${NC}"
    if [ "$HOUR" -lt "$toggle_am" ]; then
      REC_HOURS=$(( ${toggle_am} - ${HOUR} - 1))
      REC_MINUTES=$(( 60 - ${MINUTE} - 1))
      REC_SECONDS=$(( 60 - ${SECOND}))
    elif [[ "$HOUR" -ge "$toggle_am" && "$HOUR" -lt "$toggle_pm" ]]; then
      REC_HOURS=$(( ${toggle_pm} - ${HOUR} - 1))
      REC_MINUTES=$(( 60 - ${MINUTE} - 1))
      REC_SECONDS=$(( 60 - ${SECOND}))
    elif [ "$HOUR" -ge "$toggle_pm" ]; then
      REC_HOURS=$(( ${overnight} + ${toggle_pm} - ${HOUR} - 1))
      REC_MINUTES=$(( 60 - ${MINUTE} - 1))
      REC_SECONDS=$(( 60 - ${SECOND}))
    fi
    HOUR_TO_MILISEC=$(( $(( $(( ${REC_HOURS} * 60)) * 60 )) * 1000))
    MIN_TO_MILISEC=$(( $(( ${REC_MINUTES} * 60 )) * 1000))
    SEC_TO_MILI_SEC=$(( ${REC_SECONDS} * 1000))
    REC_TOTAL_MS=$(( ${HOUR_TO_MILISEC} + ${MIN_TO_MILISEC} + ${SEC_TO_MILI_SEC}))
    echo "$FF${TEXTA} Time Left: ${TEXTB}${REC_HOURS}:${REC_MINUTES}:${REC_SECONDS}${NC}"
    echo "$FF${TEXTA} Time Left(ms): ${TEXTB}${REC_TOTAL_MS}${NC}"
    vid_legth=$REC_TOTAL_MS
  fi
}

function set_brightness(){
  echo "$FF${TEXTA} Setting Video Brightness...${NC}"
  if [[ $HOUR -lt "7" || $HOUR -ge "17" ]]; then
    vid_br="55"
    vid_ev="10"
    vid_ex="night"
    vid_co="0"
  elif [[ $HOUR -ge "7" && $HOUR -lt "17" ]]; then
    vid_br="45"
    vid_ev="-10"
    vid_ex="auto"
    vid_co="0"
  fi
  echo "$FF${TEXTA} Video Brightness Set${NC}"
}

function kill_stream_raspivid(){
  echo "$FF${TEXTA} Open Pi Secure Shell... ${NC}"
  response=$(ssh -f -i $identity_file $pi_username@$pi_hostname "ps -A | grep raspivid | cut -d' ' -f 1")
  #echo $response
  if [[ $response != "?" && $response != " " && $response != "" ]]; then
      echo "$FF${TEXTA} Found existing stream. Killing Stream... ${NC}"
    ssh -f -i $identity_file $pi_username@$pi_hostname "kill -9 $response"
  else
    echo "$FF${TEXTA} Found no existing streams.${NC}"
  fi
}

function host_stream_raspivid(){
  echo "$FF${TEXTA} Open Pi Secure Shell... ${NC}"
  if [ $stream_software_host == "raspivid" ]; then
    COMMAND="raspivid -w $vid_width -h $vid_height -fps $vid_fps -g 10 -br $vid_br -ev $vid_ev -ex $vid_ex -co $vid_co -t $vid_length -b $vid_bitrate -roi $vid_roi -l -o tcp://0.0.0.0:$socket_port"
    echo "$FF${TEXTA} Command: ${TEXTB}'$COMMAND' ${NC}"
    ssh -f -q -i $identity_file $pi_username@$pi_hostname "$COMMAND" 2>&-
    sleep 5
    echo "$FF${TEXTA} Raspivid Stream Command Executed. ${NC}"
  elif [ $stream_software_host == "netcat" ]; then
    COMMAND='netcat something-or-other'
    echo "$FF${TEXTA} Command: ${TEXTB}'$COMMAND' ${NC}"
  fi
}

function watch_stream(){
  echo "$FF${TEXTA} Connecting to Raspivid Stream... ${NC}"
  COMMAND="ffplay tcp://$pi_hostname:$socket_port"
  echo "$FF${TEXTA} Command: ${TEXTB}${COMMAND} ${NC}"
  ${COMMAND}

}

function record_stream(){
  echo "$FF${TEXTA} Recording Raspivid Stream...${NC}"
  COMMAND="ffmpeg -loglevel quiet -i tcp://$pi_hostname:$socket_port -vcodec copy -t $(($vid_length - 2)) -f flv $vid_record_dir$FILENAME.flv -y"
  COMMAND="ffmpeg -i tcp://$pi_hostname:$socket_port -vcodec copy -f flv $vid_record_dir$FILENAME.flv -y"
  echo "$FF${TEXTA} Command: ${TEXTB}'${COMMAND}' ${NC}"
  echo ""
  $COMMAND
  echo "$FF${TEXTA} Saved File: ${TEXTB}$vid_record_dir$FILENAME.flv ${NC}"


}

function template(){
  echo "$FF${TEXTA} texthere ${NC}"

}


echo "$FF${TITLE} Source Config File ${NC}"
read_conf
echo ""

# Command line Variables

# Command line Variables
echo "$FF${TITLE} Processing User Defined Options ${NC}"
while getopts ":l:b:i:p:h:v:cwr" opt; do
  case $opt in
    l)
      #echo "$FF${TEXTA} Option switched on: ${TEXTB}-l ${OPTARG} ${NC}" >&2
      vid_length=${OPTARG}
      echo "$FF${TEXTB} -l ${TEXTA}Video length adjusted to: ${TEXTB}${OPTARG} (ms) ${NC}" >&2
      ;;
    b)
      #echo "$FF${TEXTA} Option switched on: ${TEXTB}-b ${OPTARG} ${NC}" >&2
      vid_bitrate=${OPTARG}
      echo "$FF${TEXTB} -b ${TEXTA}Video bitrate adjusted to: ${TEXTB}${OPTARG} (bps) ${NC}" >&2
      ;;
    i)
      #echo "$FF${TEXTA} Option switched on: ${TEXTB}-i ${OPTARG} ${NC}" >&2
      identity_file=${OPTARG}
      echo "$FF${TEXTB} -i ${TEXTA}Identity file location adjusted to: ${TEXTB}${OPTARG} ${NC}" >&2
      ;;
    p)
      #echo "$FF${TEXTA} Option switched on: ${TEXTB}-p ${OPTARG} ${NC}" >&2
      socket_port=${OPTARG}
      echo "$FF${TEXTB} -p ${TEXTA}Connection port adjusted to: ${TEXTB}${OPTARG} (tcp) ${NC}" >&2
      ;;
    h)
      #echo "$FF${TEXTA} Option switched on: ${TEXTB}-h ${OPTARG} ${NC}" >&2
      echo "$FF${TEXTB} -h ${TEXTA} ____ adjusted to: ${TEXTB}${OPTARG} ${NC}" >&2
      ;;
    v)
      #echo "$FF${TEXTA} Option switched on: ${TEXTB}-v ${OPTARG} ${NC}" >&2
      echo "$FF${TEXTB} -v ${TEXTA} ____ adjusted to: ${TEXTB}${OPTARG} ${NC}" >&2
      ;;
    c)
      #echo "$FF${TEXTA} Option switched on: ${TEXTB}-c ${NC}" >&2
      continuous=1
      echo "$FF${TEXTB} -c ${TEXTA}Continuous mode adjusted to: ${TEXTB}true ${NC}" >&2
      ;;
    w)
      #echo "$FF${TEXTA} Option switched on: ${TEXTB}-w ${NC}" >&2
      client="watch"
      echo "$FF${TEXTB} -w ${TEXTA}Client mode adjusted to: ${TEXTB}watch${NC}" >&2
      ;;
    r)
      #echo "$FF${TEXTA} Option switched on: ${TEXTB}-r ${NC}" >&2
      client="record"
      echo "$FF${TEXTB} -r ${TEXTA}Client mode adjusted to: ${TEXTB}record ${NC}" >&2
      ;;
    \?)
      echo "$FF${PANIC} An invalid option was used: ${TEXTB}-$OPTARG ${NC}" >&2
      panic
      ;;
  esac
    # :)
    #   echo "${FILE}${0}:${RED} Option ${TEXTB}-$OPTARG${RED} requires an argument. ${NC}" >&2
    #   exit 1
    #   ;;

done
echo ""

echo "$FF${TITLE} Start ${SERVICE}${NC}"
greeting
echo ""

#Program Loop
while true;
do

  echo "$FF${TITLE} Gather Date ${NC}"
  YEAR=""
  MONTH=""
  DAY=""
  HOUR=""
  MINUTE=""
  SECOND=""
  set_date
  START_YEAR=$YEAR
  START_MONTH=$MONTH
  START_DAY=$DAY
  START_HOUR=$HOUR
  START_MINUTE=$MINUTE
  START_SECOND=$SECOND
  DATE="$YEAR-$MONTH-$DAY-$HOUR:$MINUTE:$SECOND"
  START_DATE="$START_YEAR-$START_MONTH-$START_DAY-$START_HOUR:$START_MINUTE:$START_SECOND"
  echo ""

  echo "$FF${TITLE} Calculate Time Until Screen Toggle ${NC}"
  echo "$FF${PANIC} Skipping Calculation ${NC}"
  #REC_HOURS=""
  #REC_MINUTES=""
  #REC_SECONDS=""
  #REC_TOTAL_MS=""
  #time_left
  echo ""

  echo "$FF${TITLE} Set Video Brightness ${NC}"
  vid_br="50"
  vid_ev="0"
  vid_ex="auto"
  set_brightness
  echo ""

  echo "$FF${TITLE} Check for Existing PiCam Streams ${NC}"
  kill_stream_raspivid
  echo ""

  echo "$FF${TITLE} Host PiCamera Stream ${NC}"
  host_stream_raspivid
  echo ""

  if [ $client == "record" ]; then
    echo "$FF${TITLE} Record PiCamera Stream ${NC}"
    FILENAME="$DATE"
    record_stream
    echo ""
  elif [ $client == "watch" ]; then
    echo "$FF:${TITLE} Watch PiCamera Stream ${NC}"
    watch_stream
    echo ""
  fi

  #clear
  if [ $continuous -eq 0 ]; then
    echo "$FF${PINK} Continuous mode is $continuous. Closing Loop... ${NC}"
    break
  fi
  echo "$FF${PINK} Continuous mode is $continuous. Continuing Loop... ${NC}"
  echo ""
done

exit 0
#
