#!/bin/bash
#
# Updates only datasets that are not yet known to local elton cache.
#
set -x

DATASETS_ONLINE=$(elton ls --online --no-progress | sort | uniq | grep -v "^local$")
DATASETS_LOCAL=$(elton ls --no-progress | sort | uniq | grep -v "^local$")

# note the "!" operator stops the script when no new datasets are found
DATASETS_NEW=$(diff --changed-group-format='%>' --unchanged-group-format='' <(echo -e "${DATASETS_LOCAL}") <(echo -e "${DATASETS_ONLINE}"))

if [ $(echo -en ${DATASETS_NEW} | wc -m) -gt 0 ]
then
  echo "found new datasets"
  echo -e "${DATASETS_NEW}" | xargs elton update --no-progress
  exit 0
else
  echo "no new datasets found: not updating"
  exit 1
fi
