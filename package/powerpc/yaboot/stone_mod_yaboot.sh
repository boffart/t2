# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/powerpc/yaboot/stone_mod_yaboot.sh
# ROCK Linux is Copyright (C) 1998 - 2003 Clifford Wolf
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version. A copy of the GNU General Public
# License can be found at Documentation/COPYING.
# 
# Many people helped and are helping developing ROCK Linux. Please
# have a look at http://www.rocklinux.org/ and the Documentation/TEAM
# file for details.
# 
# --- ROCK-COPYRIGHT-NOTE-END ---
#
# [MAIN] 70 yaboot Yaboot Boot Loader Setup

create_kernel_list() {
	for x in `(cd /boot/ ; ls vmlinux* ) | sort` ; do
		if [ "$x" = vmlinux ] ; then
			label=linux
		else
			label=linux-${x/vmlinux_/}
		fi
		cat << EOT >> /etc/yaboot.conf
image=$bootpath/$x
	label=$label
	root=$rootdev
	read-only

EOT
	done
}

create_yaboot_conf() {
	cat << EOT > /etc/yaboot.conf

# /etc/yaboot.conf created with the ROCK Linux yaboot stone module

# The bootstrap partition
boot=$bootstrapdev

device=hd:

# The partition with the yaboot binaries
partition=$yabootpart

# Initial mutli-boot menu delay
delay=5

# Second yaboot image chooser delay
timeout=80

install=$yabootpath/lib/yaboot/yaboot
magicboot=$yabootpath/lib/yaboot/ofboot

#fgcolor=black
#bgcolor=green

enablecdboot
enablenetboot
enableofboot
EOT

	[ "$macosxpart" ] && \
	  echo -e "\nmacosx=$macosxdev\n" \
	    >> /etc/yaboot.conf


	create_kernel_list
	gui_message "This is the new /etc/yaboot.conf file:

$( cat /etc/yaboot.conf )"
}

yaboot_install()
{
	# format the boostrap if not already done	
	if hmount $bootstrapdev > /dev/null ; then
		humount
	else
		if gui_yesno "The boostrap device \
$bootstrapdev is not yet HFS formated. \
Format now?" ; then
			hformat $bootstrapdev
		else
			return
		fi
	fi

	# maybe an unpatched yaboot and no devfsd (e.g. during install)
	[ ! -c /dev/nvram ] && ln -s /dev/misc/nvram /dev/nvram

	yaboot_install_doit
}

yaboot_install_doit() {
	gui_cmd 'Installing Yaboot' "echo 'calling ybin' ; ybin"
}

device4()
{
	dev="`grep \" $1 \" /proc/mounts | tail -1 | \
	      cut -d ' ' -f 1`"
	try="`dirname $1`"
	if [ ! "$dev" ] ; then
		dev="`grep \" $try \" /proc/mounts | tail -1 | \
		      cut -d ' ' -f 1`"
	fi
	if [ -h "$dev" ] ; then 
	  echo "/dev/`readlink $dev`"
	else
	  echo $dev
	fi
}

realpath() {
	dir="`dirname $1`"
	file="`basename $1`"
	dir="`dirname $dir`/`readlink $dir`"
	dir="`echo $dir | sed 's,[^/]*/\.\./,,g'`"
	echo $dir/$file
}

main() {
    while
        bootstrappart="`pdisk -l /dev/discs/disc0/disc | \
                       grep Apple_Bootstrap | sed -e "s/:.*//" -e "s/ //g"`"
	bootstrapdev="`realpath /dev/discs/disc0/part$bootstrappart`"
	rootdev="`device4 /`"
	bootdev="`device4 /boot`"
	yabootdev="`device4 /usr`"

	macosxpart="`pdisk -l /dev/discs/disc0/disc  | grep Apple_HFS | head -1 | \
	           sed -e "s/:.*//" -e "s/ //g"`"
	[ "$macosxpart" ] && macosxdev="`realpath /dev/discs/disc0/part$macosxpart`"

	if [ "$rootdev" = "$bootdev" ]
	then bootpath=/boot ; else bootpath="" ; fi

	if [ "$rootdev" = "$yabootdev" ]
	then yabootpath=/usr ; else yabootpath="" ; fi
	yabootpart="`echo $yabootdev | sed s/.*part//`"

        gui_menu yaboot 'Yaboot Boot Loader Setup' \
		"Bootstrap Device ...... $bootstrapdev" "" \
		"Yaboot partition:path . $yabootpart:$yabootpath" "" \
		"Root Device ........... $rootdev" "" \
		"Boot Device ........... $bootdev" "" \
		"MacOS X partition ..... $macosxdev" "" \
		'' '' \
		'(Re-)Create default /etc/yaboot.conf' 'create_yaboot_conf' \
		'(Re-)Install the yaboot boot chrp script and binary' 'yaboot_install' \
		'' '' \
		"Edit /etc/yaboot.conf (Config file)" \
			"gui_edit 'Yaboot Configurationp' /etc/yaboot.conf"
    do : ; done
}

