#!/bin/bash


# compile ffmpeg only one shared library

export NDK_ROOT=${ANDROID_NDK}

CUR_DIR=$(pwd)

BUILD_DIR=${CUR_DIR}/build

PREFIX=${BUILD_DIR}/ffmpeg-merged

FFMPEG_SOURCE_DIR=${CUR_DIR}/ffmpeg

ARCH_PREFIX=

ARCH=$1

PLATFORM=

HOST=

COMPILE_PLATFORM=

SYSROOT=

CROSS_PREFIX=

OPENSSL_LIB_DIR=

LIBX264_LIB_DIR=

FDKAAC_LIB_DIR=

EXTRA_CFLAGS=

EXTRA_LDFLAGS=

MODULE_DIR="compat libavcodec libavfilter libavformat libavutil libswresample libswscale"

ASM_SUB_MODULE_DIR=

FFMPEG_LOAD_FLAGS=

cd ${FFMPEG_SOURCE_DIR}


# #-----------------------
# # 这儿是编译的选项
# #-----------------------
source ${CUR_DIR}/config/module-audio.sh
# #-----------------------
# #-----------------------


clean() {
    rm -rf ${PREFIX} 
}

init_config() {
    EXTRA_OPTIONS=""
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --disable-shared"
    EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-static"

    EXTRA_OPTIONS="${EXTRA_OPTIONS} ${COMMON_FFMPEG_CONFIG}"
}

build() {

    init_config

    ARCH=$1
    echo "开始编译 ${ARCH} so"

    PLATFORM=$2

    API=$3

    if [ "${ARCH}" == "arm" ];
    then
        HOST=arm-linux
        COMPILE_PLATFORM=$PLATFORM
        ASM_SUB_MODULE_DIR=arm
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-neon"
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-thumb"
        EXTRA_CFLAGS="${EXTRA_CFLAGS} -march=armv7-a -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb"
        FFMPEG_LOAD_FLAGS="${FFMPEG_LOAD_FLAGS} -Wl,--fix-cortex-a8"
    elif [ "${ARCH}" == "arm64" ];
    then
        HOST=aarch64-linux
        COMPILE_PLATFORM=$PLATFORM
        ASM_SUB_MODULE_DIR="aarch64 neon"
    elif [ "${ARCH}" == "x86" ];
    then
        HOST=i686-linux
        COMPILE_PLATFORM=i686-linux-android 
        ASM_SUB_MODULE_DIR=x86
    elif [ "${ARCH}" == "x86_64" ];
    then
        HOST=x86_64-linux
        COMPILE_PLATFORM=x86_64-linux-android
        ASM_SUB_MODULE_DIR=x86
    fi

    ARCH_PREFIX=${PREFIX}/${ARCH}
    rm -rf ${ARCH_PREFIX}
    
    SYSROOT=${NDK_ROOT}/platforms/android-${API}/arch-${ARCH}/
    CROSS_PREFIX=${NDK_ROOT}/toolchains/${PLATFORM}-4.9/prebuilt/darwin-x86_64/bin/${COMPILE_PLATFORM}-

    
    # 判断是否存在openssl
    OPENSSL_LIB_DIR=${BUILD_DIR}/openssl/${ARCH}
    if [ -f "${OPENSSL_LIB_DIR}/lib/libssl.a" ]; then
        echo "OpenSSL detected"
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-nonfree"
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-openssl"
        EXTRA_CFLAGS="${EXTRA_CFLAGS} -I${OPENSSL_LIB_DIR}/include"
        EXTRA_LDFLAGS="${EXTRA_LDFLAGS} -L${OPENSSL_LIB_DIR}/lib -lssl -lcrypto"
    fi

    # 判断是否存在libx264
    LIBX264_LIB_DIR=${BUILD_DIR}/libx264/${ARCH}
    if [ -f "${LIBX264_LIB_DIR}/lib/libx264.a" ]; then
        echo "libx264 detected"
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-libx264"
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-encoder=libx264"
        EXTRA_CFLAGS="${EXTRA_CFLAGS} -I${LIBX264_LIB_DIR}/include"
        EXTRA_LDFLAGS="${EXTRA_LDFLAGS} -L${LIBX264_LIB_DIR}/lib -lx264"
    fi

    # 判断是否存在 fdk-aac
    FDKAAC_LIB_DIR=${BUILD_DIR}/fdk-aac/${ARCH}
    if [ -f "${FDKAAC_LIB_DIR}/lib/libfdk-aac.a" ]; then
        echo "libfdk-aac detected"
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-nonfree"
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-libfdk-aac"
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-encoder=libfdk_aac"
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --enable-muxer=adts"
        EXTRA_CFLAGS="${EXTRA_CFLAGS} -I${FDKAAC_LIB_DIR}/include"
        EXTRA_LDFLAGS="${EXTRA_LDFLAGS} -L${FDKAAC_LIB_DIR}/lib -lfdk-aac -lm"
    fi


    ./configure \
    --prefix=${ARCH_PREFIX} \
    ${EXTRA_OPTIONS} \
    --cross-prefix=${CROSS_PREFIX} \
    --enable-cross-compile \
    --enable-gpl \
    --target-os=android \
    --arch=${ARCH} \
    --sysroot=${SYSROOT} \
    --extra-cflags="${EXTRA_CFLAGS} -fPIE -pie" \
    --extra-ldflags="${EXTRA_LDFLAGS}"

    make clean
    make -j4
    make install

    C_OBJ_FILES=
    ASM_OBJ_FILES=
    for SUB_MODULE_DIR in $MODULE_DIR
    do
        SUB_C_OBJ_FILES=${SUB_MODULE_DIR}/*.o
        if ls ${C_OBJ_FILES} 1> /dev/null 2>&1; then
            echo "link ${SUB_MODULE_DIR}/*.o"
            C_OBJ_FILES="${C_OBJ_FILES} ${SUB_C_OBJ_FILES}"
        fi

        for SUB_DIR in ${ASM_SUB_MODULE_DIR}
        do
            SUB_ASM_OBJ_FILES=${SUB_MODULE_DIR}/${SUB_DIR}/*.o
            if ls ${SUB_ASM_OBJ_FILES} 1> /dev/null 2>&1; then
                echo "link ${SUB_MODULE_DIR}/${SUB_DIR}/*.o"
                ASM_OBJ_FILES="${ASM_OBJ_FILES} ${SUB_ASM_OBJ_FILES}"
            fi
        done
    done
    echo ${SUB_ASM_OBJ_FILES}

    ${CROSS_PREFIX}gcc -lm -lz -shared --sysroot=${SYSROOT} -Wl,--no-undefined -Wl,-z,noexecstack \
    -Wl,-soname,libltpffmpeg.so \
    ${C_OBJ_FILES}   \
    ${ASM_OBJ_FILES} \
    ${EXTRA_LDFLAGS} \
    -o ${ARCH_PREFIX}/libltpffmpeg.so

    echo "完成编译 ${ARCH} so"
}

case "${ARCH}" in
    "")
        build arm arm-linux-androideabi 18
    ;;
    arm)
        build arm arm-linux-androideabi 21
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
