#!/bin/bash
set -e
set -x

# set specific version of GloBI indexer to use
#COMMIT_HASH=3c8cb8ec8fb5facb15b0f16f30afe524a9047583
#COMMIT_HASH=d0a9e8f89b7b34a2a7d40e71ca5d7cb563f0e98e
COMMIT_HASH=main

SETTINGS="--settings /etc/globi/.m2/settings.xml"

function create_tmp_dir {
  rm -rf $1
  mkdir -p $1
  ln -s $1 $2
}

function process_dataset {
  cd $2
  mvn clean -pl $1 -P$3 $SETTINGS
  # use ramdisk to improve write IO
  TMP_DATA_DIR=$1/target/data/
  RAM_GRAPH_DIR=$GLOBI_RAM_DISK/graph.db
  RAM_MAPDB_DIR=$GLOBI_RAM_DISK/mapdb
  mkdir -p $TMP_DATA_DIR
 
  create_tmp_dir $RAM_GRAPH_DIR $TMP_DATA_DIR 
  create_tmp_dir $RAM_MAPDB_DIR $TMP_DATA_DIR
  
  nice mvn $4 -pl $1 -P$3 -Dneo4j.data.dir=$RAM_GRAPH_DIR -Ddataset.dir=${ELTON_DATASET_DIR} $SETTINGS
  # remove build results
  # mvn clean -pl $1 -P$3
}


function rebuild {
  if [ ! -f $1/.git/description ]; then
	git clone git://github.com/globalbioticinteractions/globalbioticinteractions.git $1
  fi

  cd $1
  git pull --rebase
  
  # checkout specific version if provided
  if [ -n "$COMMIT_HASH" ]; then
    git checkout "$COMMIT_HASH"
  fi
  
  # tests are executed on travis / dev machines
  mvn clean install -pl elton4n -am -DskipTests $SETTINGS
  # remove intermediate build results
  mvn clean -pl eol-globi-neo4j-index -am -DskipTests $SETTINGS
}

function import_data {
  # build dataset first, install locally
  rebuild $1
  process_dataset eol-globi-datasets $1 generate-datasets install 
}

function link_data {
  rebuild $1
  # deploy linked data to keep a trace of snapshot versions
  process_dataset eol-globi-datasets $1 "generate-datasets,link" deploy
}

function export_data {
 # then export it, deploy artifacts to remote maven repository
 rebuild $1
 # install data products: this actually custom deploys artifacts, 
 # circumventing the generation of snapshot dated versions
 process_dataset eol-globi-datasets $1 "generate-datasets,export-all" install
}

function deploy_data {
 # then export it, deploy to remove non-repository servers (e.g. ncbi linkout)
 rebuild $1
 process_dataset eol-globi-datasets $1 "generate-datasets,deploy-remote" install
}


import_data $GLOBI_CACHE
link_data $GLOBI_CACHE
export_data $GLOBI_CACHE
#deploy_data $GLOBI_CACHE
