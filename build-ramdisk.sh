#!/bin/sh
RAM_DISK=/var/cache/globi/ramdisk
/bin/umount tmpfs0
/bin/rm -rf $RAM_DISK
/bin/mkdir -p $RAM_DISK
/bin/mount -t tmpfs -o size=24G tmpfs0 $RAM_DISK

/bin/chown -R globi:globi $RAM_DISK
/bin/chmod -R g+rwx $RAM_DISK
