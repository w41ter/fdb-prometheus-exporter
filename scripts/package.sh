#!/bin/bash

curdir="$(cd "$(dirname $(readlink -f ${BASH_SOURCE[0]}))" &>/dev/null && pwd)"
home="$(
  cd "${curdir}/.."
  pwd
)"

cd ${home}

mkdir -p fdb-exporter/{bin,conf,lib}
cp fdb-prometheus-exporter fdb-exporter/lib/
cp root/usr/lib/libfdb_c.so fdb-exporter/lib/
cp scripts/fdb-exporter.service fdb-exporter/
cp scripts/start.sh fdb-exporter/bin/start.sh
tar zcvf fdb-exporter.tar.gz fdb-exporter
