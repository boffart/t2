/*
 * --- ROCK-COPYRIGHT-NOTE-BEGIN ---
 * 
 * This copyright note is auto-generated by ./scripts/Create-CopyPatch.
 * Please add additional copyright information _after_ the line containing
 * the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
 * the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
 * 
 * ROCK Linux: rock-src/misc/archive/xline.c
 * ROCK Linux is Copyright (C) 1998 - 2003 Clifford Wolf
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. A copy of the GNU General Public
 * License can be found at Documentation/COPYING.
 * 
 * Many people helped and are helping developing ROCK Linux. Please
 * have a look at http://www.rocklinux.org/ and the Documentation/TEAM
 * file for details.
 * 
 * --- ROCK-COPYRIGHT-NOTE-END ---
 */

#include <stdio.h>
#include <time.h>
#include <unistd.h>

int main() {
	char ch,line[512];
	time_t lasttm=0;
	int c=0;
	
	while ( read(0,&ch,1)==1 ) {
		line[c++]=ch;
		if (ch == '\n')
			if (lasttm<time(NULL)-5) {
				line[c-1]=c=0; puts(line); time(&lasttm);
			} else 
				c=0;
		else
			if (c>500) c=500;
	}
	return 0;
}
