#!/bin/bash
CACHE_DIR=/var/cache
NEO4J_CACHE_DIR=$CACHE_DIR/neo4j
MAVEN_REPO=/home/jhpoelen/.m2/repository

GRAPH_DB_EXT=zip
GRAPH_DB_ARCHIVE=$NEO4J_CACHE_DIR/graph.db.$GRAPH_DB_EXT
GRAPH_DB_ARCHIVE_NEW=$NEO4J_CACHE_DIR/graph.db.new.$GRAPH_DB_EXT

# grab data
cp $MAVEN_REPO/org/eol/eol-globi-datasets/1.0-SNAPSHOT/eol-globi-datasets-1.0-SNAPSHOT-neo4j-graph-db.$GRAPH_DB_EXT $GRAPH_DB_ARCHIVE_NEW
chown neo4j:nogroup $GRAPH_DB_ARCHIVE_NEW 

if diff $GRAPH_DB_ARCHIVE $GRAPH_DB_ARCHIVE_NEW >/dev/null ; then
  echo File same, no update needed
else
  echo File different updating
  sudo -u neo4j cp $GRAPH_DB_ARCHIVE_NEW $GRAPH_DB_ARCHIVE
  sudo /usr/sbin/service neo4j stop
  echo $(date) installing new neo4j data index...
  sudo -u neo4j rm -rf $NEO4J_CACHE_DIR/graph.db
  sudo -u neo4j unzip $GRAPH_DB_ARCHIVE -d $NEO4J_CACHE_DIR
  echo $(date) installing new neo4j data index done.
  sudo /usr/sbin/service neo4j start
  echo $(date) resetting nginx cache...
  sudo rm -rf /var/cache/nginx
  sudo /usr/sbin/service nginx restart	
  echo $(date) resetting nginx cache done.
fi
