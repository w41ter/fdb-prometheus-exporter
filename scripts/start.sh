#!/bin/bash

curdir="$(cd "$(dirname $(readlink -f ${BASH_SOURCE[0]}))" &>/dev/null && pwd)"
home="$(
  cd "${curdir}/.."
  pwd
)"

cd ${home}

CLUSTER_FILE=${CLUSTER_FILE:-/mnt/foundationdb/fdb.cluster}
if [ ! -f ${CLUSTER_FILE} ]; then
    echo "fdb cluster file ${CLUSTER_FILE} is not exists"
    exit -1
fi

if [[ ! -d bin || ! -d lib ]]; then
  echo "$0 must be invoked at the directory which contains bin and lib"
  exit -1
fi

process=fdb-prometheus-exporter

if [ -f ${home}/bin/${process}.pid ]; then
  pid=$(cat ${home}/bin/${process}.pid)
  if [ "${pid}" != "" ]; then
    ps axu | grep "$pid" 2>&1 | grep fdb-prometheus-exporter > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "pid file existed, ${process} have already started, pid=${pid}"
      exit -1;
    fi
  fi
  echo "pid file existed but process not alive, remove it, pid=${pid}"
  rm -f ${home}/bin/${process}.pid
fi

lib_path=${home}/lib
bin=${home}/lib/fdb-prometheus-exporter
ldd ${bin} | grep -Ei 'libfdb_c.*not found' &> /dev/null
if [ $? -eq 0 ]; then
  if ! command -v patchelf &> /dev/null; then
    echo "patchelf is needed to launch meta_service"
    exit -1
  fi
  patchelf --set-rpath ${lib_path} ${bin}
  ldd ${bin}
fi

export FDB_API_VERSION="710"
export FDB_CLUSTER_FILE=${home}/fdb.cluster
export FDB_EXPORT_WORKLOAD="true"
export FDB_EXPORT_DATABASE_STATUS="true"
export FDB_EXPORT_CONFIGURATION="true"
export FDB_EXPORT_PROCESSES="true"
export FDB_METRICS_LISTEN=":5003"

# Overwrite configs
if [ -f ${home}/conf/config.sh ]; then
    source ${home}/conf/config.sh
fi

# Setup the cluster file
cp ${CLUSTER_FILE} ${FDB_CLUSTER_FILE}

exec ${bin}
