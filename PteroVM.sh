#!/bin/sh

#############################
# Linux Installation #
#############################

# Define the root directory to /home/container.
# We can only write in /home/container and /tmp in the container.
ROOTFS_DIR=/home/container

# Detect the machine architecture.
ARCH=$(uname -m)

# Check machine architecture to make sure it is supported.
# If not, we exit with a non-zero status code.
if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}"
  exit 1
fi

# Download & decompress the Linux root file system if not already installed.

if [ ! -e $ROOTFS_DIR/.installed ]; then
echo "#######################################################################################"
echo "#"
echo "#                                  VPSFREE.ES PteroVM"
echo "#"
echo "#                           Copyright (C) 2022 - 2023, VPSFREE.ES"
echo "#"
echo "#"
echo "#######################################################################################"
echo ""
echo "* [0] Debian"
echo "* [1] Ubuntu"
echo "* [2] Alpine"
echo "* [3] Void"
echo "* [4] Fedora"
echo "* [5] Opensuse"

read -p "Enter OS (0-7): " input

case $input in

    0)
    wget --no-hsts -O /tmp/rootfs.tar.gz \
    "https://github.com/termux/proot-distro/releases/download/v3.12.1/debian-${ARCH}-pd-v3.12.1.tar.xz";;

    1)
    wget --no-hsts -O /tmp/rootfs.tar.gz \
    "https://github.com/termux/proot-distro/releases/download/v3.10.0/ubuntu-${ARCH}-pd-v3.10.0.tar.xz";

    2)
    wget --no-hsts -O /tmp/rootfs.tar.gz \
    "https://github.com/termux/proot-distro/releases/download/v3.10.0/alpine-${ARCH}-pd-v3.10.0.tar.xz";;

    3)
    wget --no-hsts -O /tmp/rootfs.tar.gz \
    "https://github.com/termux/proot-distro/releases/download/v3.5.1/void-${ARCH}-pd-v3.5.1.tar.xz";;
    
    4)
    wget --no-hsts -O /tmp/rootfs.tar.gz \
    "https://github.com/termux/proot-distro/releases/download/v3.5.1/fedora-${ARCH}-pd-v3.5.1.tar.xz";;

    5)
    wget --no-hsts -O /tmp/rootfs.tar.gz \
    "https://github.com/termux/proot-distro/releases/download/v3.5.1/opensuse-x86_64-pd-v3.5.1.tar.xz";;
esac

tar -xzf /tmp/rootfs.tar.gz -C $ROOTFS_DIR
fi

PROOT_VERSION="5.3.0" # Some releases do not have static builds attached.



################################
# Package Installation & Setup #
################################

# Download static APK-Tools temporarily because minirootfs does not come with APK pre-installed.
if [ ! -e $ROOTFS_DIR/.installed ]; then
    # Download the packages from their sources.
    wget --no-hsts -O $ROOTFS_DIR/usr/local/bin/proot "https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-${ARCH}-static"
    # Make PRoot executable.
    chmod 755 $ROOTFS_DIR/usr/local/bin/proot
fi

# Clean-up after installation complete & finish up.
if [ ! -e $ROOTFS_DIR/.installed ]; then
    # Add DNS Resolver nameservers to resolv.conf.
    printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > ${ROOTFS_DIR}/etc/resolv.conf
    # Wipe the files we downloaded into /tmp previously.
    rm -rf /tmp/rootfs.tar.gz /tmp/sbin
    # Create .installed to later check whether Alpine is installed.
    touch $ROOTFS_DIR/.installed
fi

# Print some useful information to the terminal before entering PRoot.
# This is to introduce the user with the various Alpine Linux commands.
clear && cat << EOF
Powered by
 __      __        ______             
 \ \    / /       |  ____|            
  \ \  / / __  ___| |__ _ __ ___  ___ 
   \ \/ / '_ \/ __|  __| '__/ _ \/ _ \
    \  /| |_) \__ \ |  | | |  __/  __/
     \/ | .__/|___/_|  |_|  \___|\___|
        | |                           
        |_|                           
______________________________________
EOF

###########################
# Start PRoot environment #
###########################

# This command starts PRoot and binds several important directories
# from the host file system to our special root file system.
$ROOTFS_DIR/usr/local/bin/proot \
--rootfs="${ROOTFS_DIR}" \
-0 -w "/root" -b /dev -b /sys -b /proc -b /lib/systemd/systemd -b /etc/resolv.conf -b /sbin/init --kill-on-exit
/bin/bash
