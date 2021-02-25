#!/bin/bash
#
# Updates all datasets.
#
set -x
DATASETS_ONLINE=$(elton ls --online --no-progress | sort | uniq | grep -v --file dataset-excludes.txt)

echo $DATASETS_ONLINE | xargs elton update --no-progress
