#!/bin/sh
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../vserver/stone_mod_vserver.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---
# [MAIN] 40 vserver Linux VServer Manager

CONFDIR=/etc/vservers

oneliner() {
	[ -r $1 ] && head -n 1 $1 || echo "N/A"
}

gui_edit_oneliner() {
	local value=
	[ -f $2 ] && value="$( cat $2 )"
	if gui_input "Enter value for '$1' ($2):" "$value" value; then
		if [ "$value" ]; then
			echo "$value" > $2
		else
			rm -f $2
		fi
	fi
}
gui_edit_deleteable() {
	gui_edit $1 $2
	[ ! -s $2 ] && rm -f $2
}

flag_if_empty() {
	[ -s $1 ] || echo '[N/A]'
}

vserver_conf_manage() {
	local server="$1" errno=0
	local vdir=$CONFDIR/$server

	while [ $errno -eq 0 ]; do
		local options=
		
		options="$options 'Name ......: $( oneliner $vdir/name )' ''"
		options="$options 'Context ID.: $( oneliner $vdir/run )' ''"
		options="$options 'Directory .: $( readlink -f $vdir/vdir )' ''"
		options="$options 'Context ...: $( oneliner $vdir/context )' \
			'gui_edit_oneliner context $vdir/context'"
		options="$options 'Namespace .: $( oneliner $vdir/namespace )' \
			'gui_edit_oneliner namespace $vdir/namespace'"
			
		options="$options '' ''"
		case "`uname -r`" in
			2.4*)	options="$options 'System Capabilities  $( flag_if_empty $vdir/capabilities )' \
					'gui_edit_deleteable capabilities $vdir/capabilities'"
				;;
			*)	options="$options 'System Capabilities  $( flag_if_empty $vdir/bcapabilities )' \
					'gui_edit_deleteable bcapabilities $vdir/bcapabilities'"
				;;
		esac
		options="$options 'Context Capabilities $( flag_if_empty $vdir/ccapabilities )' \
			'gui_edit_deleteable ccapabilities $vdir/ccapabilities'"
		options="$options 'Flags                $( flag_if_empty $vdir/flags )' \
			'gui_edit_deleteable flags $vdir/flags'"
		options="$options 'Personalities        $( flag_if_empty $vdir/personality )' \
			'gui_edit_deleteable personality $vdir/personality'"
		options="$options 'Scheduler Parameters $( flag_if_empty $vdir/schedule )' \
			'gui_edit_deleteable schedule $vdir/schedule'"

		options="$options '' ''"
		options="$options 'Nice Level ...: $( oneliner $vdir/nice )' \
			'gui_edit_oneliner nice $vdir/nice'"
		options="$options 'Default Shell : $( oneliner $vdir/shell )' \
			'gui_edit_oneliner shell $vdir/shell'"

		options="$options '' ''"
		options="$options '==> uname (uts)' 'vserver_conf_uts_manage  $server'"
		case "`uname -r`" in
			2.4*)	options="$options '==> Resource Limits'    'vserver_conf_ul_manage   $server'"	;;
			*)	options="$options '==> Resource Limits'    'vserver_conf_rl_manage   $server'"	;;
		esac
		options="$options '==> Network Interfaces' 'vserver_conf_if_manage   $server'"
		options="$options '==> Applications'       'vserver_conf_apps_manage $server'"
		options="$options '==> Scripts'            'vserver_conf_sc_manage   $server'"

		options="$options '' ''"
		options="$options 'mtab         $( flag_if_empty $appsdir/init/mtab )' \
			'gui_edit_deleteable init_mtab $vdir/apps/init/mtab'"
		options="$options 'fstab        $( flag_if_empty $vdir/fstab )' \
			'gui_edit fstab $vdir/fstab'"
		options="$options 'fstab.remote $( flag_if_empty $vdir/fstab.remote )' \
			'gui_edit_deleteable fstab_remote $vdir/fstab.remote'"

		eval "gui_menu vserver_conf 'VServer \`$server\` Configuration' $options"
		errno=$?
	done
}

vserver_conf_uts_manage() {
	local server="$1" errno=0
	local utsdir=$CONFDIR/$server/uts

	while [ $errno -eq 0 ]; do
		local options=

		options="$options 'Context Name .: $( oneliner $utsdir/context )' 'gui_edit_oneliner context $utsdir/context'"
		options="$options 'Node Name ....: $( oneliner $utsdir/nodename )' 'gui_edit_oneliner machine $utsdir/nodename'"
		options="$options 'Domain Name ..: $( oneliner $utsdir/domainname )' 'gui_edit_oneliner domainname $utsdir/domainname'"
		options="$options 'Machine Type .: $( oneliner $utsdir/machine )' 'gui_edit_oneliner machine $utsdir/machine'"
		options="$options 'Sysname ......: $( oneliner $utsdir/sysname )' 'gui_edit_oneliner machine $utsdir/sysname'"
		options="$options 'OS Release ...: $( oneliner $utsdir/release )' 'gui_edit_oneliner machine $utsdir/release'"
		options="$options 'OS Version ...: $( oneliner $utsdir/version )' 'gui_edit_oneliner machine $utsdir/version'"

		eval "gui_menu vserver_conf_uts 'VServer \`$server\` uname Configuration' $options"
		errno=$?
	done
	}

vserver_conf_apps_manage() {
	local server="$1" errno=0
	local appsdir=$CONFDIR/$server/apps

	while [ $errno -eq 0 ]; do
		local options=
		options="$options '$server/apps/init/' ''"
		options="$options '  - style ..........: $( oneliner $appsdir/init/style )' \
			'gui_edit_oneliner init_style $appsdir/init/style'"
		options="$options '  - mark ...........: $( oneliner $appsdir/init/mark )' \
			'gui_edit_oneliner init_mark $appsdir/init/mark'"
		options="$options '  - tty ............: $( readlink -f $appsdir/init/tty 2> /dev/null )' ''"
		options="$options '  - runlevel .......: $( oneliner $appsdir/init/runlevel )' \
			'gui_edit_oneliner init_runlevel $appsdir/init/runlevel'"
		options="$options '  - runlevel.start .: $( oneliner $appsdir/init/runlevel.start )' \
			'gui_edit_oneliner init_runlevel_start $appsdir/init/runlevel.start'"
		options="$options '  - runlevel.stop ..: $( oneliner $appsdir/init/runlevel.stop )' \
			'gui_edit_oneliner init_runlevel_stop $appsdir/init/runlevel.stop'"

		options="$options '' ''"
		options="$options '  * depends     $( flag_if_empty $appsdir/init/depends )' \
			'gui_edit_deleteable init_depends $appsdir/init/depends'"
		options="$options '  * killseq     $( flag_if_empty $appsdir/init/killseq )' \
			'gui_edit_deleteable init_killseq $appsdir/init/killseq'"

		options="$options '  * cmd.prepare $( flag_if_empty $appsdir/init/cmd.prepare )' \
			'gui_edit_deleteable init_prepare $appsdir/init/cmd.prepare'"
		options="$options '  * cmd.start   $( flag_if_empty $appsdir/init/cmd.start )' \
			'gui_edit_deleteable init_start $appsdir/init/cmd.start'"
		options="$options '  * cmd.stop    $( flag_if_empty $appsdir/init/cmd.stop )' \
			'gui_edit_deleteable init_stop $appsdir/init/cmd.stop'"

		if [ -e $appsdir/init/sync ]; then
		options="$options '  * cmd.start-sync $( flag_if_empty $appsdir/init/cmd.start-sync )' \
			'gui_edit_deleteable init_start_sync $appsdir/init/cmd.start-sync'"
		options="$options '  * cmd.stop-sync  $( flag_if_empty $appsdir/init/cmd.stop-sync )' \
			'gui_edit_deleteable init_stop_sync $appsdir/init/cmd.stop-sync'"
		fi

		eval "gui_menu vserver_conf_uts 'VServer \`$server\` Applications Configuration' $options"
		errno=$?
	done
	}

vserver_conf_rl_manage() {
	local server="$1" errno=0
	local rldir=$CONFDIR/$server/rlimits

	while [ $errno -eq 0 ]; do
		local options=
		options="$options 'resource      $( flag_if_empty $rldir/resource )' \
			'gui_edit_deleteable resource $rldir/resource'"
		options="$options 'resource.min  $( flag_if_empty $rldir/resource.min )' \
			'gui_edit_deleteable resource $rldir/resource.min'"
		options="$options 'resource.hard $( flag_if_empty $rldir/resource.hard )' \
			'gui_edit_deleteable resource $rldir/resource.hard'"
		options="$options 'resource.soft $( flag_if_empty $rldir/resource.soft )' \
			'gui_edit_deleteable resource $rldir/resource.soft'"
		eval "gui_menu vserver_conf_rl 'VServer \`$server\` (2.6) Resource Limits Configuration' $options"
		errno=$?
	done
	}

vserver_conf_ul_manage() {
	local server="$1" errno=0
	local rldir=$CONFDIR/$server/ulimits

	while [ $errno -eq 0 ]; do
		local options=
		options="$options 'resource      $( flag_if_empty $rldir/resource )' \
			'gui_edit_deleteable resource $rldir/resource'"
		options="$options 'resource.hard $( flag_if_empty $rldir/resource.hard )' \
			'gui_edit_deleteable resource $rldir/resource.hard'"
		options="$options 'resource.soft $( flag_if_empty $rldir/resource.soft )' \
			'gui_edit_deleteable resource $rldir/resource.soft'"
		eval "gui_menu vserver_conf_ul 'VServer \`$server\` (2.4) Resource Limits Configuration' $options"
		errno=$?
	done
	}

vserver_conf_sc_manage() {
	local server="$1" errno=0
	local scdir=$CONFDIR/$server/scripts

	while [ $errno -eq 0 ]; do
		local options=
		eval "gui_menu vserver_conf_uts 'VServer \`$server\` uname Configuration' $options"
		errno=$?
	done
	}

vserver_conf_if_manage() {
	local server="$1" errno=0
	local ifdir=$CONFDIR/$server/interfaces

	while [ $errno -eq 0 ]; do
		local options= iface=
		options="$options 'default broadcast ..: $( oneliner $ifdir/bcast )'  'gui_edit_oneliner bcast $ifdir/bcast'"
		options="$options 'default device .....: $( oneliner $ifdir/dev )'    'gui_edit_oneliner device $ifdir/dev'"
		options="$options 'default netmask ....: $( oneliner $ifdir/prefix )' 'gui_edit_oneliner prefix $ifdir/prefix'"
		options="$options 'default scope ......: $( oneliner $ifdir/scope )'  'gui_edit_oneliner scope $ifdir/scope'"
		for iface in $( cd $ifdir; ls -1 ); do
			if [ -d $ifdir/$iface/ ]; then
				options="$options '' ''"
				if [ -e $ifdir/$iface/disabled ]; then
					options="$options 'interface/$iface: DISABLED' 'rm -f $ifdir/$iface/disabled'"  
				else
					options="$options 'interface/$iface: ENABLED'  'touch $ifdir/$iface/disabled'"  
				fi
				options="$options '   broadcast ..: $( oneliner $ifdir/$iface/bcast )' \
					'gui_edit_oneliner bcast $ifdir/$iface/bcast'"
				options="$options '   device .....: $( oneliner $ifdir/$iface/dev )' \
					'gui_edit_oneliner dev $ifdir/$iface/dev'"
				options="$options '   ip .........: $( oneliner $ifdir/$iface/ip )' \
					'gui_edit_oneliner ip $ifdir/$iface/ip'"
				options="$options '   netmask ....: $( oneliner $ifdir/$iface/prefix )' \
					'gui_edit_oneliner prefix $ifdir/$iface/prefix'"
				options="$options '   scope ......: $( oneliner $ifdir/$iface/scope )' \
					'gui_edit_oneliner scope $ifdir/$iface/scope'"
		fi
		done
		options="$options '' ''"
		options="$options 'Add new interface' 'vserver_if_new $server'"

		eval "gui_menu vserver_conf_uts 'VServer \`$server\` Network Interfaces Configuration' $options"
		errno=$?
	done
	}

vserver_if_new() {
	local server="$1"
	local iface=
	gui_input "Enter a name for the new interface" '' iface
	if [ "$iface" ]; then
		mkdir -p "$CONFDIR/$server/interfaces/$iface"
	fi
}
vserver_new() {
	local server= action= errno=
	gui_input "Enter a name for the new vserver" '' server
	if [ "$server" ]; then
		action="vserver '$server' build -m skeleton --initstyle plain"
		eval "$action"; errno=$?
		if [ $errno -eq 0 ]; then
			vserver_conf_manage "$server"
		else
			gui_message "\"$action\" failed."
		fi
	fi
}


main() {
	local errno=0
	local servers= server=

	while [ $errno -eq 0 ]; do
		servers=
		for server in $( ls -1 $CONFDIR); do
			[ -d $CONFDIR/$server ] && servers="$servers 'vserver: $server' 'vserver_conf_manage $server'"
		done

		[ "$servers" ] && servers="$servers '' ''"
		eval "gui_menu vserver 'Linux VServer Manager' $servers 'Create a new vserver' 'vserver_new'"
		errno=$?
	done
}
