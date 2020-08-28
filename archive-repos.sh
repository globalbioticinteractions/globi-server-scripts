#!/bin/bash
#
# Requests GloBI dataset registration repositories to be registered with the https://softwareheritage.org .
#


request_save() {
  curl -XPOST -L --verbose -i "https://archive.softwareheritage.org/api/1/origin/save/git/url/https://github.com/$1"
}

REPOS=$(elton ls --cache-dir=/var/cache/elton/datasets)

REPO_FIRST=$(echo -e "$REPOS" | shuf -n 1)

LIMITS=$(request_save $REPO_FIRST | grep ^X-RateLimit)
REMAINING=$(echo -n "$LIMITS" | grep "Remaining:" | grep -Eo "[0-9]*" | tr -d '\n')


if [ "$REMAINING" -gt 0 ] ; then
  REPOS_TO_SAVE=$(echo -e "$REPOS" | shuf -n $REMAINING)
  echo "requesting softwareheritage.org to archive [$REMAINING] GloBI repos: $REPOS_TO_SAVE"
  #echo -e "$REPOS_TO_SAVE" | xargs -L1 request_save
else
  echo no requests left, skipping archive requests
fi


