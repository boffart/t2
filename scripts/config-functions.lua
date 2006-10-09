#!/usr/bin/lua
-- --- T2-COPYRIGHT-NOTE-BEGIN ---
-- This copyright note is auto-generated by ./scripts/Create-CopyPatch.
-- 
-- T2 SDE: scripts/config-functions.lua
-- Copyright (C) 2006 The T2 SDE Project
-- Copyright (C) 2006 Rene Rebe <rene@exactcode.de>
-- 
-- More information can be found in the files COPYING and README.
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License. A copy of the
-- GNU General Public License can be found in the file COPYING.
-- --- T2-COPYRIGHT-NOTE-END ---

packages = {} -- our internal package array of tables

function pkglistread (filename)
--   print ("pkglistread: "..filename)
   local f = io.open (filename, "r")
   
   packages = {}
   
   for count = 1, math.huge do
      local line = f:read()
      if line == nil then break end
      
      -- use captures to yank out the various parts:
      -- X -----5---9 149.800 develop lua 5.1.1 / extra/development DIETLIBC 0
      -- X -----5---- 112.400 xorg bigreqsproto 1.0.2 / base/x11 0
      
      -- hm - maybe strtok as one would do in C?
      
      pkg = {}
      pkg.status, pkg.stages, pkg.priority, pkg.repository,
      pkg.name, pkg.ver, pkg.extraver, pkg.categories, pkg.flags =
	 string.match (line, "([XO]) *([0123456789-]+) *([0123456789.]+) *(%S+) *(%S+) *(%S+) *(%S*) */ ([abcdefghijklmnopqrstuvwxyz0123456789/ ]+) *([ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _-]*) 0")
      
      -- shortcomming of above regex
      pkg.categories = string.match (pkg.categories, "(.*%S) *");
      
      --[[
      print (line);
      
      if pkg.categories == nil then
	 pkg.categories = "nil" end
      
      if pkg.flags == nil then
	 pkg.flags = "nil" end
      io.write ("'",pkg.categories,"'",pkg.flags,"'\n")
      ]]--
      
      if pkg.name == nil then
	 print ("!> ", line)
      else
	 packages[#packages+1] = pkg
      end
      
   end
   f:close()
end

function pkglistwrite (filename)
--   print ("pkglistwrite: "..filename)
   local f = io.open (filename, "w")
   
   for i,pkg in ipairs(packages) do
      if pkg.status == "-" then
	 print ("package ".. pkg.name .. " disabled")
      end
      
      f:write (pkg.status, " ", pkg.stages, " ", pkg.priority, " ",
	       pkg.repository, " ", pkg.name, " ", pkg.ver)
      
      if string.len(pkg.extraver) > 0 then
	 f:write (" ", pkg.extraver)
      end
      
      f:write (" / ", pkg.categories)
      
      if string.len(pkg.flags) > 0 then
	 f:write (" ", pkg.flags)
      end
      
      f:write (" 0\n")
   end
   f:close()
end

local function pkgswitch (mode, ...)
   for i,pkg in ipairs(packages) do
      for j,arg in ipairs {...} do
	 if (pkg.name == arg) then
	    if not pkg.status == "-" then
	       pkg.status = mode
	    end
	 end
      end
   end
   -- return error if no match was found?
end

function pkgenable (pkg)
   pkgswitch ("X", pkg)
end

function pkgdisable (pkg)
   pkgswitch ("O", pkg)
end

function pkgremove (pkg)
   pkgswitch ("-", pkg)
end

function pkgcheck (pattern, mode)
   -- split the pattern seperated by "|"
   p = {}
   for x in string.gmatch(pattern, "[^|]+") do
      p[#p+1] = x
   end
   
   for i,pkg in ipairs(packages) do
      for j,x in ipairs (p) do
	 if pkg.name == x then
	    if mode == "X" then
	       if pkg.status == "X" then return 0 end
	    elseif mode == "O" then
	       if pkg.status == "O" then return 0 end
	    elseif mode == "." then
	       return 0
	    else
	       print ("Syntax error near pkgcheck: "..pattern.." "..mode)
	    end
	 end
      end
   end
   return 1
end

--pkglistread ("config/default/packages")
--pkglistwrite ("config/default/packages2")

print "LUA accelerator (C) 2006 by Valentin Ziegler & Rene Rebe, ExactCODE"

-- register shortcuts for the functions above
bash.register("pkglistread")
bash.register("pkglistwrite")
bash.register("pkgcheck")
bash.register("pkgremove")
bash.register("pkgenable")
bash.register("pkgdisable")
