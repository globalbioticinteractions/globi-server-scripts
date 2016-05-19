#!/bin/bash
CACHE_DIR=/var/cache
NEO4J_CACHE_DIR=$CACHE_DIR/neo4j
MAVEN_REPO=/home/jhpoelen/.m2/repository

GRAPH_DB_EXT=zip
GRAPH_DB_TAR=$NEO4J_CACHE_DIR/graph.db.$GRAPH_DB_EXT
GRAPH_DB_TAR_NEW=$NEO4J_CACHE_DIR/graph.db.new.$GRAPH_DB_EXT

# grab data
cp $MAVEN_REPO/org/eol/eol-globi-datasets/1.0-SNAPSHOT/eol-globi-datasets-1.0-SNAPSHOT-neo4j-graph-db.$GRAPH_DB_EXT $GRAPH_DB_TAR_NEW
chown neo4j:nogroup $GRAPH_DB_TAR_NEW 

if diff $GRAPH_DB_TAR $GRAPH_DB_TAR_NEW >/dev/null ; then
  echo File same, no update needed
else
  echo File different updating
  sudo -u neo4j cp $GRAPH_DB_TAR_NEW $GRAPH_DB_TAR
  sudo -u neo4j /usr/sbin/service neo4j-service stop
  sudo -u neo4j rm -rf $NEO4J_CACHE_DIR/graph.db
  if [ "$GRAPH_DB_EXT" -eq "zip" ] then
    sudo -u neo4j zip $GRAPH_DB_TAR -d $NEO4J_CACHE_DIR
  else 
    sudo -u neo4j tar -xvf $GRAPH_DB_TAR -C $NEO4J_CACHE_DIR
  fi
  sudo -u neo4j /usr/sbin/service neo4j-service start
  # reset nginx cache
  sudo rm -rf /var/cache/nginx
  sudo /usr/sbin/service nginx restart	
fi
