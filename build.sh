#!/bin/bash

FDB_VERSION=7.1.30
FDB_COMMIT_TAG=94e42d5

mkdir -p root

if [ ! -f ./root/foundationdb-clients_${FDB_VERSION}-1_amd64.deb ]; then
    cd root
    echo "FDB client is missing, download and extract ..."
    wget "https://github.com/apple/foundationdb/releases/download/${FDB_VERSION}/foundationdb-clients_${FDB_VERSION}-1_amd64.deb"
    ar x foundationdb-clients_${FDB_VERSION}-1_amd64.deb
    tar zxvf data.tar.gz
    cd ../
fi

go get github.com/apple/foundationdb/bindings/go@${FDB_COMMIT_TAG}

export CGO_CPPFLAGS="-I`pwd`/root/usr/include"
export CGO_LDFLAGS="-L`pwd`/root/usr/lib"
go build

