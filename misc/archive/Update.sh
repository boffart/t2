#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: misc/archive/Update.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

# Extract packagename and version number from the script arguments.
pkg="$1" ; shift
ver="$1" ; shift 

# The script also supports the package name and version separated by a '-'
# dash. In this case they have to be separated from each other. 
if [ -z "$ver" ]; then
	ver=${pkg/*-/}
	pkg=${pkg%-$ver}
fi

# Check if both package name and version have been extracted from the 
# commandline arguments. If not the script was called with invalid 
# arguments, show the usage. 
if [ -z "$pkg" -o -z "$ver" -o $pkg == $ver ]; then
	echo "Usage: $0 pkg ver"
	echo "   or: $0 pkg-ver"
	echo ""
	echo "Updating a package to a new versions."
	echo ""
	echo "  pkg	Packagename to be updated"
	echo "  ver	New version number for the package"
	echo "" 
	echo "For detailed information on how to update packages"
	echo "to new versions, please have a look at the online"
	echo "T2 documentaion."
	exit
fi

# Make sure any diff files from previous runs are removed.
rm -f $$.diff

# Only package names in lowercase are supported. As an additional
# service any package names supplied in capitols will be converted
# to lowercase.
pkg=`echo $pkg | tr A-Z a-z`

# Of course we can only update packages we know about.
if [ -d package/*/$pkg ]; then
	# The package exists so now update the package descriptor
	# for the given package to the new version. Luckily we have
	# a script for that too :-)
	./scripts/Create-PkgUpdPatch $pkg $ver | tee $$.diff
	patch -p1 < $$.diff
	rm -f $$.diff

	# Step 2: Use the modified package descriptor to download
	# the package. Again, nothing more that calling an existing
	# script.
	./scripts/Download $pkg

	# Third and final step is updating the checksum for the
	# new download.
	./scripts/Create-CkSumPatch $pkg | patch -p0
else
	# Oeps, the given package name does not exist.
	echo "ERROR: package $pkg doesn't exist"
	# As an extra service for the user a list possibilities is
	# presented with packages closely matching the given package
	# name.
	pkg=`echo "$pkg" | tr '\-_.' '***'`
	echo `echo package/*/*$pkg*/ | tr ' ' '\n' | grep -v '*' | cut -d'/' -f3`
fi

