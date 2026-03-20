#!/bin/sh

set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=x86_64-lfs-linux-musl
CFLAGS="-O2 -pipe"
CXXFLAGS="-O2 -pipe"

export PATH=$LFS/tools/bin:$PATH
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export CFLAGS CXXFLAGS

xtar() {
    [ -z "$1" ] && { echo "Requires Package Name. Exiting."; return 1; }
    local file="$1"
    local dir
    dir=$(tar -tf "$file" | head -1 | cut -d'/' -f1)
    tar -xf "$file" || { echo "Tar extraction failed"; return 1; }
    cd "$dir" || { echo "Failed to cd into $dir"; return 1; }
}
export -f xtar

mcd() {
	mkdir -v $1
	cd $1
}
export -f mcd
