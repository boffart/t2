#!/bin/bash

if [ "$UID" -ne 0 ]; then
	exec gnomesu -t "Disable HTTPS (SSL)" \
	-m "Please enter the system password (root user)^\
in order to disable HTTPS (SSL) for the web server." -c $0
fi

# PATH and co
. /etc/profile

# sanity check for user response
if ! grep -q DSSL /sbin/init.d/apache; then
	Xdialog --msgbox "Support for HTTPS was not enabled" 0 0
	exit
fi

# tweak init script to start without SSL suport
sed -i "s/apachectl .*start/apachectl -k start/" /sbin/init.d/apache

# tweak the window manager references to https - menu, keys, startup
sed -i 's,https://localhost/,http://localhost/,g' /home/archivista/.fluxbox/*
killall -USR2 fluxbox

rc apache stop
rc apache start

Xdialog --title "" --msgbox "HTTPS (SSL) disabled." 0 0

