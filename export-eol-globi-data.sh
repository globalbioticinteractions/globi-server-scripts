#!/bin/bash
source ~/lock.sh
acquire_lock

source ~/.profile

function create_tmp_dir {
  rm -rf $1
  mkdir -p $1
  ln -s $1 $2
}

function export_dataset {
  cd $2
  mvn clean -pl $1 -P$3
  # use ramdisk to improve write IO
  TMP_DATA_DIR=$1/target/data/
  RAM_GRAPH_DIR=/var/cache/globi/ramdisk/graph.db
  RAM_MAPDB_DIR=/var/cache/globi/ramdisk/mapdb
  mkdir -p $TMP_DATA_DIR
 
  create_tmp_dir $RAM_GRAPH_DIR $TMP_DATA_DIR 
  create_tmp_dir $RAM_MAPDB_DIR $TMP_DATA_DIR
  
  nice mvn $4 -pl $1 -P$3 -Dneo4j.data.dir=$RAM_GRAPH_DIR -Dgithub.client.id=$GITHUB_CLIENT_ID -Dgithub.client.secret=$GITHUB_CLIENT_SECRET -Ddataset.dir=${ELTON_DATASET_DIR}
  # remove build results
  # mvn clean -pl $1 -P$3
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
 # then export it, deploy artifacts to remote maven repository
 rebuild $1
 export_dataset eol-globi-datasets $1 "generate-datasets,export-all" deploy
}

function deploy_data {
 # then export it, deploy to remove non-repository servers (e.g. ncbi linkout)
 rebuild $1
 export_dataset eol-globi-datasets $1 "generate-datasets,deploy-remote" install
}


import_data $RAMDISK
link_data $RAMDISK
export_data $RAMDISK
#deploy_data $RAMDISK
release_lock
