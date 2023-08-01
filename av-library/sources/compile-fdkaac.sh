#!/bin/bash


# compile fdk-aac

export NDK_ROOT=${ANDROID_NDK}


CUR_DIR=$(pwd)

PREFIX=${CUR_DIR}/build/fdk-aac

FDKAAC_SOURCE_DIR=${CUR_DIR}/fdk-aac

ARCH_PREFIX=

ARCH=$1

PLATFORM=

HOST=

COMPILE_PLATFORM=

SYSROOT=

CROSS_PREFIX=


cd ${FDKAAC_SOURCE_DIR}


clean() {
	rm -rf ${PREFIX} 
}

build() {
	ARCH=$1
	echo "开始编译 ${ARCH} so"

	PLATFORM=$2

	API=$3

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


    ./autogen.sh

    ./configure \
	--prefix=${ARCH_PREFIX} \
	--enable-static \
	--disable-shared \
	--disable-dependency-tracking \
	--with-pic=no \
	--target=android \
	--host=$HOST \
	CC="${CROSS_PREFIX}gcc --sysroot=${SYSROOT}" \
	CXX="${CROSS_PREFIX}g++ --sysroot=${SYSROOT}" \
	RANLIB="${CROSS_PREFIX}ranlib" \
	AR="${CROSS_PREFIX}ar" \
	STRIP="${CROSS_PREFIX}strip" \
	NM="${CROSS_PREFIX}nm" \
	CFLAGS="-O3 --sysroot=${SYSROOT}" \
	CXXFLAGS="-O3 --sysroot=${SYSROOT}"

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