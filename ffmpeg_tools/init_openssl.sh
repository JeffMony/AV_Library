#!/bin/bash

# download openssl source

OPENSSL_UPSTREAM=https://github.com/openssl/openssl
TAG_NAME=OpenSSL_1_1_1

CUR_DIR=$(pwd)

SOURCE_DIR=${CUR_DIR}/sources/openssl

git clone ${OPENSSL_UPSTREAM} ${SOURCE_DIR}

cd ${SOURCE_DIR}

git checkout -b ${TAG_NAME} ${TAG_NAME}

cd -