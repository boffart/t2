#!/usr/bin/perl -w
#
# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/scripts/patch-pp.pl
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
# ROCK Linux "Patch Postprozessor"
#
# This script runs as part of the './scripts/Internal' diff command
# and cleans up the patch 'Clifford' style...

use English;
use strict;

my $skipit=0;
my ($line,$a,$b);

if ($#ARGV != 0 or not -d $ARGV[0]) {
	print STDERR "Usage: $0 Reference-Dir\n" ; exit 1
}

while (<STDIN>) {
	$line=$_;
        if (m,^--- rock-old/([^/]+)/(\S+)\s,) {
		$skipit=0; $a=$1; $b=$2;
		while ($b=~s,^([^/]+)/?,,) {
			$a.="/".$1; $skipit=1 if -l "$ARGV[0]/$a";
			# print STDERR "Checked $a ($skipit)\n";
		}
		
        }
        print $line unless $skipit;
}

0;
