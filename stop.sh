#!/bin/bash

if test -z "$1"
then
    serverDir="seven"
else
    serverDir="$1"
fi

cat <(echo shutdown) <(sleep 0.1) <(echo exit) | nc -q 1 localhost 8081
screen -S $serverDir -p 0 -X stuff "^c"

echo "Attempting to wait for 7 Days to Die to stop"
counter=0
i=1
sp="/-\|"
echo -n ' '
until [ $counter -gt 60 ]
do
    printf "\b${sp:i++%${#sp}:1}"
    sleep 1
    ((counter=counter+1))
    if ! screen -list | grep -q $serverDir
    then
        break
    fi
done

echo ""
echo "7 Days to Die server has stopped... checking"
echo ""

/bin/bash status.sh $serverDir
