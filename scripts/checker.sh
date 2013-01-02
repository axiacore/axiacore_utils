#!/bin/bash
################################################
# Script to check pep8 and pylint standards
# Author: AxiaCore S.A.S
# Notes:
# You must run this script in active virtualenv
# and from the root of project
################################################

echo -e "Running pep8 checking in modified files .....\n"
git status | grep 'py$' | grep 'modified' | awk '{print $3}' | xargs pep8
if [ $? -eq 0 ] ; then echo -e "Not pep8 errors found in modified files"; fi
echo -e "Running pep8 checking in new files .....\n"
git status | grep 'py$' | grep -v 'modified' | awk '{print $2}' | xargs pep8
if [ $? -eq 0 ] ; then echo -e "Not pep8 errors found in new files"; fi

echo -e "Running pylint checking in modified files .....\n"
git status | grep 'py$' | grep 'modified' | awk '{print $3}' | xargs pylint --rcfile=pylint.rc -r n
if [ $? -eq 0 ] ; then echo -e "Not pylint errors found in modified files"; fi
echo -e "Running pylint checking in new files .....\n"
git status | grep 'py$' | grep -v 'modified' | awk '{print $2}' | xargs pylint --rcfile=pylint.rc -r n
if [ $? -eq 0 ] ; then echo -e "Not pylint errors found in new files"; fi