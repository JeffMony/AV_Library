# -fsanitize=address \

CURRENT_DIR=$(pwd)

EXEC_DIR=${CURRENT_DIR}/../../../exec

if [ ! -d ${EXEC_DIR} ]; then
    mkdir ${EXEC_DIR}
fi

OUTPUT_DIR=${CURRENT_DIR}/cmd

if [ ! -d ${OUTPUT_DIR} ]; then
  mkdir ${OUTPUT_DIR}
fi

PROJECT_ROOT_DIR=${CURRENT_DIR}/../../..

OS_NAME=$(uname -s)
CPU_NAME=$(uname -m)

BUILD_MAC_MX() {
  echo "build based on mac m1 or m2"
  OUTPUT_DIR=${CURRENT_DIR}/cmd/mac-mx
  if [ ! -d ${OUTPUT_DIR} ]; then
    mkdir ${OUTPUT_DIR}
  fi
  gcc -o ${OUTPUT_DIR}/media_info ${CURRENT_DIR}/src/media_info.c \
  `pkg-config --cflags --libs libavcodec libavformat libavutil`
}

BUILD_MAC_INTEL() {
  echo "build based on mac intel"
  OUTPUT_DIR=${CURRENT_DIR}/cmd/mac-intel
  if [ ! -d ${OUTPUT_DIR} ]; then
    mkdir ${OUTPUT_DIR}
  fi
  gcc -o ${OUTPUT_DIR}/media_info ${CURRENT_DIR}/src/media_info.c \
  `pkg-config --cflags --libs libavcodec libavformat libavutil`
}

BUILD_LINUX() {
  echo "build based on linux"
  OUTPUT_DIR=${CURRENT_DIR}/cmd/linux
  if [ ! -d ${OUTPUT_DIR} ]; then
    mkdir ${OUTPUT_DIR}
  fi
  DIST_DIR=${PROJECT_ROOT_DIR}/third_party/dist
  gcc -std=c99 \
  -o ${OUTPUT_DIR}/media_info \
  ${CURRENT_DIR}/src/media_info.c \
  -I ${DIST_DIR}/ffmpeg/include \
  -L ${DIST_DIR}/ffmpeg/lib -lavcodec -lavformat -lswresample -lavutil \
  -I ${DIST_DIR}/openssl/include \
  -L ${DIST_DIR}/openssl/lib64 -lssl -lcrypto -lm -lpthread -ldl

  cp -rf ${OUTPUT_DIR}/media_info ${EXEC_DIR}/media_info
}

if [ ${OS_NAME} == 'Darwin' ]; then
  if [ ${CPU_NAME} == 'arm64' ]; then
    BUILD_MAC_MX
  else
    BUILD_MAC_INTEL
  fi
elif [ ${OS_NAME} == 'Linux' ]; then
  BUILD_LINUX
fi
