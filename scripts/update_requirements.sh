#!/bin/bash

# This script will update the requirements only if the file has changed
# Author: AxiaCore S.A.S. http://axiacore.com

FILE=.requirements_timestamp
if [ ! -f $FILE ] || [ ! `stat --format="%Y" requirements.txt` -eq $(cat $FILE) ];
then
    echo "Updating requirements..."
    pip install -U -r requirements.txt
    stat --format="%Y" requirements.txt > $FILE
    echo "Done"
else
    echo "Requirements not changed."
fi
