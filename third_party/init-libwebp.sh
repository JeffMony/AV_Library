#!/bin/bash

# download libwebp source 

LIBWEBP_UPSTREAM=https://chromium.googlesource.com/webm/libwebp
TAG_NAME=v1.3.1

CUR_DIR=$(pwd)

SOURCE_DIR=${CUR_DIR}/sources/libwebp

git clone ${LIBWEBP_UPSTREAM} ${SOURCE_DIR}

cd ${SOURCE_DIR}

git checkout -b ${TAG_NAME} ${TAG_NAME}

cd -