/*
 * --- T2-COPYRIGHT-NOTE-BEGIN ---
 * This copyright note is auto-generated by ./scripts/Create-CopyPatch.
 * 
 * T2 SDE: misc/tools-source/getdu.c
 * Copyright (C) 2004 - 2005 The T2 SDE Project
 * Copyright (C) 1998 - 2003 ROCK Linux Project
 * 
 * More information can be found in the files COPYING and README.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License. A copy of the
 * GNU General Public License can be found in the file COPYING.
 * --- T2-COPYRIGHT-NOTE-END ---
 */

#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>

int main(int argc, char ** argv) {
	int size=0;
	char fn[512];
	struct stat st;
	if (argc > 1) chdir(argv[1]);
	while ( scanf("%*s %s",fn) == 1 ) {
		if ( lstat(fn,&st) ) continue;
		if ( S_ISREG(st.st_mode) ) size+=st.st_size;
		size+=512; /* Every file has 512 bytes metadata ... :-) */
	}
	printf("%.2f MB\n",size/1048576.0 + 0.01);
	return 0;
}
