#!/bin/sh
#
# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/*/rock-debug/test_bindups.sh
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
#
# List all binary names which are used more than once in various bin dirs.
#
# Output format:
# Bin-Name <Tab> Dir1 <Tab> Dir2
# ...

find {,/usr,/usr/local}/{,s}bin /usr/games -type f -printf '%f %H\n' |
sort | awk 'BEGIN { OFS="\t"; last=""; lastdir=""; }
$1==last { print $1, lastdir, $2; } { lastdir=$2; last=$1; }'

exit 0
