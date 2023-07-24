#!/bin/bash

SEVEN_BASE_DIR=$(pwd)

if test -z "$1"
then
    serverDir="seven"
else
    serverDir="$1"
fi

./steamcmd.sh +force_install_dir "$SEVEN_BASE_DIR/$serverDir" +login anonymous +app_update 294420 +exit
