#!/bin/bash
#
# Updates all datasets.
#
set -x

elton ls --online --no-progress\
| grep -v --file "$GLOBI_LIB_DIR/dataset-excludes.txt"\
| sort\
| uniq\
| xargs -L1 elton update --no-progress
