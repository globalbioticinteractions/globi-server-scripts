#!/bin/bash
#
# returns 0 if neo4j is working as expected, 1 otherwise

set -x

echo "CYPHER 2.3 start d = node:datasets('namespace:\"globalbioticinteractions/template-dataset\"') return d.namespace limit 1;"\
 | cypher-shell\
 | grep "template-dataset"

NEO4J_HAPPY=$?
echo $NEO4J_HAPPY

 if [[ ${NEO4J_HAPPY} -eq 0 ]]; then
    echo neo4j is happy: no need to restart
 else
    echo neo4j is not happy: attempt to restart
    echo forcing neo4j index reset
    sudo /var/lib/globi/update-index.sh -f
 fi
