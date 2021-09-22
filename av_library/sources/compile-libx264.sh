#!/bin/bash


# compile libx264

export NDK_ROOT=${ANDROID_NDK}


CUR_DIR=$(pwd)

PREFIX=${CUR_DIR}/build/libx264

LIBX264_SOURCE_DIR=${CUR_DIR}/libx264

ARCH_PREFIX=

API=24

ARCH=$1

PLATFORM=

HOST=

COMPILE_PLATFORM=

SYSROOT=

CROSS_PREFIX=


cd ${LIBX264_SOURCE_DIR}


clean() {
	rm -rf ${PREFIX} 
}

build() {
	ARCH=$1
	echo "开始编译 ${ARCH} so"

	PLATFORM=$2

	if [ "${ARCH}" == "arm" ];
	then
		HOST=arm-linux
    	COMPILE_PLATFORM=$PLATFORM
	elif [ "${ARCH}" == "arm64" ];
	then
		HOST=aarch64-linux
    	COMPILE_PLATFORM=$PLATFORM
	elif [ "${ARCH}" == "x86" ];
	then
		HOST=i686-linux
    	COMPILE_PLATFORM=i686-linux-android	
	elif [ "${ARCH}" == "x86_64" ];
	then
		HOST=x86_64-linux
    	COMPILE_PLATFORM=x86_64-linux-android
	fi
	
	ARCH_PREFIX=${PREFIX}/${ARCH}
	rm -rf ${ARCH_PREFIX}
	
	SYSROOT=${NDK_ROOT}/platforms/android-${API}/arch-${ARCH}/
    CROSS_PREFIX=${NDK_ROOT}//toolchains/${PLATFORM}-4.9/prebuilt/darwin-x86_64/bin/${COMPILE_PLATFORM}-

	./configure \
	--prefix=${ARCH_PREFIX} \
	--host=${HOST} \
	--enable-static \
	--enable-pic \
	--enable-strip \
	--disable-cli \
	--disable-opencl \
	--disable-interlaced \
	--disable-avs \
	--disable-swscale \
	--disable-lavf \
	--disable-ffms \
	--disable-asm \
	--disable-gpac \
	--cross-prefix=${CROSS_PREFIX} \
	--sysroot=${SYSROOT}


    make clean
    make -j4
    make install
    echo "完成编译 ${ARCH} so"
}

case "${ARCH}" in
	"")
        build arm arm-linux-androideabi
    ;;
    arm)
        build arm arm-linux-androideabi
    ;;
    arm64)
        build arm64 aarch64-linux-android
    ;;
    x86)
        build x86 x86
    ;;
    x86_64)
        build x86_64 x86_64
    ;;
    all)
        build arm arm-linux-androideabi
        build arm64 aarch64-linux-android
        build x86 x86
        build x86_64 x86_64
    ;;
    clean)
         clean
    ;;
esac


cd -