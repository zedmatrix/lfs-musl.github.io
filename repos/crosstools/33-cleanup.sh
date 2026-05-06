#!/bin/bash

echo "Cleaning Up Temporary Cross Tools"

rm -rf /usr/share/{info,man,doc}/*

find /usr/{lib,libexec} -name \*.la -delete

rm -rf /tools

echo "Finished Cleaning Up From Temporary Tools"

echo "Backup Temporary LFS-Portage"
cd $LFS
# tar --zstd -cpf /ybuild/lfs-temptools-portage-systemd.tar.zst .

tar --zstd -cpf /musl-build/zlfs-temptools-musl-sysv.tar.zst .
