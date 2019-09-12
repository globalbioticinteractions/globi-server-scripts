#!/bin/sh
RAM_DISK=/var/cache/globi/ramdisk
/bin/umount tmpfs0
/bin/rm -rf $RAM_DISK
/bin/mkdir -p $RAM_DISK
/bin/mount -t tmpfs -o size=10G tmpfs0 $RAM_DISK

# rebuild git repo
/usr/bin/git clone git://github.com/globalbioticinteractions/globalbioticinteractions.git $RAM_DISK/eol-globi-data

# rebuild neo4j database
DATA_VERSION=1.0-SNAPSHOT
/bin/tar xvf /var/cache/globi/repository/org/eol/eol-globi-datasets/$DATA_VERSION/eol-globi-datasets-$DATA_VERSION-neo4j-graph-db.tar.gz -C $RAM_DISK

# rebuild neo4j dark database
/bin/mkdir -p $RAM_DISK/dark
/bin/tar xvf /var/cache/globi/repository/org/eol/eol-globi-datasets-dark/$DATA_VERSION/eol-globi-datasets-dark-$DATA_VERSION-neo4j-graph-db.tar.gz -C $RAM_DISK/dark

/bin/chown -R :ramdisk-users $RAM_DISK
/bin/chmod -R g+rwx $RAM_DISK
