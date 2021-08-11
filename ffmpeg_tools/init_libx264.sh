#!/bin/bash

# download libx264 source

LIBX264_UPSTREAM=https://code.videolan.org/videolan/x264
BRANCH_NAME=stable

CUR_DIR=$(pwd)

SOURCE_DIR=${CUR_DIR}/sources/libx264

git clone ${LIBX264_UPSTREAM} ${SOURCE_DIR}

cd ${SOURCE_DIR}

git checkout -b ${BRANCH_NAME} origin/${BRANCH_NAME}

cd -