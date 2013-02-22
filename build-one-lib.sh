#!/bin/sh
SDKVERSION="6.1"
CURRENTPATH=`pwd`
DEVELOPER=`xcode-select --print-path`
LIPO="xcrun -sdk iphoneos lipo"
STRIP="xcrun -sdk iphoneos strip"
ios_toolchain="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
AR="$ios_toolchain"/ar
PLATFORM=""
ARCH=""
FAKE_ARCH=""
FAT_LIB_DIR=${CURRENTPATH}/fat-lib

if [ -d  $FAT_LIB_DIR ]; then
    rm -rf $FAT_LIB_DIR
fi

mkdir $FAT_LIB_DIR

set -e

make_libs_together()
{
    echo "--------------------------"
    echo "Make $ARCH library begin."

    if [ "$ARCH" = "i386" ]; then
        FAKE_ARCH=""
    else
        FAKE_ARCH="-$ARCH"
    fi

    cp "${CURRENTPATH}/cURL/bin/${PLATFORM}${SDKVERSION}${FAKE_ARCH}.sdk/lib/libcurl.a" $FAT_LIB_DIR/libcurl-${ARCH}.a
    cp "${CURRENTPATH}/OpenSSL/bin/${PLATFORM}${SDKVERSION}${FAKE_ARCH}.sdk/lib/libcrypto.a" $FAT_LIB_DIR/libcrypto-${ARCH}.a
    cp "${CURRENTPATH}/OpenSSL/bin/${PLATFORM}${SDKVERSION}${FAKE_ARCH}.sdk/lib/libssl.a" $FAT_LIB_DIR/libssl-${ARCH}.a
    pushd "${FAT_LIB_DIR}"
    # $AR q libcurl-ssl-${ARCH}.a libcrypto-${ARCH}.a libssl-${ARCH}.a libcurl-${ARCH}.a
    
    $AR -x libcrypto-${ARCH}.a
    $AR -x libssl-${ARCH}.a
    $AR -x libcurl-${ARCH}.a

    $AR r libcurl-ssl-${ARCH}.a *.o
    rm -f libcrypto-${ARCH}.a libssl-${ARCH}.a libcurl-${ARCH}.a *.o
    popd

    echo "Make $ARCH library successfuly."
}

PLATFORM="iPhoneSimulator"
ARCH="i386"
make_libs_together

PLATFORM="iPhoneOS"
ARCH="armv7"
make_libs_together

PLATFORM="iPhoneOS"
ARCH="armv7s"
make_libs_together

echo "--------------------------"
#############
# Universal Library
echo "Build universal library..."

$LIPO -create ${FAT_LIB_DIR}/libcurl-ssl-i386.a ${FAT_LIB_DIR}/libcurl-ssl-armv7.a ${FAT_LIB_DIR}/libcurl-ssl-armv7s.a -output ${CURRENTPATH}/libcurl.a
# remove debugging info
$STRIP -S ${CURRENTPATH}/libcurl.a
$LIPO -info ${CURRENTPATH}/libcurl.a

rm -f ${FAT_LIB_DIR}/libcurl-ssl-i386.a ${FAT_LIB_DIR}/libcurl-ssl-armv7.a ${FAT_LIB_DIR}/libcurl-ssl-armv7s.a

echo "--------------------------"
echo "Building libraries done."
