#!/bin/bash
CACHE_DIR=/var/cache
NEO4J_CACHE_DIR=$CACHE_DIR/neo4j
MAVEN_REPO=$HOME/.m2/repository

GRAPH_DB_TAR=$NEO4J_CACHE_DIR/graph.db.tar.gz
GRAPH_DB_TAR_NEW=$NEO4J_CACHE_DIR/graph.db.new.tar.gz

# grab data
cp $MAVEN_REPO/org/eol/eol-globi-datasets/1.0-SNAPSHOT/eol-globi-datasets-1.0-SNAPSHOT-neo4j-graph-db.tar.gz $GRAPH_DB_TAR_NEW 

if diff $GRAPH_DB_TAR $GRAPH_DB_TAR_NEW >/dev/null ; then
  echo File same, no update needed
else
  echo File different updating
  cp $GRAPH_DB_TAR_NEW $GRAPH_DB_TAR
  # figure out how to automatically stop neo4j as non-super user
  #/sbin/service neo4j-service stop
  rm -rf $NEO4J_CACHE_DIR/neo4j/graph.db
  tar -xvf $GRAPH_DB_TAR -C $NEO4J_CACHE_DIR/neo4j
  # figure out how to automatically start neo4j as non-user user
  #/sbin/service neo4j-service start
fi
