#!/bin/bash
#
# Reviews all locally cached elton datasets.
#
set -x
DATASET_DIR=${${ELTON_DATASET_DIR}:-/var/cache/elton/datasets}
DATASETS_LOCAL=$(elton ls --cache-dir "${DATASET_DIR}" --no-progress | sort | uniq | grep -v "^local$")

echo $DATASETS_LOCAL | xargs -L1 -I '{}' echo bash /var/lib/globinizer/check-datasets.sh '{}' ${DATASET_DIR}
