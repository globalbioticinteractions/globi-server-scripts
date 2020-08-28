#!/bin/bash
#
# Requests GloBI dataset registration repositories to be registered with the https://softwareheritage.org .
#

REPOS=$(elton ls --cache-dir=/var/cache/elton/datasets) 

echo -e "$REPOS" | xargs -L1 -I{} curl --verbose -XPOST -L --verbose "https://archive.softwareheritage.org/api/1/origin/save/git/url/https://github.com/{}"
