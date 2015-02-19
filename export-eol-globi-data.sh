source ~/lock.sh
acquire_lock

source ~/.bashrc

function export_dataset {
  cd $2
  mvn clean $4 -pl $1 -P$3
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

function build_dataset {
  # build dataset first, install locally
  rebuild $RAMDISK
  export_dataset eol-globi-datasets $RAMDISK generate-datasets install
}

function export_data {
 # then export it, deploy remotely
 EXPORT_CACHE=/var/cache/globi/exports
 rebuild $EXPORT_CACHE
 export_dataset eol-globi-datasets $EXPORT_CACHE "generate-datasets,export-all" deploy
}

build_dataset
export_data
#export_dataset eol-globi-datasets-dark
release_lock
