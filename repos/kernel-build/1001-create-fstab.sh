#!/bin/bash

source "${PWD}/ybase_header.sh" || { echo "Can Not Base Header"; exit 127; }
codename="Betelgeuse"
kernelversion="7.0.3"

DRIVE="/dev/sdb"
PTTYPE="gpt"

[[ $DRIVE =~ 'nvme' ]] && P=p || P=

if [[ $PTTYPE == "dos" ]]; then
    SWAP=$(blkid -s UUID -o value ${DRIVE}1)
    ROOT=$(blkid -s UUID -o value ${DRIVE}2)
    ROOTPART=$(blkid -s PARTUUID -o value ${DRIVE}2)
else
    UEFI=$(blkid -s UUID -o value ${DRIVE}${P}1)
    SWAP=$(blkid -s UUID -o value ${DRIVE}${P}2)
    ROOT=$(blkid -s UUID -o value ${DRIVE}${P}3)
    ROOTPART=$(blkid -s PARTUUID -o value ${DRIVE}${P}3)
    UEFI_MNT="UUID=$UEFI /boot/efi   vfat    noauto,codepage=437,iocharset=iso8859-1  0 1"
fi

## create fstab
cat > /etc/fstab <<EOF
# Begin /etc/fstab

# file system  mount-point    type     options             dump  fsck
#                                                                order
EOF

## append sysv header
if [[ ${YBUILD_RELEASE} == "sysv" ]]; then
    cat >> /etc/fstab <<EOF
proc           /proc          proc     nosuid,noexec,nodev 0     0
sysfs          /sys           sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs          /run           tmpfs    defaults            0     0
devtmpfs       /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm       tmpfs    nosuid,nodev        0     0
cgroup2        /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0     0

EOF
fi

## Append drive info
cat >> /etc/fstab <<EOF
UUID=$ROOT      /              ext4     defaults            1     1
UUID=$SWAP      swap           swap     pri=1               0     0
$UEFI_MNT
# End /etc/fstab
EOF

[ -f /etc/fstab ] && zzok " Created: /etc/fstab "

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF
[ -f /etc/modprobe.d/usb.conf ] && zzok " Created: /etc/modprobe.d/usb.conf "

