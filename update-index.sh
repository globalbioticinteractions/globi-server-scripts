#!/bin/bash
CACHE_DIR=/var/cache

function update {
  neo4j_name=${1:=neo4j}

  NEO4J_CACHE_DIR=$CACHE_DIR/${neo4j_name}

  NEO4J_CACHE_UPDATE_DIR=$CACHE_DIR/${neo4j_name}/update

  MAVEN_REPO=/var/cache/globi/repository

  GRAPH_DB_EXT=zip
  GRAPH_DB_ARCHIVE=$NEO4J_CACHE_DIR/graph.db.$GRAPH_DB_EXT
  GRAPH_DB_ARCHIVE_NEW=$NEO4J_CACHE_DIR/graph.db.new.$GRAPH_DB_EXT

  mkdir -p $NEO4J_CACHE_DIR
  chown neo4j:nogroup $NEO4J_CACHE_DIR

  # grab data
  GRAPH_DB_VERSION="1.1-SNAPSHOT"
  GRAPH_DB_SNAPSHOT="$MAVEN_REPO/org/eol/eol-globi-datasets/${GRAPH_DB_VERSION}/eol-globi-datasets-${GRAPH_DB_VERSION}-neo4j-graph-db.$GRAPH_DB_EXT"

  if diff $GRAPH_DB_ARCHIVE $GRAPH_DB_SNAPSHOT >/dev/null ; then
    echo File same, no update needed
  else
    echo File different updating
    cp $GRAPH_DB_SNAPSHOT $GRAPH_DB_ARCHIVE
    chown neo4j:nogroup $GRAPH_DB_ARCHIVE 
    sudo -u neo4j rm -rf $NEO4J_CACHE_UPDATE_DIR && sudo -u neo4j mkdir -p $NEO4J_CACHE_UPDATE_DIR
    sudo -u neo4j unzip $GRAPH_DB_ARCHIVE -d $NEO4J_CACHE_UPDATE_DIR
    sudo /usr/sbin/service ${neo4j_name} stop
    echo $(date) installing new ${neo4j_name} data index...
    sudo -u neo4j mv $NEO4J_CACHE_DIR/graph.db $NEO4J_CACHE_UPDATE_DIR/graph.db.old
    sudo -u neo4j mv $NEO4J_CACHE_UPDATE_DIR/graph.db $NEO4J_CACHE_DIR/graph.db
    sudo -u neo4j rm -rf $NEO4J_CACHE_UPDATE_DIR/graph.db.old
    echo $(date) installing new ${neo4j_name} data index done.
    sudo /usr/sbin/service ${neo4j_name} start
  fi
}

update neo4j-internal
update neo4j

echo $(date) resetting nginx cache...
sudo rm -rf /var/cache/nginx
sudo /usr/sbin/service nginx restart	
echo $(date) resetting nginx cache done.
