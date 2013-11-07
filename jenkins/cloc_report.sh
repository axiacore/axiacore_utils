#!/bin/bash

# This script create a report for jenkins violations plugin
# Author: AxiaCore S.A.S. http://axiacore.com

echo "Generating cloc report..."
mkdir -p reports
cloc --by-file --exclude-dir=migrations,libs,vendor,reports --exclude-ext=min.js,min.css --exclude-lang=make --quiet --csv "`pwd`/" | egrep -v 'Counting|language' | awk -F, '{ if ($1 == "Bourne Again Shell") {language="shell"} else if ($1 == "Bourne Shell") {language="shell"} else { language=tolower($1) } n=split($2, basedir, "/"); folder=basedir[n-1]; print $5"\t"language"\t"folder"\t"$2 }' > reports/cloc.report
echo "Done"
