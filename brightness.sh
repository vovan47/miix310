#!/bin/bash
ERROR=false
re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
   echo "error: Not a number";
   ERROR=true
else
    if [ "$1" -lt "10" ]; then
        echo "error: brightness value is less than 10"
        ERROR=true
    else 
        if [ "$1" -gt "100" ]; then
             echo "error: brightness value is more than 100"
             ERROR=true
        fi	
    fi	
fi

if $ERROR; then
  val=35
else
  val=$1
fi
brightness=$(bc -l <<< "scale=2;"$val"/100")
echo "brightness set to "$brightness
`xrandr --output DSI-1 --brightness $brightness --gamma 1:1:0.7`

