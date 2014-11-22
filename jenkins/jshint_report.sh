#!/bin/bash

# This script create a report for jenkins violations plugin
# Make sure you have a .jshintignore file to exclude paths from the report
# Author: AxiaCore S.A.S. http://axiacore.com

echo "Generating jshint report..."
mkdir -p reports
jshint --jslint-reporter app/static/js/ | sed -E 's?<file name="(.*)\?">?<file name="'"`pwd`"'/\1">?' > reports/jshint.xml
echo "Done"
