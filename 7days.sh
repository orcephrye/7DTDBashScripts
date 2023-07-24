#!/bin/bash

if test -z "$1"
then
    serverDir="seven"
else
    serverDir="$1"
fi

echo $$ > seven_$serverDir.lockfile

./$serverDir/startserver.sh -configfile=serverconfig.xml


kill -9 $(pgrep -P $$)

echo "" > seven_$serverDir.lockfile