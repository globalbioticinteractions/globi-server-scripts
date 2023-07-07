#!/bin/bash
#
# Reviews all locally cached elton datasets.
#
set -x
DATASET_DIR=${ELTON_DATASET_DIR:-/var/cache/elton/datasets}
DATASETS_LOCAL=$(elton ls --cache-dir "${DATASET_DIR}" --no-progress | sort | uniq | grep -v "^local$")

# first run 10 review in sequence to warm up taxonomic resource caches
echo "$DATASETS_LOCAL"\
 | head\
 | parallel -j1 /var/lib/globinizer/check-dataset.sh {1} ${DATASET_DIR}

# run the rest in parallel against "warm" caches
echo "$DATASETS_LOCAL"\
 | tail -n+10\
 | parallel -j3 /var/lib/globinizer/check-dataset.sh {1} ${DATASET_DIR}
