
# Sort the kernel images so that a defined default kernel is on-top.
#
# Copyright (C) 2006 Archivista GmbH
# Copyright (C) 2006 Rene Rebe
#
# Usage: sort-kernel [ default-kernel-overwrite ] < menu.lst > new-menu.lst

BEGIN {
	default_kernel="2.6.17.14-dist"
	if (ARGV[1] != "") {
		default_kernel = ARGV[1]
		delete ARGV[1]
	}

	global=1
	n=0
}

# do we arrived at the kernel images?
/title/ {
	global=0
	n=n+1
}

{	# copy global config
	if (global)
		print
}

# save the image config
/^title /	{titles[n]=$0}
/^root /	{roots[n]=$0}
/^kernel /	{kernels[n]=$0}
/^initrd /	{initrds[n]=$0}
/^chainloader /	{chainloaders[n]=$0}


function print_kernel (i) {
	print titles[i]
	if (roots[i] != "")
		print roots[i]
	if (kernels[i] != "")
		print kernels[i]
	if (initrds[i] != "")
		print initrds[i]
	if (chainloaders[i] != "")
		print chainloaders[i]
	print ""
}

END {
	# output images

	# first the default one
	for (i = 1; i <= n; ++i) {
		#if (kernels[i] ~ $dk)
		if (match (kernels[i], default_kernel))
			print_kernel(i)
	}

	# then the others
	for (i = 1; i <= n; ++i) {
		if (! match (kernels[i], default_kernel))
			print_kernel(i)
	}
}
