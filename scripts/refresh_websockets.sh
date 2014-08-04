#!/bin/bash
################################################
# Script to kill some workers
# Author: AxiaCore S.A.S
################################################

MAX_WEBSOCKETS=20
CANT=`ps aux | grep websocket | wc -l`
if [ $CANT -gt $MAX_WEBSOCKETS ]
then
   ps aux | grep websocket | grep -v grep | grep -v refresh | awk '{system("kill "$2); }'
fi
