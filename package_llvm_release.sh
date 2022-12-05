#!/usr/bin/env bash
#===-- test-release.sh - Test the LLVM release candidates ------------------===#
#
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
#===------------------------------------------------------------------------===#
#
# Download, build, and test the release candidate for an LLVM release.
#
#===------------------------------------------------------------------------===#

Release=""
BuildDir="`pwd`"
RC=""
Triple=""
use_gzip="no"

function usage() {
    echo "usage: `basename $0` -release X.Y.Z -rc NUM [OPTIONS]"
    echo ""
    echo " -release X.Y.Z       The release version to test."
    echo " -rc NUM              The pre-release candidate number."
    echo " -final               The final release candidate."
    echo " -triple TRIPLE       The target triple for this machine."
    echo " -build-dir DIR       Directory to perform testing in. [default: pwd]"
    echo " -use-gzip            Use gzip instead of xz."
}

while [ $# -gt 0 ]; do
    case $1 in
        -release | --release )
            shift
            Release="$1"
            ;;
        -rc | --rc | -RC | --RC )
            shift
            RC="rc$1"
            ;;
        -final | --final )
            RC=final
            ;;
        -triple | --triple )
            shift
            Triple="$1"
            ;;
        -build-dir | --build-dir | -builddir | --builddir )
            shift
            BuildDir="$1"
            ;;
        -use-gzip | --use-gzip )
            use_gzip="yes"
            ;;
        -help | --help | -h | --h | -\? )
            usage
            exit 0
            ;;
        * )
            echo "unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

function package_release() {
    cwd=`pwd`
    cd $BuildDir/Phase3/Release
    mv llvmCore-$Release-$RC.install/usr/local $Package
    if [ "$use_gzip" = "yes" ]; then
      tar cf - $Package | gzip -9c > $BuildDir/$Package.tar.gz
    else
      tar cf - $Package | xz -9ce > $BuildDir/$Package.tar.xz
    fi
    mv $Package llvmCore-$Release-$RC.install/usr/local
    cd $cwd
}

# Go to the build directory (may be different from CWD)
BuildDir=$BuildDir/$RC
if [ ! -d "$BuildDir/Phase3/Release" ]; then
  echo "ERROR: Invalid build directory"
  exit 1
fi

# Final package name.
Package=clang+llvm-$Release
if [ $RC != "final" ]; then
  Package=$Package-$RC
fi
Package=$Package-$Triple

package_release
