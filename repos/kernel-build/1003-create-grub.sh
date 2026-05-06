#!/bin/bash

source "${PWD}/ybase_header.sh" || { echo "Can Not Base Header"; exit 127; }

codename="Betelgeuse"
kernelversion="7.0.3"
autogrub="true"

DRIVE="/dev/sdb"
PTTYPE="gpt"

[[ $DRIVE =~ 'nvme' ]] && P=p || P=

if [[ $PTTYPE == "gpt" ]]; then
    UEFI=$(blkid -s UUID -o value ${DRIVE}${P}1)
    SWAP=$(blkid -s UUID -o value ${DRIVE}${P}2)
    ROOT=$(blkid -s UUID -o value ${DRIVE}${P}3)
    ROOTPART=$(blkid -s PARTUUID -o value ${DRIVE}${P}3)
else
    ROOT=$(blkid -s UUID -o value ${DRIVE}2)
    ROOTPART=$(blkid -s PARTUUID -o value ${DRIVE}2)
fi

mkdir -pv /boot/grub
if [[ -z $autogrub ]]; then
	cat > /boot/grub/grub.cfg <<BIOEOF
# Begin /boot/grub/grub.cfg
set default=0
set timeout=30

insmod part_gpt
insmod ext2
insmod gfxterm
insmod gfxmenu

set menu_color_normal=cyan/black
set menu_color_highlight=white/blue

search --no-floppy --fs-uuid --set=root UUID=$ROOT
#set gfxpayload=1280x1024x32
set gfxpayload=1024x768x32

menuentry "${codename}, GNU/Linux-${kernelversion}" {
    linux   /boot/vmlinuz-${kernelversion}-zlfs root=PARTUUID=$ROOTPART ro rootfstype=ext4

}
BIOEOF

	if [[ -n $UEFI ]]; then
		cat >> /boot/grub/grub.cfg <<EFIEOF

menuentry "UEFI Firmware Setup" {
    fwsetup
}
EFIEOF
	fi
else
	zprint "Letting GRUB Create Config"
	mkdir -p /etc/default
	cat > /etc/default/grub <<EOFCONF
GRUB_DEFAULT=0
GRUB_TIMEOUT=30
GRUB_DISTRIBUTOR="Betelgeuse"

GRUB_DEVICE_PARTUUID=${ROOTPART}
GRUB_DISABLE_LINUX_PARTUUID=false

GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""
GRUB_THEME="/boot/grub/themes/starfield/theme.txt"
EOFCONF
	[ -f /etc/default/grub ] && zzok " Created: /etc/default/grub "
	grub-mkconfig -o /boot/grub/grub.cfg
fi
[ -f /boot/grub/grub.cfg ] && zzok " Created: /boot/grub/grub.cfg "

if [[ $PTTYPE == "dos" ]]; then
    grub-install --target=i386-pc $DRIVE
elif [[ $PTTYPE == "gpt" ]]; then
    zprint "Mounting EFI Partition ${DRIVE}${P}1 "
    mount --mkdir -v -t vfat ${DRIVE}${P}1 -o codepage=437,iocharset=iso8859-1 /boot/efi
    zprint "Updating UEFI Boot"
    grub-install --target=x86_64-efi --removable
    mountpoint /sys/firmware/efi/efivars || mount -v -t efivarfs efivarfs /sys/firmware/efi/efivars
    grub-install --target=x86_64-efi --bootloader-id=ZLFS --recheck
    efibootmgr | cut -f 1
else
    zerror "Error Installing to Unknown Partition: ${PTTYPE}"
    exit 1
fi
