#!/bin/bash

# compile openssl

export NDK_ROOT=${ANDROID_NDK}

CUR_DIR=$(pwd)

PREFIX=${CUR_DIR}/build/openssl

OPENSSL_SOURCE_DIR=${CUR_DIR}/openssl

ARCH_PREFIX=

ARCH=$1

PLATFORM=


cd ${OPENSSL_SOURCE_DIR}


clean() {
    rm -rf ${PREFIX} 
}

build() {
    ARCH=$1
    echo "开始编译 ${ARCH} so"
    PLATFORM=$2

    API=$3

    ARCH_PREFIX=${PREFIX}/${ARCH}
    rm -rf ${ARCH_PREFIX}
    
    PATH=${NDK_ROOT}/toolchains/${PLATFORM}-4.9/prebuilt/darwin-x86_64/bin:${PATH}

    ./Configure \
    android-${ARCH} \
    -D__ANDROID_API__=24 \
    no-shared \
    no-ssl3 \
    no-comp \
    no-hw \
    no-engine \
    --prefix=${ARCH_PREFIX} \
    --openssldir=${ARCH_PREFIX}


    make clean
    make -j4
    make install
    echo "完成编译 ${ARCH} so"
}

case "${ARCH}" in
    "")
        build arm arm-linux-androideabi 18
    ;;
    arm)
        build arm arm-linux-androideabi 18
    ;;
    arm64)
        build arm64 aarch64-linux-android 21
    ;;
    x86)
        build x86 x86 18
    ;;
    x86_64)
        build x86_64 x86_64 21
    ;;
    all)
        build arm arm-linux-androideabi 18
        build arm64 aarch64-linux-android 21
        build x86 x86 18
        build x86_64 x86_64 21
    ;;
    clean)
         clean
    ;;
esac


cd -