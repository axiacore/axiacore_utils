#!/bin/bash
################################################
# Script to check pep8, pylint and jshint standards
# Author: AxiaCore S.A.S
# Notes:
# You must run this script in active virtualenv
# and from the root of project
################################################


MODIFIED_EXPR='^M|^ M'
RENAMED_EXPR='^R|^ R'
UNTRACKED_EXPR='^\?|^ \?'
NEW_EXPR='^A|^ A'
GIT_COMMAND='git status --porcelain'
PEP8_COMMAND='pep8'
PYLINT_COMMAND='pylint --rcfile=pylint.rc -r n'
JSHINT_COMMAND='jshint'
PRINT_COMMAND='grep -n -H --colour=auto print'

# pep8 checking
echo -e "Running pep8 checking .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${MODIFIED_EXPR}" | awk '{print $2}' | xargs ${PEP8_COMMAND}
${GIT_COMMAND} | grep 'py$' | egrep "${UNTRACKED_EXPR}" | awk '{print $2}' | xargs ${PEP8_COMMAND}
${GIT_COMMAND} | grep 'py$' | egrep "${RENAMED_EXPR}" | awk '{print $4}' | xargs ${PEP8_COMMAND}
${GIT_COMMAND} | grep 'py$' | egrep "${NEW_EXPR}" | awk '{print $2}' | xargs ${PEP8_COMMAND}

# pylint checking
echo -e "Running pylint checking .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${MODIFIED_EXPR}" | awk '{print $2}' | xargs ${PYLINT_COMMAND}
${GIT_COMMAND} | grep 'py$' | egrep "${UNTRACKED_EXPR}" | awk '{print $2}' | xargs ${PYLINT_COMMAND}
${GIT_COMMAND} | grep 'py$' | egrep "${RENAMED_EXPR}" | awk '{print $4}' | xargs ${PYLINT_COMMAND}
${GIT_COMMAND} | grep 'py$' | egrep "${NEW_EXPR}" | awk '{print $2}' | xargs ${PYLINT_COMMAND}

# print checking
echo -e "Running checking for print calls .....\n"
${GIT_COMMAND} | grep 'py$' | egrep "${MODIFIED_EXPR}" | awk '{print $2}' | xargs ${PRINT_COMMAND}
${GIT_COMMAND} | grep 'py$' | egrep "${UNTRACKED_EXPR}" | awk '{print $2}' | xargs ${PRINT_COMMAND}
${GIT_COMMAND} | grep 'py$' | egrep "${RENAMED_EXPR}" | awk '{print $4}' | xargs ${PRINT_COMMAND}
${GIT_COMMAND} | grep 'py$' | egrep "${NEW_EXPR}" | awk '{print $2}' | xargs ${PRINT_COMMAND}

# jshint checking
echo -e "Running jshint checking .....\n"
${GIT_COMMAND} | grep 'js$' | egrep "${MODIFIED_EXPR}" | awk '{print $2}' | xargs ${JSHINT_COMMAND}
${GIT_COMMAND} | grep 'js$' | egrep "${UNTRACKED_EXPR}" | awk '{print $2}' | xargs ${JSHINT_COMMAND}
${GIT_COMMAND} | grep 'js$' | egrep "${RENAMED_EXPR}" | awk '{print $4}' | xargs ${JSHINT_COMMAND}
${GIT_COMMAND} | grep 'js$' | egrep "${NEW_EXPR}" | awk '{print $2}' | xargs ${JSHINT_COMMAND}
