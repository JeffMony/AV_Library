#!/bin/bash

# download ffmpeg source

FFMPEG_UPSTREAM=https://github.com/FFmpeg/FFmpeg
TAG_NAME=n4.0.3

CUR_DIR=$(pwd)

SOURCE_DIR=${CUR_DIR}/sources/ffmpeg

git clone ${FFMPEG_UPSTREAM} ${SOURCE_DIR}

cd ${SOURCE_DIR}

git checkout -b ${TAG_NAME} ${TAG_NAME}

cd -