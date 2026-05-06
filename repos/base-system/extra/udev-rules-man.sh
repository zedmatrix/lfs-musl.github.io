#!/bin/sh

# Install some custom rules and support files useful in an LFS environment:
tar -xvf ${YSRC}/udev-lfs-20230818.tar.xz
make -f udev-lfs-20230818/Makefile.lfs install

# Install the man pages:
tar -xf ${YSRC}/systemd-man-pages-${PKGVER}.tar.xz --no-same-owner \
    --strip-components=1 -C /usr/share/man --wildcards '*/udev*' '*/libudev*' \
    '*/systemd.link.5' '*/systemd-'{hwdb,udevd.service}.8

sed 's|systemd/network|udev/network|' /usr/share/man/man5/systemd.link.5 > /usr/share/man/man5/udev.link.5

sed 's/systemd\(\\\?-\)/udev\1/' /usr/share/man/man8/systemd-hwdb.8 > /usr/share/man/man8/udev-hwdb.8

sed 's|lib.*udevd|sbin/udevd|' /usr/share/man/man8/systemd-udevd.service.8 > /usr/share/man/man8/udevd.8

rm /usr/share/man/man*/systemd*
