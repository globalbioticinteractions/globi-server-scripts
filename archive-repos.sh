#!/bin/bash
#
# Requests GloBI dataset registration repositories to be registered with the https://softwareheritage.org .
#


LIMITS=$(curl -i https://archive.softwareheritage.org/api/1/stat/counters/ | grep ^X-RateLimit)
REMAINING=$(echo -n "$LIMITS" | grep "Remaining:" | grep -Eo "[0-9]*" | tr -d '\n')


if [ "$REMAINING" -gt 0 ] ; then
  REPOS=$(elton ls --cache-dir=/var/cache/elton/datasets | shuf -n $REMAINING)
  echo "requesting softwareheritage.org to archive [$REMAINING] GloBI repos: $REPOS"
  echo -e "$REPOS" | xargs -L1 -I{} curl --verbose -XPOST -L --verbose "https://archive.softwareheritage.org/api/1/origin/save/git/url/https://github.com/{}"
else
  echo no requests left, skipping archive requests
fi


