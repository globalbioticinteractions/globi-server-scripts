#!/bin/bash
#
# exit 1 elton update in progress or no content changed
# exit 0 content changed and no elton update in progress
#
set -x

function is_quiet() {
  local LAST_MODIFIED_AT=$(find . -type f -name access.tsv -printf "%T@\n" | sort -nr | sed 's/\..*//g' | head -1)
  local QUIET_TIME_IN_SECONDS=$(( 20*60 ))
  local QUIET_TIME_IN_SECONDS=$(( 20*60 ))
  local QUIET_TIME_IN_SECONDS=$(( 10 ))
  local SECONDS_SINCE_LAST_CHANGE=$(( $(date +%s) - ${LAST_MODIFIED_AT:=0} ))

  if [ $QUIET_TIME_IN_SECONDS -gt $SECONDS_SINCE_LAST_CHANGE ] 
  then
    echo elton is updating: last change [${SECONDS_SINCE_LAST_CHANGE}]s ago
    exit 1
  fi
}

function content_same() {
  local HASH_OLD=$(cat .elton.state)
  local HASH_NOW=${HASH_OLD:=0}
  local HASH=$(find . -type f | sort | sha256sum | cut -d ' ' -f1)
  echo $HASH > .elton.state
  diff -q <(echo $HASH_NOW) <(echo $HASH)
  SAME_CONTENT=$?
  if [ $SAME_CONTENT == 0 ]
    then
      echo no change
      exit 1
  fi
}

is_quiet
content_same
exit 0
