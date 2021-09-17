#!/bin/bash
#
# returns 0 if neo4j is working as expected, 1 otherwise

echo "CYPHER 2.3 start d = node:datasets('namespace:\"globalbioticinteractions/template-dataset\"') return d.namespace limit 1;"\
 | cypher-shell\
 | grep "template-dataset"
