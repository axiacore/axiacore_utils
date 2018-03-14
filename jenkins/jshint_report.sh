#!/bin/bash

# This script create a report for jenkins violations plugin
# Make sure you have a .jshintignore file to exclude paths from the report
# Author: AxiaCore S.A.S. http://axiacore.com

echo "Generating jshint report..."
mkdir -p reports

if [ -f app/static/es6/ ]; then
    js_path=app/static/es6/
else
    js_path=app/static/js/
fi

jshint --jslint-reporter $js_path | sed -E 's?<file name="(.*)\?">?<file name="'"`pwd`"'/\1">?' > reports/jshint.xml
echo "Done"
