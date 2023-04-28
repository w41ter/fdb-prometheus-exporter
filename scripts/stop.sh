#!/usr/bin/bash
curdir="$(cd "$(dirname $(readlink -f ${BASH_SOURCE[0]}))" &>/dev/null && pwd)"
home="$(
    cd "${curdir}/.."
    pwd
)"

cd ${home}

process=fdb-prometheus-exporter

if [ ! -f ${home}/bin/${process}.pid ]; then
        echo "no ${process}.pid found, process may have been stopped"
        exit -1
fi

pid=`cat ${home}/bin/${process}.pid`
kill -2 ${pid}
rm -f ${home}/bin/${process}.pid
