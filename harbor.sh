#!/bin/sh

#############################
# Ubuntu Linux Installation #
#############################

# Define the root directory to /home/container.
# We can only write in /home/container and /tmp in the container.
ROOTFS_DIR=/home/container

# Define the Ubuntu Linux version we are going to be using.
UBUNTU_VERSION="20.04"
UBUNTU_FULL_VERSION="20.04.5"
APK_TOOLS_VERSION="2.14.0-r2" # Make sure to update this too when updating Ubuntu Linux.
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

# Download & decompress the Ubuntu linux root file system if not already installed.
if [ ! -e $ROOTFS_DIR/.installed ]; then
    # Download Ubuntu Linux root file system.
    wget --no-hsts -O /tmp/rootfs.tar.gz \
    "http://cdimage.ubuntu.com/ubuntu-base/releases/${UBUNTU_VERSION}/release/ubuntu-base-${UBUNTU_FULL_VERSION}-base-${ARCH_ALT}.tar.gz"
    # Extract the Ubuntu Linux root file system.
    tar -xzf /tmp/rootfs.tar.gz -C $ROOTFS_DIR
fi

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

Hello there!

Here's some commands you might be interested in running
after installing the vps:

apt update && apt install dropbear curl dialog -y && echo "export PATH=$PATH:/usr/sbin" >> .bashrc

^^
allows you to install a ssh server and other important stuff
(keep on mind you should edit /etc/default/dropbear to change the port of the ssh)

Kind regards, Dxomg
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
