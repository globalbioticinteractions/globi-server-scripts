#!/bin/bash
source ~/lock.sh
acquire_lock

source ~/.profile

function export_dataset {
  cd $2
  mvn clean -pl $1 -P$3
  # use ramdisk to improve write IO
  TMP_GRAPH_DB=$1/target/data/
  RAM_GRAPH_DB=/var/cache/globi/ramdisk/graph.db
  RAM_MAP_DB=/var/cache/globi/ramdisk/mapdb
  mkdir -p $TMP_GRAPH_DB
  
  rm -rf $RAM_DB
  mkdir -p $RAM_DB
  ln -s $RAM_GRAPH_DB $TMP_GRAPH_DB
  ln -s $RAM_MAP_DB $TMP_GRAPH_DB
  mvn $4 -pl $1 -P$3
  # remove build results
  mvn clean -pl $1 -P$3
}


function rebuild {
  if [ ! -f $1/.git/description ]; then
	git clone git://github.com/jhpoelen/eol-globi-data.git $1
  fi

  cd $1
  git pull --rebase
  # tests are executed on travis / dev machines
  mvn clean install -pl eol-globi-data-tool -am -DskipTests
  # remove intermediate build results
  mvn clean -pl eol-globi-data-tool -am -DskipTests
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
 # then export it, deploy remotely
 rebuild $1
 export_dataset eol-globi-datasets $1 "generate-datasets,export-all" deploy
}

import_data $RAMDISK
link_data $RAMDISK
export_data $RAMDISK
#export_dataset eol-globi-datasets-dark
release_lock
