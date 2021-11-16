#!/usr/bin/env sh
# sync repos every X seconds

set -u

: ${APP_ROOT:?must be set}

SYNC_EVERY=${1:-60}
LOCKFILE="${APP_ROOT}/sync_repos.lock"
LOCKTIMEOUT="300"

function lock(){
	lockfile-create --retry ${LOCKTIMEOUT} ${LOCKFILE} >&2
}

function unlock(){
    lockfile-remove ${LOCKFILE}
}

while true; do
  sleep ${SYNC_EVERY}
  if [[ -e ${APP_ROOT}/data/satis.json ]]; then
  	if lock; then
	    ${APP_ROOT}/bin/satis build ${APP_ROOT}/data/satis.json ${APP_ROOT}/web
	    unlock
	  fi
  fi
done
