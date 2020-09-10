#!/bin/bash
#
# Updates only datasets that are not yet known to local elton cache.
#
CACHE_DIR=${ELTON_DATASET_DIR:=/var/cache/elton/datasets}

DATASETS_ONLINE=$(elton ls --online)
DATASETS_LOCAL=$(elton ls --data-dir ${CACHE_DIR})

DATASETS_NEW=$(diff --changed-group-format='%>' <(${DATASETS_LOCAL}) <(${DATASETS_ONLINE}))

echo ${DATASETS_NEW} | xargs -L1 echo elton update 
