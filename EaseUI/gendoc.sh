#!/bin/sh

#export LC_ALL = (unset),
LC_ALL="en_US.utf-8"
LANG="en_US.utf-8"
export LC_ALL LANG

ROOT=.
EXPORT_ROOT=${ROOT}/export
DOCROOT=${EXPORT_ROOT}/SDKHelper
INCLUDE_DIR=${EXPORT_ROOT}/include

# reset
rm -rf ${DOCROOT}
mkdir -p ${DOCROOT}

# generate doc
find ${EXPORT_ROOT} -name \*.h -print | xargs headerdoc2html -o ${DOCROOT}

# collect
gatherheaderdoc ${DOCROOT}

exit 0

