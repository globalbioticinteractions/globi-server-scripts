#!/bin/bash
#
# Updates all datasets.
#
set -x
DATASETS_ONLINE=$(elton ls --online --no-progress | sort | uniq | grep -v --file $GLOBI_LIB_DIR/dataset-excludes.txt)

echo $DATASETS_ONLINE | xargs elton update --no-progress
