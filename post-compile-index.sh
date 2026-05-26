#!/bin/bash
#
# post compile steps of GloBI neo4j index and associated data products build process: link, summarize and export.
# 
# also see compile-index.sh
#
set -e
set -x

SCRIPT_DIR=$(dirname $(readlink -f $0))

source "${SCRIPT_DIR}/process-index.sh"

#import_data $GLOBI_CACHE
link_data $GLOBI_CACHE
summarize_data $GLOBI_CACHE
export_data $GLOBI_CACHE
#deploy_data $GLOBI_CACHE
