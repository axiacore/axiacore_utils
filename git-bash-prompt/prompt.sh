#!/bin/bash
BLUE="\[\033[0;34m\]"
BLUE_BOLD="\[\033[1;34m\]"
RED="\[\033[0;31m\]"
RED_BOLD="\[\033[1;31m\]"
GREEN="\[\033[0;32m\]"
GREEN_BOLD="\[\033[1;32m\]"
YELLOW="\[\033[0;33m\]"
YELLOW_BOLD="\[\033[1;33m\]"
BLUE="\[\033[0;34m\]"
BLUE_BOLD="\[\033[1;34m\]"
MAGENTA="\[\033[0;35m\]"
MAGENTA_BOLD="\[\033[1;35m\]"
CYAN="\[\033[0;36m\]"
CYAN_BOLD="\[\033[1;36m\]"
WHITE="\[\033[0;37m\]"
WHITE_BOLD="\[\033[1;37m\]"
GRAY="\[\033[1;30m\]"
NO_COLOUR="\[\033[0m\]"

MAIN_COLOR=$WHITE
SUB_COLOR=$RED
GIT_BR_COLOR=$YELLOW

PRIM_COL=$SUB_COLOR
PRIM_COL_CLEAN=${PRIM_COL#\\[}
PRIM_COL_CLEAN=${PRIM_COL_CLEAN%\\\]}
SEC_COL=$MAIN_COLOR
SEC_COL_CLEAN=${SEC_COL#\\[}
SEC_COL_CLEAN=${SEC_COL_CLEAN%\\]}
GIT_BR_COL_CLEAN=${GIT_BR_COLOR#\\[}
GIT_BR_COL_CLEAN=${GIT_BR_COL_CLEAN%\\]}
YELLOW_CLEAN=${YELLOW#\\[}
YELLOW_CLEAN=${YELLOW_CLEAN%\\]}
GREEN_CLEAN=${GREEN#\\[}
GREEN_CLEAN=${GREEN_CLEAN%\\]}
RED_CLEAN=${RED#\\[}
RED_CLEAN=${RED_CLEAN%\\]}

function get_git_reponame {
    v=`realpath .`
    while [ ! -d "$v/.git" -a "$v" != "/" ]; do
        v=`dirname "$v"`
    done
    if [ ! -d "$v/.git" -a "$v" == "/" ]; then
        echo 
    else
        echo `basename "$v"`
    fi
}

function get_git_branch {
    CURR_BRANCH=$(git branch --no-color 2> /dev/null | grep '\*')
    if test $? -eq 0 ; then
        CURR_BRANCH=$(echo "$CURR_BRANCH" | cut --delimiter=" " --fields=2-)
        if [ "$CURR_BRANCH" == '(no branch)' ]; then
            CURR_BRANCH=$(git show | head -1 | cut --delimiter=" " --fields=2)
        fi
        rn=`get_git_reponame`
        unstaged_changes_format="${YELLOW_CLEAN}*"
        staged_changes_format="${GREEN_CLEAN}*"
        git diff --no-ext-diff --ignore-submodules --quiet --exit-code || unstaged_changes=$unstaged_changes_format
	git diff-index --cached --quiet --ignore-submodules HEAD 2> /dev/null
	(( $? && $? != 128 )) && staged_changes=$staged_changes_format
	if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
		unchecked_changes=""
	else
		unchecked_changes="${RED_CLEAN}*"
	fi

        if [ "x"$rn == "x" ]; then
            echo -e '\['$PRIM_COL_CLEAN:$GIT_BR_COL_CLEAN$CURR_BRANCH$staged_changes$unstaged_changes$unchecked_changes'\]'
        else
            echo -e '\['$PRIM_COL_CLEAN:$GIT_BR_COL_CLEAN$rn$PRIM_COL_CLEAN:$GIT_BR_COL_CLEAN$CURR_BRANCH$staged_changes$unstaged_changes$unchecked_changes'\]'
        fi
    fi
}

PS1="$PRIM_COL[$SEC_COL\h$PRIM_COL\$(get_git_branch)$PRIM_COL:$SEC_COL\W$PRIM_COL]$NO_COLOUR "
