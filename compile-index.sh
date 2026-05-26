#!/bin/bash
#
# compiles index from associated GloBI indexed datasets
# 
# also see post-compile-index.sh
#

set -e
set -x

SCRIPT_DIR=$(dirname $(readlink -f $0))

source "${SCRIPT_DIR}/process-index.sh"

import_data $GLOBI_CACHE
