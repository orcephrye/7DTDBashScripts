#!/bin/bash

if test -z "$1"
then
    serverDir="seven"
else
    serverDir="$1"
fi

/bin/bash update.sh $serverDir
screen -d -S $serverDir -m bash 7days.sh $serverDir

sleep 2

/bin/bash status.sh $serverDir
