#!/bin/bash
set -e
set -x

SETTINGS="--settings /etc/globi/.m2/settings.xml"

function create_tmp_dir {
  rm -rf $1
  mkdir -p $1
  ln -s $1 $2
}

function export_dataset {
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
  # tests are executed on travis / dev machines
  mvn clean install -pl eol-globi-neo4j-index -am -DskipTests $SETTINGS
  # remove intermediate build results
  mvn clean -pl eol-globi-neo4j-index -am -DskipTests $SETTINGS
}

function import_data {
  # build dataset first, install locally
  rebuild $1
  export_dataset eol-globi-datasets $1 generate-datasets install 
}

function link_data {
  rebuild $1
  export_dataset eol-globi-datasets $1 "generate-datasets,link" install
}

function export_data {
 # then export it, deploy artifacts to remote maven repository
 rebuild $1
 export_dataset eol-globi-datasets $1 "generate-datasets,export-all" deploy
}

function deploy_data {
 # then export it, deploy to remove non-repository servers (e.g. ncbi linkout)
 rebuild $1
 export_dataset eol-globi-datasets $1 "generate-datasets,deploy-remote" install
}


import_data $GLOBI_CACHE
link_data $GLOBI_CACHE
export_data $GLOBI_CACHE
#deploy_data $GLOBI_CACHE
