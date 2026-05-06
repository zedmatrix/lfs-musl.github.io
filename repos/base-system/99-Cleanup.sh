#!/bin/bash

echo "Starting"

rm -rf /tmp/{*,.*}

find /usr/lib /usr/libexec -name \*.la -delete

find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
find /usr -depth -name $(uname -m)-lfs-linux-musl\* | xargs rm -rf

# userdel -r tester

echo "Done"
