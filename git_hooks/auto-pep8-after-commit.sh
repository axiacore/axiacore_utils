#!/bin/sh
  
#
# This git hook fixes pep8 violations after every commit so that
# we can compare, modify and commit the corrections.
#
# Save it as: `.git/hooks/post-commit` 
#
# It's important to notice that we've to have autopep8 installed 
# before running the hook.
# https://pypi.python.org/pypi/autopep8/
#
#   `pip install autopep8`
#
# Read more at:
# http://victorlin.me/posts/2014/02/05/auto-post-commit-pep8-correction
#
FILES=$(git diff HEAD^ HEAD --name-only --diff-filter=ACM | grep -e '\.py$')
 
for f in $FILES
do
    
    # auto pep8 correction
    autopep8 --in-place --ignore=E309,E501,W293 $f
    
done
