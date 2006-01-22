#!/bin/sh
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../mkinitrd/initrdinit.sh
# Copyright (C) 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

echo "T2 early userspace ..."

PATH=/sbin:/bin

echo "Mounting /dev, /proc and /sys ..."
mount -t tmpfs none /dev
mount -t proc  none /proc
mount -t usbfs none /proc/bus/usb
mount -t sysfs none /sys
ln -s /proc/self/fd /dev/fd

mknod /dev/console c 5 1
mknod /dev/null c 1 3
mknod /dev/zero c 1 5

# later on we might reverse these, that is run udevstart first,
# and let udev add new ones as hotplug agents ...

echo "Running hotplug++ hardware detection ..."
/sbin/hotplug++ -synth
echo "/sbin/hotplug++" > /proc/sys/kernel/hotplug

echo "Loading additional subsystem and filesystem driver ..."
# hack to be removed
modprobe sbp2

# well some hardcoded help for now ...
modprobe ide-disk
modprobe ide-cd
modprobe sd_mod
modprobe sr_mod
modprobe sg

# the modular filesystems ...
for x in /lib/modules/*/kernel/fs/{*/,}*.*o ; do
	x=${x##*/} ; x=${x%.*o}
	modprobe $x
done

echo "Populating /dev (udev) ..."
/sbin/udevstart

echo "Mounting rootfs ..."

# get the root device and init
root="root= `cat /proc/cmdline`" ; root=${root##*root=} ; root=${root%% *}
init="init= `cat /proc/cmdline`" ; init=${init##*init=} ; init=${init%% *}

# try best match / detected rootfs first, all the others thereafter
filesystems=`disktype $root 2>/dev/null |
             sed -e '/file system/!d' -e 's/file system.*//' -e 's/ //g' \
                 -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'
             sed '1!G ; $p ; h ; d' /proc/filesystems | sed /^nodev/d`

mkdir /rootfs

if [ "$root" ]; then
  i=0
  while [ $i -le 9 ]; do
	for fs in $filesystems ; do
	  if mount -t $fs $root /rootfs -o ro 2> /dev/null; then
		echo "Successfully mounted rootfs as $fs"

		# TODO: later on search other places if we want 100% backward compat.
		[ "$init" ] || init=/sbin/init
		if [ -f /rootfs/$init ]; then
			mount -t none /dev -o move /rootfs/dev
			mount -t none /proc -o move /rootfs/proc
			mount -t none /sys -o move /rootfs/sys
			exec switch_root /rootfs $init
		else
			echo "specified init ($init) does not exist"
		fi
	  fi
	done
  : $(( i++ ))
  sleep 1
  done
fi

echo "Ouhm - some boot problem, but I do not scream. Debug shell:"
exec /bin/sh

