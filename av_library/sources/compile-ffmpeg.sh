#!/bin/bash


# compile ffmpeg

export NDK_ROOT=${ANDROID_NDK}

CUR_DIR=$(pwd)

BUILD_DIR=${CUR_DIR}/build

PREFIX=${BUILD_DIR}/ffmpeg

FFMPEG_SOURCE_DIR=${CUR_DIR}/ffmpeg

ARCH_PREFIX=

API=24

ARCH=$1

PLATFORM=

HOST=

COMPILE_PLATFORM=

SYSROOT=

CROSS_PREFIX=

OPENSSL_LIB_DIR=

LIBX264_LIB_DIR=

FDKAAC_LIB_DIR=

EXTRA_OPTIONS=

EXTRA_CFLAGS=

EXTRA_LDFLAGS=

cd ${FFMPEG_SOURCE_DIR}


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
	--disable-doc \
	--enable-shared \
	--disable-static \
	--disable-x86asm \
	--disable-asm \
	--disable-symver \
	--disable-devices \
	--disable-avdevice \
	--enable-gpl \
	--disable-ffmpeg \
	--disable-ffplay \
	--disable-ffprobe \
	--enable-small \
	${EXTRA_OPTIONS} \
	--enable-cross-compile \
	--cross-prefix=${CROSS_PREFIX} \
	--target-os=android \
	--arch=${ARCH} \
	--sysroot=${SYSROOT} \
	--extra-cflags="${EXTRA_CFLAGS} -fPIE -pie" \
	--extra-ldflags="${EXTRA_LDFLAGS}"

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
