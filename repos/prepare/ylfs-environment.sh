#!/bin/bash
#
# Usage: source ylfs-environment.sh
#
if [[ -z ${_YLFS_ENVIRONMENT} == "true" ]]; then
_YLFS_ENVIRONMENT=1

set +h
umask 022
LC_ALL=POSIX
#LANG=C.UTF-8

# LFS_TGT=$(uname -m)-lfs-linux-gnu
# YARCH="glibc"

LFS_TGT=$(uname -m)-lfs-linux-musl
YARCH="musl"

LFS="/mnt/lfs"
YBLD="${LFS}/ybuild"
YSRC="${YBLD}/sources"
YREPOS="${YBLD}/repos/crosstools"
# YCHECK=YES
# XML_PRINT=FILE

PATH=/usr/bin:/usr/sbin
if [ ! -L /bin ]; then PATH=/bin:/sbin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
# CFLAGS="-O3 -pipe"
# CXXFLAGS="$CFLAGS"
# LDFLAGS=""

export MAKEFLAGS=-j$(nproc)
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export YSRC YBLD YREPOS YARCH
export CFLAGS CXXFLAGS LDFLAGS
