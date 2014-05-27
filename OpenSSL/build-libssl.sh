#!/bin/sh

#  Automatic build script for libssl and libcrypto 
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Felix Schulze on 16.12.10.
#  Copyright 2010 Felix Schulze. All rights reserved.
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
VERSION="1.0.1c"							  #
SDKVERSION="7.1"							  #
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
ios_deploy_version="7.0"

set -e
if [ ! -e openssl-${VERSION}.tar.gz ]; then
	echo "Downloading openssl-${VERSION}.tar.gz"
    curl -O http://www.openssl.org/source/openssl-${VERSION}.tar.gz
else
	echo "Using openssl-${VERSION}.tar.gz"
fi

if [ -d  ${CURRENTPATH}/src ]; then
	rm -rf ${CURRENTPATH}/src
fi

if [ -d ${CURRENTPATH}/bin ]; then
	rm -rf ${CURRENTPATH}/bin
fi

mkdir -p "${CURRENTPATH}/src"
tar zxf openssl-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
cd "${CURRENTPATH}/src/openssl-${VERSION}"

xcode_base="${DEVELOPER}/Platforms"
ios_sdk_root="${DEVELOPER}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.1.sdk"
ios_toolchain="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
ios_sdk_version=${SDKVERSION}

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
echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
echo "Invalid SDK version"
fi
export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure BSD-generic32 --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1
# add -isysroot to CC=
sed -ie "s!^CFLAG=!CFLAG=-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type !" "Makefile"
echo "Make openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make >> "${LOG}" 2>&1
make install >> "${LOG}" 2>&1
make clean >> "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"
#############

#############
# iPhoneOS armv7
ios_arch="armv7"
ARCH=${ios_arch}
PLATFORM="iPhoneOS"
ios_target=${PLATFORM}
echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
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

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure BSD-generic32 --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1

sed -ie "s!^CFLAG=!CFLAG=-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type !" "Makefile"
# remove sig_atomic for iPhoneOS
sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"

echo "Make openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make  "${LOG}" 2>&1
make install  "${LOG}" 2>&1
make clean "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"

#############
# iPhoneOS armv7s
ios_arch="armv7s"
ARCH=${ios_arch}
PLATFORM="iPhoneOS"
ios_target=${PLATFORM}
echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
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

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure BSD-generic64 --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1

sed -ie "s!^CFLAG=!CFLAG=-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type !" "Makefile"
# remove sig_atomic for iPhoneOS
sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"

echo "Make openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make  "${LOG}" 2>&1
make install  "${LOG}" 2>&1
make clean "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"

#############

#############
# iPhoneOS armv64
ios_arch="arm64"
ARCH=${ios_arch}
PLATFORM="iPhoneOS"
ios_target=${PLATFORM}
echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
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

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure BSD-generic32 --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1

sed -ie "s!^CFLAG=!CFLAG=-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type !" "Makefile"
# remove sig_atomic for iPhoneOS
sed -ie "s!static volatile sig_atomic_t intr_signal;!static volatile intr_signal;!" "crypto/ui/ui_openssl.c"

echo "Make openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make  "${LOG}" 2>&1
make install  "${LOG}" 2>&1
make clean "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"


#############
# iPhoneSimulator x86_64
ios_arch="x86_64"
ARCH=${ios_arch}
PLATFORM="iPhoneSimulator"
ios_target=${PLATFORM}
echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
    echo "Invalid SDK version"
fi
export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -D_FORTIFY_SOURCE=0 -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc -arch ${ARCH}"
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-openssl-${VERSION}.log"

echo "Configure openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure darwin64-x86_64-cc --openssldir="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" > "${LOG}" 2>&1

echo "Make openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make  "${LOG}" 2>&1
make install  "${LOG}" 2>&1
make clean "${LOG}" 2>&1

echo "Building openssl for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"

#############
# Universal Library
echo "Build universal library..."

# $LIPO -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libssl.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/lib/libssl.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libssl.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib/libssl.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib/libssl.a -output ${CURRENTPATH}/libssl.a

# $LIPO -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libcrypto.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/lib/libcrypto.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libcrypto.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib/libcrypto.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib/libcrypto.a -output ${CURRENTPATH}/libcrypto.a
# remove debugging info
# $STRIP -S ${CURRENTPATH}/libssl.a
# $LIPO -info ${CURRENTPATH}/libssl.a

# $STRIP -S ${CURRENTPATH}/libcrypto.a
# $LIPO -info ${CURRENTPATH}/libcrypto.a

# mkdir -p ${CURRENTPATH}/include
# cp -R ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/include/openssl ${CURRENTPATH}/include/
# echo "Building done."
# echo "Cleaning up..."
# rm -rf ${CURRENTPATH}/src
# rm -rf ${CURRENTPATH}/bin
echo "Done."
