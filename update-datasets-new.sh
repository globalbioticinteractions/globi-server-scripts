#!/bin/bash
#
# Updates only datasets that are not yet known to local elton cache.
#
set -xe
CACHE_DIR=${ELTON_DATASET_DIR:=/var/cache/elton/datasets}

DATASETS_ONLINE=$(elton ls --online | sort | uniq | grep -v "^local$")
DATASETS_LOCAL=$(elton ls --cache-dir ${CACHE_DIR} | sort | uniq | grep -v "^local$")

# note the "!" operator stops the script when no new datasets are found
DATASETS_NEW=$(diff --changed-group-format='%>' --unchanged-group-format='' <(echo -e "${DATASETS_LOCAL}") <(echo -e "${DATASETS_ONLINE}") && true)

if [ $(echo -e ${DATASETS_NEW} | wc -l) -gt 0 ]
then
  echo "found new datasets"
  echo -e "${DATASETS_NEW}" | xargs elton update
else
  echo "no new datasets found: not updating"
fi
