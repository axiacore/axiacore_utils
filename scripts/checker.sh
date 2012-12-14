#!/bin/bash
################################################
# Script to check pep8 and pylint standards
# Author: AxiaCore S.A.S
# Notes:
# You must run this script in active virtualenv
# and in the root of project
################################################

echo -e "Running pep8 checking .....\n"
git status | grep 'py$' | grep 'modified' | awk '{print $3}' | xargs pep8
if [ $? -eq 0 ] ; then echo -e "Not pep8 errors found"; fi

echo -e "Running pylint checking .....\n"
git status | grep 'py$' | grep 'modified' | awk '{print $3}' | xargs pylint --rcfile=pylint.rc -r n
if [ $? -eq 0 ] ; then echo -e "Not pylint errors found"; fi
