#!/bin/bash
# removes files older than 30 days from globi repo
# find ~/.m2/repository/org/eol/* -mtime +30 | xargs rm

set -xe
# create a list of s3 snaphots using some regex
#DATE_PATTERN='\-20200[12345]'
#aws s3 ls globi/snapshot/org/eol/eol-globi-datasets/1.0-SNAPSHOT/ | sed s+^.*eol-+eol-+g | grep "$DATE_PATTERN" | sed 's+^+s3://globi/snapshot/org/eol/eol-globi-datasets/1.0-SNAPSHOT/+g' > aws-delete-candidates.tsv

# remove index snapshots from minio
MINIO_CONFIG="--config-dir /etc/globi/.mc"

mc ${MINIO_CONFIG} ls minio/globi/snapshot/org/eol/eol-globi-datasets/1.0-SNAPSHOT/\
 | grep -o -E "eol-globi-.*[0-9]{8}[.][0-9]{6}-.*$"\
 | sort -r\
 | uniq\
 | tail -n+31\
 | parallel mc ${MINIO_CONFIG} rm minio/globi/snapshot/org/eol/eol-globi-datasets/1.0-SNAPSHOT/{1}

