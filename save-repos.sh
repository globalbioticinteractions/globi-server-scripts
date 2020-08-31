#!/bin/bash
#
# Request to save Elton repositories in the https://archive.softwareheritage.org .
#
#


request_save() {
  echo -e "$1" | xargs -L1 -I{} curl -XPOST -L -i "https://archive.softwareheritage.org/api/1/origin/save/git/url/https://github.com/{}"
}

REPOS=$(elton ls --cache-dir=${ELTON_DATASET_DIR:=/var/cache/elton/datasets})

REPO_FIRST=$(echo -e "$REPOS" | shuf -n 1)

LIMITS=$(request_save $REPO_FIRST | grep ^X-RateLimit)
REMAINING=$(echo -n "$LIMITS" | grep "Remaining:" | grep -Eo "[0-9]*" | tr -d '\n')


if [ "$REMAINING" -gt 0 ] ; then
  REPOS_TO_SAVE=$(echo -e "$REPOS" | shuf -n $REMAINING)
  echo "requesting softwareheritage.org to archive [$REMAINING] GloBI repos: $REPOS_TO_SAVE"
  request_save "$REPOS_TO_SAVE"
else
  echo no requests left, skipping archive requests
fi


