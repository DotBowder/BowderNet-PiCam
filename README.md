
# BowderNet PiCam

BowderNet PiCam is designed to automate the process of recording or watching video from your raspberry pi camera.

### Prerequisites

Dependencies:
  Raspberry Pi
    - Camera Enabled
    - SSH Enabled
    - Workstation SSH Key added to authorized keys file (typically /home/pi/.shh/authorized_keys)

  Workstation
    - ffmpeg for recording video to file
    - ffplay for playing video on screen
    - Workstation SSH Key for accessing the raspberry pi autonomously. (typically /home/$USER/.ssh/id_ecdsa)

  SSH Key
    * If you do not have an SSH key authorized on your raspberry pi, you need to generate one.
    * The process is described here: http://sshkeychain.sourceforge.net/mirrors/SSH-with-Keys-HOWTO/SSH-with-Keys-HOWTO-4.html

### Installing

Usage:
Start in the local directory of the file. There is some code that depends on being in that directory.

./PiCam.sh [options]  
```
-l [miliseconds]         : eg(-l 30000)              # Video length will be 30 seconds

-b [bitrate]             : eg(-b 1000000)            # Video bitrate will be 1Mbps
-i [identity file]       : eg(-i /keys/mykey)        # Key used for SSH will be /keys/mykey
-p [port number]         : eg(-p 9999)               # Video will be transported on tcp port 9999
-h [hostname]            : eg(-h 10.0.0.54)          # Connect to the ip/hostname of 10.0.0.54
                         : eg(-h raspberrypi)        # Connect to the ip/hostname of raspberrypi
-d [save dir]            : eg(-d /home/$USER/Vids/"  # Directory to save videos to. (Note the use of
                         :                           # a trailing "/" is needed.)
-c                       : eg(-c)                    # Continuous mode. Use to restart video recording
                         :                           # or viewing, instead of quitting the program.
                         :                           #
-w                       : eg(-w)                    # Watch mode. (Open stream with ffplay video player)
                         :                           #
-r                       : eg(-r)                    # Record mode. (Save stream to file. Do not play)
```

