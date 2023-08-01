#!/bin/bash

# compile libwebp

export ANDROID_NDK_HOME=/Users/jefflee/tools/aandroid-ndk-r22b

CUR_DIR=$(pwd)

PREFIX=${CUR_DIR}/build/libwebp

LIBWEBP_SOURCE_DIR=${CUR_DIR}/libwebp

TOOLCHAIN_PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64

ARCH_OPTIONS=

BUILD_NAME=

BUILD_HOST=

cd ${LIBWEBP_SOURCE_DIR}

init_arm() {
    BUILD_NAME=armeabi-v7a
    BUILD_HOST=arm-linux-androideabi
    ARCH_OPTIONS="--enable-neon --enable-neon-rtcd"
}

init_arm64() {
    BUILD_NAME=arm64-v8a
    BUILD_HOST=aarch64-linux-android
    ARCH_OPTIONS="--enable-neon --enable-neon-rtcd"
}

autoconf() {
    # autoreconf --force --install

    # autoreconf --force --install -I m4

    # autoreconf --install

    # autoreconf --install -I m4

    autoreconf

    # autoreconf -I m4
}

build() {
    PREFIX_NAME=${PREFIX}/${BUILD_NAME}

    rm -rf ${PREFIX_NAME}

    make clean
    make distclean

    autoconf

    ./configure \
    --prefix=${PREFIX_NAME} \
    --with-pic \
    --with-sysroot=${TOOLCHAIN_PATH}/sysroot \
    --enable-static \
    --disable-shared \
    --disable-dependency-tracking \
    --enable-libwebpmux \
    ${ARCH_OPTIONS} \
    --host=${BUILD_HOST}]

    make

    make install
}

clean() {
    rm -rf ${PREFIX}
}

case "$1" in
    arm)
        init_arm
        build
    ;;
    arm64)
        init_arm64
        build
    ;;
    clean)
        clean
    ;;
esac

cd -