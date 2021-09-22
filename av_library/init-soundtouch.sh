#!/bin/bash

# download soundtouch source

OPENSSL_UPSTREAM=https://gitlab.com/soundtouch/soundtouch
TAG_NAME=2.3.1

CUR_DIR=$(pwd)

SOURCE_DIR=${CUR_DIR}/sources/soundtouch

git clone ${OPENSSL_UPSTREAM} ${SOURCE_DIR}

cd ${SOURCE_DIR}

git checkout -b ${TAG_NAME} ${TAG_NAME}

cd -