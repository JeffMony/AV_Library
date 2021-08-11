#!/bin/bash

# download fdk-aac source

FDKAAC_UPSTREAM=https://github.com/mstorsjo/fdk-aac
TAG_NAME=v2.0.2

CUR_DIR=$(pwd)

SOURCE_DIR=${CUR_DIR}/sources/fdk-aac

git clone ${FDKAAC_UPSTREAM} ${SOURCE_DIR}

cd ${SOURCE_DIR}

git checkout -b ${TAG_NAME} ${TAG_NAME}

cd -