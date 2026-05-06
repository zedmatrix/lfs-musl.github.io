#!/bin/sh

# Remove two unneeded groups, render and sgx, from the default udev rules:
sed -e 's/GROUP="render"/GROUP="video"/' -e 's/GROUP="sgx", //' -i rules.d/50-udev-default.rules.in

# Remove one udev rule requiring a full Systemd installation:
sed -i '/systemd-sysctl/s/^/#/' rules.d/99-systemd.rules.in

# Adjust the hardcoded paths to network configuration files for the standalone udev installation:
sed -e '/NETWORK_DIRS/s/systemd/udev/' -i src/libsystemd/sd-network/network-util.h
