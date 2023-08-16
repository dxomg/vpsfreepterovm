#!/bin/sh

#############################
# Linux Installation #
#############################

# Define the root directory to /home/container.
# We can only write in /home/container and /tmp in the container.
ROOTFS_DIR=/home/container

export PATH=$PATH:~/.local/usr/bin

PROOT_VERSION="5.3.0" # Some releases do not have static builds attached.

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

read -p "Enter OS (0-3): " input

case $input in

    0)
    wget --no-hsts -O /tmp/rootfs.tar.xz \
    "https://github.com/termux/proot-distro/releases/download/v3.10.0/debian-${ARCH}-pd-v3.10.0.tar.xz"
    apt download xz-utils
    deb_file=$(find $ROOTFS_DIR -name "*.deb" -type f)
    dpkg -x $deb_file ~/.local/
    rm "$deb_file"
    
    tar -xJf /tmp/rootfs.tar.xz -C $ROOTFS_DIR;;

    1)
    wget --no-hsts -O /tmp/rootfs.tar.gz \
    "http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.4-base-${ARCH_ALT}.tar.gz"

    tar -xf /tmp/rootfs.tar.gz -C $ROOTFS_DIR;;

    2)
    wget --no-hsts -O /tmp/rootfs.tar.gz \
    "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-minirootfs-3.18.3-${ARCH}.tar.gz"

    tar -xf /tmp/rootfs.tar.gz -C $ROOTFS_DIR;;


esac

fi

################################
# Package Installation & Setup #
################################

# Download static APK-Tools temporarily because minirootfs does not come with APK pre-installed.
if [ ! -e $ROOTFS_DIR/.installed ]; then
    # Download the packages from their sources
    mkdir $ROOTFS_DIR/usr/local/bin -p
    wget --no-hsts -O $ROOTFS_DIR/usr/local/bin/proot "https://github.com/proot-me/proot/releases/download/v${PROOT_VERSION}/proot-v${PROOT_VERSION}-${ARCH}-static"
    # Make PRoot executable.
    chmod 755 $ROOTFS_DIR/usr/local/bin/proot
fi

# Clean-up after installation complete & finish up.
if [ ! -e $ROOTFS_DIR/.installed ]; then
    # Add DNS Resolver nameservers to resolv.conf.
    printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > ${ROOTFS_DIR}/etc/resolv.conf
    # Wipe the files we downloaded into /tmp previously.
    rm -rf /tmp/rootfs.tar.xz /tmp/sbin
    # Create .installed to later check whether Alpine is installed.
    touch $ROOTFS_DIR/.installed
fi

# Print some useful information to the terminal before entering PRoot.
# This is to introduce the user with the various Alpine Linux commands.
clear && cat << EOF
Powered by
 _    __           ______             
| |  / /___  _____/ ____/_______  ___ 
| | / / __ \/ ___/ /_  / ___/ _ \/ _ \

| |/ / /_/ (__  ) __/ / /  /  __/  __/
|___/ .___/____/_/   /_/   \___/\___/ 
   /_/                                
______________________________________
EOF

###########################
# Start PRoot environment #
###########################
# Option to set a password
echo
echo "Do you want to set a password for your VM? (type y)"
read choice

if [ "$choice" = "y" ]; then
    if [ ! -e $ROOTFS_DIR/.password_set ]; then
        echo "Enter password for the VM:"
        read vm_password
        echo "root:$vm_password" | $ROOTFS_DIR/usr/local/bin/proot --rootfs="$ROOTFS_DIR" -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf chpasswd
        echo "Password set successfully for the root user."
        touch $ROOTFS_DIR/.password_set
    else
        echo "Password has already been set for the VM."
    fi
fi

# This command starts PRoot and binds several important directories
# from the host file system to our special root file system.
$ROOTFS_DIR/usr/local/bin/proot \
--rootfs="${ROOTFS_DIR}" \
-0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit

