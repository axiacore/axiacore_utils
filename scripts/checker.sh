#!/bin/bash
################################################
# Script to check pep8 and pylint standards
# Author: AxiaCore S.A.S
# Notes:
# You must run this script in active virtualenv
# and from the root of project
################################################


MODIFIED_EXPR='^M|^ M'
RENAMED_EXPR='^R|^ R'
UNTRACKED_EXPR='^\?|^ \?'
GIT_COMMAND='git status --porcelain'
PEP8_COMMAND='pep8'
PYLINT_COMMAND='pylint --rcfile=pylint.rc -r n'
PRINT_COMMAND='grep -n -H --colour=auto print'

# pep8 checking

echo -e "Running pep8 checking in modified files .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${MODIFIED_EXPR}" | awk '{print $2}' | xargs ${PEP8_COMMAND}
if [ $? -eq 0 ] ; then echo -e "Not pep8 errors found in modified files"; fi
echo -e "Running pep8 checking in new files .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${UNTRACKED_EXPR}" | awk '{print $2}' | xargs ${PEP8_COMMAND}
if [ $? -eq 0 ] ; then echo -e "Not pep8 errors found in new files"; fi
echo -e "Running pep8 checking in renamed files .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${RENAMED_EXPR}" | awk '{print $4}' | xargs ${PEP8_COMMAND}
if [ $? -eq 0 ] ; then echo -e "Not pep8 errors found in renamed files"; fi

# pylint checking

echo -e "Running pylint checking in modified files .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${MODIFIED_EXPR}" | awk '{print $2}' | xargs ${PYLINT_COMMAND}
if [ $? -eq 0 ] ; then echo -e "Not pylint errors found in modified files"; fi
echo -e "Running pylint checking in new files .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${UNTRACKED_EXPR}" | awk '{print $2}' | xargs ${PYLINT_COMMAND}
if [ $? -eq 0 ] ; then echo -e "Not pylint errors found in new files"; fi
echo -e "Running pylint checking in renamed files .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${RENAMED_EXPR}" | awk '{print $4}' | xargs ${PYLINT_COMMAND}
if [ $? -eq 0 ] ; then echo -e "Not pylint errors found in renamed files"; fi

# print checking

echo -e "Running checking for print calls in modified files .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${MODIFIED_EXPR}" | awk '{print $2}' | xargs ${PRINT_COMMAND}
if [ $? -eq 0 ] ; then echo -e "Not print calls found in modified files"; fi
echo -e "Running checking for print calls in new files .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${UNTRACKED_EXPR}" | awk '{print $2}' | xargs ${PRINT_COMMAND}
if [ $? -eq 0 ] ; then echo -e "Not print calls found in new files"; fi
echo -e "Running checking for print calls in renamed files .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${RENAMED_EXPR}" | awk '{print $4}' | xargs ${PRINT_COMMAND}
if [ $? -eq 0 ] ; then echo -e "Not print calls found in renamed files"; fi
