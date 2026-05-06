#!/bin/bash
LFS=${LFS:-/mnt/lfs}
RELEASE=${RELEASE:-'sysv'}
XML_PRINT=${XML_PRINT:-'FILE'}

rows="$(stty size | cut -d ' ' -f 1)"
cols=$(expr "$(stty size | cut -d ' ' -f 2)" - 2)
zzreset="\033[0m"
zzred="\033[1;31m"
zzgreen="\033[1;32m"
zzyellow="\033[1;33m"
zzblue="\033[1;34m"
zzpurple="\033[1;35m"
zzcyan="\033[1;36m"
zzwhite="\033[1;37m"

zprint() { echo -e "${zzwhite} *** $* *** ${zzreset}"; }
zstars() { echo -e "${zzblue} $(eval printf "%${cols}s" | tr ' ' '*') ${zzreset}"; }

chroot_pre() {
    zstars
    zprint " === Mounting Virtual Kernel Filesystems === "
    mkdir -pv $LFS/{dev,proc,sys,run}
    mount --types proc /proc $LFS/proc
    mount --rbind /sys $LFS/sys
    mount --make-rslave $LFS/sys
    mount --rbind /dev $LFS/dev
    mount --make-rslave $LFS/dev
    mount --rbind /run $LFS/run
    mount --make-slave $LFS/run

    if [ -h $LFS/dev/shm ]; then
        install -v -d -m 1777 $LFS$(realpath /dev/shm)
    else
        mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
    fi
    if [ ! -f $LFS/etc/resolv.conf ]; then
        printf "nameserver 1.1.1.1\nnameserver 8.8.8.8\n" > $LFS/etc/resolv.conf
    fi
    zstars
}

chroot_exec() {
    zstars
    zprint " === Entering Chroot $LFS === "
    /usr/sbin/chroot "$LFS" \
    /usr/bin/env -i HOME=/root TERM="$TERM" \
    PS1='($?)(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin \
    YBUILD_RELEASE=${RELEASE} \
    XML_PRINT=${XML_PRINT} \
    MAKEFLAGS="-j$(nproc)" \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login
    zprint " === Welcome Back === "
    zstars
}
check_unmount() { mountpoint -q "$1" && umount -v -l "$1"; }

chroot_post() {
    zstars
    zprint " === Un-Mounting Virtual Kernel Filesystems === "
    check_unmount $LFS/sys/firmware/efi/efivars
    check_unmount $LFS/dev
    check_unmount $LFS/run
    check_unmount $LFS/proc
    check_unmount $LFS/sys
    zstars
}

zstars
# checks if directory exists
[ ! -d $LFS ] && { zprint "Error $LFS is not a mountpoint"; exit 1; }

# mounts virtual kernel filesystems
chroot_pre

# enters the new root environment
chroot_exec

# cleans up the virtual kernel filesystems
chroot_post

zstars
