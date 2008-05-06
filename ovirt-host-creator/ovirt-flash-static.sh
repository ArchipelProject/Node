#!/bin/bash
#
# Create an Ovirt Host USB device (stateful)
# Copyright 2008 Red Hat, Inc.
# Written by Chris Lalancette <clalance@redhat.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

. ./ovirt-common.sh

if [ $# -eq 1 ]; then
    ISO=
elif [ $# -eq 2 ]; then
    ISO=$2
else
    echo "Usage: ovirt-flash.sh <usbdevice> [iso-image]"
    exit 1
fi

USBDEVICE=$1
IMGTMP=/var/tmp/ovirt-$$
SQUASHTMP=/var/tmp/ovirt-squash-$$
USBTMP=/var/tmp/ovirt-usb-$$

if [ ! -b "$USBDEVICE" ]; then
    echo "USB device $USBDEVICE doesn't seem to exist"
    exit 2
fi

ISO=`create_iso $ISO` || exit 1

# do setup
mkdir -p $IMGTMP $SQUASHTMP $USBTMP
mount -o loop $ISO $IMGTMP
mount -o loop $IMGTMP/LiveOS/squashfs.img $SQUASHTMP

# clear out the old partition table
dd if=/dev/zero of=$USBDEVICE bs=4096 count=1
printf 'n\np\n1\n\n\nt\n83\na\n1\nw\n' | fdisk $USBDEVICE

cat /usr/lib/syslinux/mbr.bin > $USBDEVICE
dd if=$SQUASHTMP/LiveOS/ext3fs.img of=${USBDEVICE}1

mount ${USBDEVICE}1 $USBTMP

cp $IMGTMP/isolinux/* $USBTMP

rm -f $USBTMP/isolinux.bin
mv $USBTMP/isolinux.cfg $USBTMP/extlinux.conf

LABEL=`echo $ISO | cut -d'.' -f1 | cut -c-16`
sed -i -e "s/ *append.*/  append initrd=initrd.img root=LABEL=$LABEL ro/" $USBTMP/extlinux.conf

extlinux -i $USBTMP

umount $USBTMP
umount $SQUASHTMP
umount $IMGTMP
rm -rf $SQUASHTMP $IMGTMP $USBTMP
