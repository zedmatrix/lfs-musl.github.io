#!/bin/bash

source ${PWD}/ybase_header.sh || { echo "Can Not Base Header"; exit 1; }

zstars

DRIVE=""
case $1 in
    sd[a-z]|vd[a-z]|hd[a-z]|nvme[0-9]n[0-9])
        DRIVE="/dev/${1}"
        [ -b $DRIVE ] || bad_drive
        ;;
    [?])
        echo "Usage: $0 [sda | vda | hda | nvme] [uefi] [force]" >&2
        exit 1
        ;;
esac
[ -b $DRIVE ] && echo "Install Drive: $DRIVE " || bad_drive

ROOTPATH="/usr/sbin"
PATH=${ROOTPATH}:${PATH}

# Check Drive
pttype=$(lsblk -n -o PTTYPE $DRIVE | head -1)
zprint "Drive: $DRIVE - Partition Type: $pttype "
[[ $DRIVE =~ 'nvme' ]] && P=p || P=

if [[ $pttype == "dos" ]]; then
    SWAP="${DRIVE}1"
    ROOT="${DRIVE}2"
    zprint " Assuming (SWAP:${SWAP}) (ROOT:${ROOT}) "
else
    UEFI="${DRIVE}${P}1"
    SWAP="${DRIVE}${P}2"
    ROOT="${DRIVE}${P}3"
    zprint " Assuming (UEFI:${UEFI}) (SWAP:${SWAP}) (ROOT:${ROOT}) "
fi

# Mount ROOT partition if not already mounted
if ! mountpoint -q "$LFS"; then
    zprint " Mounting ${ROOT} to ${LFS} "
    mount -v --mkdir "$ROOT" "$LFS" || {
        zerror " Failed to mount ${ROOT} to ${LFS} "
        exit 1
    }
    chown -v root:root $LFS
    chmod -v 755 $LFS
else
    zprint "${LFS} is already mounted."
fi

[[ -n ${SWAP} ]] && /sbin/swapon ${SWAP} || { zerror " Failed to Activate ${SWAP} Swap "; exit 1; }

# Setup yaml-builder paths
mkdir -pv $LFS/ybuild/{tmp,log,repos,sources}

# Setup LFS Limited directories
mkdir -pv $LFS/{etc,var,tools} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  [ ! -e "$LFS/$i" ] && ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac
