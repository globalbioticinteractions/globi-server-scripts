#!/bin/bash
#
# Reviews all locally cached elton datasets in randomized order.
# 
#  Randomization is introduce in an attempt to prevent one 
#  "bad" dataset to block reviews of others.
# 
set -x
DATASET_DIR=${ELTON_DATASET_DIR:-/var/cache/elton/datasets}
DATASETS_LOCAL=$(elton ls --prov-dir "${DATASET_DIR}" --data-dir "${DATASET_DIR}" --no-progress | sort | uniq | grep -v "^local$" | shuf -)

# first run 10 review in sequence to warm up taxonomic resource caches
echo "$DATASETS_LOCAL"\
 | head\
 | parallel -j1 /var/lib/globinizer/check-dataset.sh {1} ${DATASET_DIR}

# run the rest in parallel against "warm" caches
echo "$DATASETS_LOCAL"\
 | tail -n+10\
 | parallel -j3 /var/lib/globinizer/check-dataset.sh {1} ${DATASET_DIR}
