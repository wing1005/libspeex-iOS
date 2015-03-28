#!/bin/sh

#source ./env.shi

VERSION="1.3.2"
SDKVERSION="8.2"
LIB="libogg"

DEVELOPER=`xcode-select -print-path`
ARCHS="i386 x86_64 armv7 armv7s arm64"
CURRENTPATH=`pwd`
BUILD="x86_64-apple-darwin11"
OLD_PATH=$PATH

cd ${LIB}-${VERSION}

for ARCH in ${ARCHS}
do
    case "${ARCH}" in
        "i386"|"x86_64")
            PLATFORM="iPhoneSimulator"
            HOST="${ARCH}-apple-darwin11"
            ;;
        "arm64")
            PLATFORM="iPhoneOS"
            HOST="aarch64-apple-darwin11"
            ;;
        *)
            PLATFORM="iPhoneOS"
            HOST="${ARCH}-apple-darwin11"
            ;;
    esac

    SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"

    export IPHONEOS_DEPLOYMENT_TARGET=6.0
    export CC="clang -arch ${ARCH} -isysroot ${SDK} -miphoneos-version-min=6.0"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="$CFLAGS"
    export LD=$CC

    PREFIX="${CURRENTPATH}/build/${LIB}/${ARCH}"

    mkdir -p ${PREFIX}

    echo "Please stand by..."

    ./configure --prefix=$PREFIX --host=${HOST} -build=${BUILD} 

    make clean
    make && make install

    echo "======== CHECK ARCH ========"
    lipo -info ${PREFIX}/lib/${LIB}.a
    echo "======== CHECK DONE ========"

done

echo " == Copy headers to fat folder from i386 folder AND clean files in lib =="
cp -r ${CURRENTPATH}/build/${LIB}/i386/ ${CURRENTPATH}/build/${LIB}/Fat
rm -rf ${CURRENTPATH}/build/${LIB}/Fat/lib/*

echo "Build library..."
lipo -create ${CURRENTPATH}/build/${LIB}/i386/lib/${LIB}.a ${CURRENTPATH}/build/${LIB}/x86_64/lib/${LIB}.a ${CURRENTPATH}/build/${LIB}/arm64/lib/${LIB}.a ${CURRENTPATH}/build/${LIB}/armv7/lib/${LIB}.a ${CURRENTPATH}/build/${LIB}/armv7s/lib/${LIB}.a -output ${CURRENTPATH}/build/${LIB}/Fat/lib/${LIB}.a

echo "======== CHECK FAT ARCH ========"
lipo -info ${CURRENTPATH}/build/${LIB}/Fat/lib/${LIB}.a
echo "======== CHECK DONE ========"

echo "== Done =="
