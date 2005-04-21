# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: target/bootdisk/sparc/build.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

use_silo=1

cd $disksdir

echo_header "Creating cleaning boot directory:"
rm -rfv boot/*-dist boot/System.map boot/kconfig*

if [ $use_silo -eq 1 ]
then
	echo_header "Creating silo setup:"
	#
	echo_status "Extracting silo boot loader images."
	mkdir -p boot
	tar --use-compress-program=bzip2 \
	    -xf $base/build/${SDECFG_ID}/TOOLCHAIN/pkgs/silo.tar.bz2 \
	    boot/second.b -O > boot/second.b
	#
	echo_status "Creating silo config file."
	cp -v $base/target/$target/sparc/{silo.conf,boot.msg} \
	  boot
	#
	echo_status "Moving image (initrd) to boot directory."
	mv -v initrd.gz boot/
	#
	buildroot="build/${SDECFG_ID}"
	datadir="build/${SDECFG_ID}/TOOLCHAIN/bootdisk"
	cat > ../isofs_arch.txt <<- EOT
		BOOT	-G $buildroot/boot/isofs.b -B ...
		DISK1	$datdir/boot/ boot/
	EOT
fi

