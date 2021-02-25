#!/bin/bash
#
# Updates only datasets that are not yet known to local elton cache.
#
set -x

DATASETS_ONLINE=$(elton ls --online --no-progress | grep -v --file "${GLOBI_LIB_DIR}/dataset-excludes.txt" | sort | uniq)
DATASETS_LOCAL=$(elton ls --no-progress | grep -v --file "${GLOBI_LIB_DIR}/dataset-excludes.txt" | sort | uniq)

# note the "!" operator stops the script when no new datasets are found
DATASETS_NEW=$(diff --changed-group-format='%>' --unchanged-group-format='' <(echo -e "${DATASETS_LOCAL}") <(echo -e "${DATASETS_ONLINE}"))

if [ $(echo -en ${DATASETS_NEW} | wc -m) -gt 0 ]
then
  echo "found new datasets"
  echo "updating..."
  echo -e "${DATASETS_NEW}" | xargs -L1 elton update --no-progress
  echo "updating... done."
  
  echo "indexing..."
  DATASET_DIR=${ELTON_DATASET_DIR:-/var/cache/elton/datasets}
  echo -e "$DATASETS_NEW" | xargs -L1 -I '{}' /bin/bash /var/lib/globinizer/check-dataset.sh '{}' ${DATASET_DIR}
  echo "indexing... done."
  exit 0
else
  echo "no new datasets found: not updating"
  exit 1
fi
