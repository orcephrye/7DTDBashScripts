#!/bin/bash

if test -z "$1"
then
    serverDir="seven"
else
    serverDir="$1"
fi

if ! test -f "seven_$serverDir.lockfile"
then
    echo "7 Days to Die server in dir $serverDir has never ran before"
fi

if test -s "seven_$serverDir.lockfile"
then
    seven_pid=$(cat "seven_$serverDir.lockfile" | tr -d '\n')
    if test -z "$seven_pid"
    then
        echo "PID lock file is empty... seven must not be running."
        exit 0
    fi
    if ps -p $seven_pid > /dev/null
    then
        echo "7 Days to Die server in dir $serverDir is running with PID: $seven_pid"
        cat <(echo lpi) <(sleep 0.1) <(echo exit) | nc -q 1 localhost 8081
    else
        echo "7 Days to Die  PID is invalid. Must not be running... Clenaing up."
        echo "" > "seven_$serverDir.lockfile"
    fi
else
    echo "7 Days to Die  server in dir $serverDir is not running"
fi
