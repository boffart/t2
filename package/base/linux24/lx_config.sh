# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/*/linux24/lx_config.sh
# Copyright (C) 1998 - 2003 ROCK Linux Project
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

treever=${pkg/linux/} ; treever=${treever/-*/}
hook_add prepare 3 'archdir="$base/download/mirror/l"'

[ "$vanilla_ver" ] || vanilla_ver="$ver"
srctar="linux-${vanilla_ver}.tar.bz2"

lx_cpu=`echo "$arch_machine" | sed -e s/x86$/i386/ \
  -e s/i.86/i386/ -e s/powerpc/ppc/ -e s/hppa/parisc/`
lx_extraversion=""
lx_kernelrelease=""
lx_tempdir=""

[ $arch = sparc -a "$ROCKCFG_SPARC_64BIT_KERNEL" = 1 ] && \
        lx_cpu=sparc64

MAKE="$MAKE ARCH=$lx_cpu CROSS_COMPILE=$archprefix KCC=$KCC"

# correct the abolute path for patchfiles supplied in the .desc file
for x in $patchfiles ; do
	if [ ! -e "$x" -a -n "${x##*/*}" ] ; then
		var_remove patchfiles " " "$x"
		var_append patchfiles " " "$base/download/mirror/${x:0:1}/$x"
	fi
done

auto_config ()
{
	if [ -f $base/architecture/$arch/kernel$treever.conf.sh ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf.sh"
		. $base/architecture/$arch/kernel$treever.conf.sh > .config
	elif [ -f $base/architecture/$arch/kernel$treever.conf.m4 ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf.m4"
		m4 -I $base/architecture/$arch -I $base/architecture/share \
		   $base/architecture/$arch/kernel$treever.conf.m4 > .config
	elif [ -f $base/architecture/$arch/kernel$treever.conf ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf"
		cp $base/architecture/$arch/kernel$treever.conf .config
	elif [ -f $base/architecture/$arch/kernel.conf.sh ] ; then
		echo "  using: architecture/$arch/kernel.conf.sh"
		. $base/architecture/$arch/kernel.conf.sh > .config
	elif [ -f $base/architecture/$arch/kernel.conf.m4 ] ; then
		echo "  using: architecture/$arch/kernel.conf.m4"
		m4 -I $base/architecture/$arch -I $base/architecture/share \
		   $base/architecture/$arch/kernel.conf.m4 > .config
	elif [ -f $base/architecture/$arch/kernel.conf ] ; then
		echo "  using: architecture/$arch/kernel.conf"
		cp $base/architecture/$arch/kernel.conf .config
	else
		echo "  using: no rock kernel config found"
		cp arch/$lx_cpu/defconfig .config
	fi

	echo "  merging (system default): 'arch/$lx_cpu/defconfig'"
	grep '^CONF.*=y' arch/$lx_cpu/defconfig | cut -f1 -d= | \
	while read tag ; do egrep -q "(^| )$tag[= ]" .config || echo "$tag=y"
	  done >> .config ; cp .config .config.1

	# all modules needs to be first so modules can be disabled by i.e.
	# the targets later
	echo "Enabling all modules ..."
	yes '' | eval $MAKE no2modconfig > /dev/null ; cp .config .config.2

	if [ -f $base/target/$target/kernel$treever.conf.sh ] ; then
		confscripts="$base/target/$target/kernel$treever.conf.sh $confscripts"
	elif [ -f $base/target/$target/kernel.conf.sh ] ; then
		confscripts="$base/target/$target/kernel.conf.sh $confscripts"
	fi

	for x in $confscripts ; do
		echo "  running: $x"
		sh $x .config
	done
	cp .config .config.3

	# merge various text/plain config files
	for x in $base/config/$config/linux.cfg \
	         $base/target/$target/kernel.conf ; do
	   if [ -f $x ] ; then
		echo "  merging: '$x'"
		tag="$(sed '/CONFIG_/ ! d; s,.*CONFIG_\([^ =]*\).*,\1,' \
			$x | tr '\n' '|')"
		egrep -v "\bCONFIG_($tag)\b" < .config > .config.4
		sed 's,\(CONFIG_.*\)=n,# \1 is not set,' \
			$x >> .config.4
		cp .config.4 .config
	   fi
	done

	# create a valid .config
	yes '' | eval $MAKE oldconfig > /dev/null ; cp .config .config.5

	# last disable broken stuff
	rm -f /tmp/$$.sed
	list="CONFIG_THIS_DOES_NOT_EXIST"
	for x in $pkg_linux_brokenfiles ; do
	    if [ -f "$x" ] ; then
		echo "Disable broken file: $x"
		list="$list `tr ' ' '\t' < $x | cut -f1 | grep '^CONFIG_'`"
            fi
	done
	for x in $list ; do
		echo "s,^$x=.\$,# $x is not set,;" >> /tmp/$$.sed
	done

	sed -f /tmp/$$.sed < .config > .config.6
	cp .config.6 .config ; rm -f /tmp/$$.sed

	# create a valid .config (dependencies might need to be disabled)
	yes '' | eval $MAKE oldconfig > /dev/null

	# save final config
	cp .config .config_modules

	echo "Creating config without modules ...."
	sed "s,\(CONFIG_.*\)=m,# \1 is not set," .config > .config_new
	mv .config_new .config
	# create a valid .config (dependencies might need to be disabled)
	yes '' | eval $MAKE oldconfig > /dev/null
	mv .config .config_nomods

	# which .config to use?
	if [ "$ROCKCFG_PKG_LINUX_CONFIG_STYLE" = "modules" ] ; then
		cp .config_modules .config
	else
		cp .config_nomods .config
	fi
}

lx_grabextraversion () {
	local ev
	ev=$( sed -n -e 's,^[ \t]*EXTRAVERSION[ \t]*=[ \t]*\([^ \t]*\),\1,p' Makefile | tail -n 1 )
	if [ "$ev" ]; then
		lx_extraversion="${lx_extraversion}$ev"
		# keep intact but commented since the second EXTRAVERSION
		# definition, and clean the first.
		sed -e 's,^\([ \t]*EXTRAVERSION[ \t]*=.*\),#\1,g' \
		    -e 's,^#\(EXTRAVERSION =\).*,\1,' \
		    Makefile > Makefile.new
		mv Makefile.new Makefile
	fi
}
lx_injectextraversion () {
	lx_extraversion="${lx_extraversion}-rock"

	# inject final EXTRAVERSION into Makefile
	sed -i -e "s,^\([ \t]*EXTRAVERSION[ \t]*\)=.*,\1= ${lx_extraversion},g" Makefile

	# update version.h - we only do this, because some other freaky
	# projects like rsbac change EXTRAVERSION in other Makefiles ...
	rerun=""; eval $MAKE include/linux/version.h | grep -q "is up to date" && rerun=1
	if [ "$rerun" ] ; then
		echo "WARNING: Your system's timer resolution is too low ..."
		sleep 1 ; touch Makefile
		eval $MAKE include/linux/version.h
	fi

	# get kernel_release
	lx_kernelrelease="$( echo -e "#include <linux/version.h>\nUTS_RELEASE" \
                    > conftest.c &&	\
                    gcc -E -I./include conftest.c | tail -n 1	\
                    | cut -d '"' -f 2 && rm -f conftest.c )"

	# rename temp directory 
	if [ "${lx_tempdir}" ]; then
		cd ..
		rm -rf linux-${lx_kernelrelease} ; mv ${lx_tempdir} linux-${lx_kernelrelease}
		ln -sf $PWD/linux-${lx_kernelrelease} $builddir/linux-${vanilla_ver}

		if [ "${pkg%-src}" = "$ROCKCFG_DEFAULT_KERNEL" ] ; then
			rm -f linux
			ln -svf linux-${lx_kernelrelease} linux
		fi
		cd linux-${lx_kernelrelease}
	fi
}

lx_config ()
{
	echo "Generic linux source patching and configuration ..."

	# grab extraversion from vanilla
	lx_grabextraversion

	hook_eval prepatch
	apply_patchfiles "lx_grabextraversion"
	hook_eval postpatch

	echo "Redefining some VERSION flags ..."
	lx_injectextraversion

	echo "Correcting user and permissions ..."
	chown -R root:root . * ; chmod -R u=rwX,go=rX .

	if [[ $treever = 24* ]] ; then
		echo "Create symlinks and a few headers for <$lx_cpu> ... "
		eval $MAKE symlinks
		cp $base/package/base/linux24/autoconf.h include/linux/
		touch include/linux/modversions.h
	fi

	if [ "$ROCKCFG_PKG_LINUX_CONFIG_STYLE" = none ] ; then
		echo "Using \$base/config/\$config/linux.cfg."
		echo "Since automatic generation is disabled ..."
		cp -v $base/config/$config/linux.cfg .config
	else
		echo "Automatically creating default configuration ...."
		auto_config
	fi

	echo "... configuration finished!"

	if [[ $treever != 24* ]] ; then
		echo "Create symlinks and a few headers for <$lx_cpu> ... "
		eval $MAKE include/asm
		yes '' | eval $MAKE oldconfig > /dev/null
	fi

	echo "Clean up the *.orig and *~ files ... "
	rm -f .config.old `find -name '*.orig' -o -name '*~'`

	echo "Generic linux source configuration finished."
}

pkg_linux_brokenfiles="$base/architecture/$arch/kernel-disable.lst \
	$base/architecture/$arch/kernel$treever-disable.lst \
	$base/package/*/linux$treever/disable-broken.lst \
	$pkg_linux_brokenfiles"

