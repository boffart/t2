/*
 * --- T2-COPYRIGHT-NOTE-BEGIN ---
 * This copyright note is auto-generated by ./scripts/Create-CopyPatch.
 * 
 * T2 SDE: misc/tools-source/getfiles.c
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
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

int main(int argc, char ** argv) {
	char *fn, buf[512], *n;
	struct stat st;
	if (argc > 1) chdir(argv[1]);
	while ( fgets(buf, 512, stdin) != NULL &&
					(fn = strchr(buf, ' ')) != NULL ) {
		if ( (n = strchr(++fn, '\n')) != NULL ) *n = '\0';
		if ( !lstat(fn,&st) && S_ISREG(st.st_mode) )
			puts(fn);
	}
	return 0;
}
