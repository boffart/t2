/*
 * --- ROCK-COPYRIGHT-NOTE-BEGIN ---
 * 
 * This copyright note is auto-generated by ./scripts/Create-CopyPatch.
 * Please add additional copyright information _after_ the line containing
 * the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
 * the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
 * 
 * ROCK Linux: rock-src/misc/tools-source/fl_wrparse.c
 * Copyright (C) 1998 - 2003 ROCK Linux Project
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

#define _GNU_SOURCE

#include <string.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>

char * get_realname(char * origname) {
	static char buf[FILENAME_MAX];
	char *file, odir[FILENAME_MAX];

	if (! strcmp(origname, "/")) return "/";
	
	strcpy(buf,origname);
	if ( (file=strrchr(buf,'/')) == NULL ) {
		file = origname;
		strcpy(buf, ".");
	} else {
		*file=0; file++;
		file = origname + (file-buf);
	}
	
	getcwd(odir, FILENAME_MAX); chdir(buf);
	getcwd(buf, FILENAME_MAX);  chdir(odir);

	if (strcmp(buf, "/")) strcat(buf,"/");
	strcat(buf, file);

	return buf;
}

int dir_empty(char * nam) {
	struct dirent **namelist; int n;
	n = scandir(nam, &namelist, 0, alphasort);
	if (n < 0) perror("scandir");
	while (n--)
		if ( strcmp(namelist[n]->d_name,".") &&
		     strcmp(namelist[n]->d_name,"..") ) return 0;
	return 1;
}

int main(int argc, char ** argv) {
	char *fn, buf[FILENAME_MAX], *n;
	char realrootdir[FILENAME_MAX];
	char *package = NULL;
	char *rootdir = NULL;
	struct stat st;
	int opt, nodircheck = 0;
	int stripinfo = 0;
	int debug = 0;

	while ( (opt = getopt(argc, argv, "dDr:sp:")) != -1 ) {
		switch (opt) {
		    case 'd':
			debug = 1;
			break;

		    case 'D':
			nodircheck = 1;
			break;

		    case 's':
			stripinfo = 1;
			break;

		    case 'p':
			package = optarg;
			break;

		    case 'r':
			strcpy(realrootdir, get_realname(optarg));
			rootdir = realrootdir;
			break;

		    default:
			fprintf(stderr, "Usage: %s [-D] [-r rootdir] [-s] "
					"[-p pkg]\n", argv[0]);
			return 1;
		}
	}

	if ( rootdir != NULL ) chdir(rootdir);

	while ( fgets(buf, FILENAME_MAX, stdin) != NULL ) {

		if (stripinfo) {
			fn = strpbrk(buf, "\t ");
			if ( fn++ == NULL ) continue;
		} else fn = buf;
		if ( (n = strchr(fn, '\n')) != NULL ) *n = '\0';
		if ( *fn == 0 ) continue;

		if ( !lstat(fn,&st) )
		{
		    if ( !S_ISDIR(st.st_mode) || nodircheck || dir_empty(fn) )
		    {
			fn = get_realname(fn);
			if (rootdir) {
				if (! strncmp(rootdir, fn, strlen(rootdir))) {
					fn += strlen(rootdir);
				} else {
					if (debug) printf("DEBUG: Outside "
					                  "root (%s): %s.\n",
					                   rootdir, fn);
					continue;
				}
			}
			if (! package) printf("%s\n", fn);
			else printf("%s: %s\n", package, fn);
		    } else {
			if (debug) printf("DEBUG: Non-empty dir: %s.\n", fn);
		    }
		} else {
			if (debug) printf("DEBUG: Can't stat file: %s.\n", fn);
		}
	}
	return 0;
}
