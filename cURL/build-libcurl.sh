#!/bin/sh

#  Automatic build script for libcurl 
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Miyabi Kazamatsuri on 19.04.11.
#  Copyright 2011 Miyabi Kazamatsuri. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#  Change values here							  #
#									  #
VERSION="7.26.0"							  #
SDKVERSION="6.0"							  #
OPENSSL="${PWD}/../OpenSSL"						  #
#									  #
###########################################################################
#									  #
# Don't change anything under this line!				  #
#									  #
###########################################################################

CURRENTPATH=`pwd`
DEVELOPER=`xcode-select --print-path`

LIPO="xcrun -sdk iphoneos lipo"
STRIP="xcrun -sdk iphoneos strip"

# test for Xcode 4.3+
if ! test -d "${DEVELOPER}/Platforms" ; then
    echo "You must install Xcode first from the App Store"
fi

xcode_base="${DEVELOPER}/Platforms"
ios_sdk_root=""
ios_toolchain="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
ios_sdk_version=${SDKVERSION}

set -e
if [ ! -e curl-${VERSION}.tar.gz ]; then
	echo "Downloading curl-${VERSION}.tar.gz"
    curl -O http://curl.haxx.se/download/curl-${VERSION}.tar.gz
else
	echo "Using curl-${VERSION}.tar.gz"
fi

if [ -d  ${CURRENTPATH}/src ]; then
	rm -rf ${CURRENTPATH}/src
fi

if [ -d ${CURRENTPATH}/bin ]; then
	rm -rf ${CURRENTPATH}/bin
fi

mkdir -p "${CURRENTPATH}/src"
tar zxf curl-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
cd "${CURRENTPATH}/src/curl-${VERSION}"


# set the compilers
export AS="$ios_toolchain"/as
export CC="$ios_toolchain"/clang
export CXX="$ios_toolchain"/clang++
export CPP="$ios_toolchain/clang -E"
export LD="$ios_toolchain"/ld
export AR="$ios_toolchain"/ar
export RANLIB="$ios_toolchain"/ranlib
export STRIP="$ios_toolchain"/strip

############
# iPhone Simulator
ios_arch=i386
ARCH=${ios_arch}
PLATFORM="iPhoneSimulator"
ios_target=${PLATFORM}
echo "Building libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
    echo "Invalid SDK version"
fi

export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc"
#export CFLAGS="-arch ${ARCH} -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk -I${OPENSSL}/include -L${OPENSSL}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}.sdk/build-libcurl-${VERSION}.log"

echo "Configure libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure -prefix=${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}.sdk -disable-shared -with-random=/dev/urandom --without-ssl --without-libssh2 # --with-ssl # > "${LOG}" 2>&1

echo "Make libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make # >> "${LOG}" 2>&1
make install # >> "${LOG}" 2>&1
make clean #>> "${LOG}" 2>&1

echo "Building libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"

#############

#############
# iPhoneOS armv7
ios_arch="armv7"
ARCH=${ios_arch}
PLATFORM="iPhoneOS"
ios_target=${PLATFORM}

echo "Building libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
    echo "Invalid SDK version"
fi

export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc"
#export CFLAGS="-arch ${ARCH} -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk -I${OPENSSL}/include -L${OPENSSL}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-libcurl-${VERSION}.log"

echo "Configure libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure -prefix=${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk --host=${ARCH}-apple-darwin --disable-shared -with-random=/dev/urandom --without-ssl --without-libssh2 # --with-ssl # > "${LOG}" 2>&1

echo "Make libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make # >> "${LOG}" 2>&1
make install # >> "${LOG}" 2>&1
make clean # >> "${LOG}" 2>&1

echo "Building libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"
#############

#############
# iPhoneOS armv7s
ios_arch="armv7s"
ARCH=${ios_arch}
PLATFORM="iPhoneOS"
ios_target=${PLATFORM}

echo "Building libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
    echo "Invalid SDK version"
fi

export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc"
#export CFLAGS="-arch ${ARCH} -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk -I${OPENSSL}/include -L${OPENSSL}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-libcurl-${VERSION}.log"

echo "Configure libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure -prefix=${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk --host=${ARCH}-apple-darwin --disable-shared -with-random=/dev/urandom --without-ssl --without-libssh2 # --with-ssl # > "${LOG}" 2>&1

echo "Make libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make # >> "${LOG}" 2>&1
make install # >> "${LOG}" 2>&1
make clean # >> "${LOG}" 2>&1

echo "Building libcurl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"
#############

#############
# Universal Library
echo "Build universal library..."

$LIPO -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}.sdk/lib/libcurl.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libcurl.a  ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib/libcurl.a -output ${CURRENTPATH}/libcurl.a
# remove debugging info
$STRIP -S ${CURRENTPATH}/libcurl.a
$LIPO -info ${CURRENTPATH}/libcurl.a
    
mkdir -p ${CURRENTPATH}/include
cp -R ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}.sdk/include/curl ${CURRENTPATH}/include/
echo "Building all steps done."
echo "Cleaning up..."
rm -rf ${CURRENTPATH}/src
rm -rf ${CURRENTPATH}/bin
echo "Done."
