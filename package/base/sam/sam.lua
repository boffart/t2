#!/usr/bin/lua
-- --- T2-COPYRIGHT-NOTE-BEGIN ---
-- This copyright note is auto-generated by ./scripts/Create-CopyPatch.
-- 
-- T2 SDE: package/.../sam/sam.lua
-- Copyright (C) 2006 The T2 SDE Project
-- 
-- More information can be found in the files COPYING and README.
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License. A copy of the
-- GNU General Public License can be found in the file COPYING.
-- --- T2-COPYRIGHT-NOTE-END ---

-- identification
local _NAME        = "SAM"
local _VERSION     = "0.0-devel"
local _COPYRIGHT   = "Copyright (C) 2006 The T2 SDE Project"
local _DESCRIPTION = "System Administration Manager for systems based on T2"

-- SAM namespace
sam = sam or {
	command = {}
}

require "sam.log"

-- default options
sam.opt = sam.opt or {
	loglevel = sam.log.DEBUG, -- sam.log.WARN
}

--[[ DESCRIPTION ] ----------------------------------------------------------

Provided functions:

* sam.command["command-name"](args...)
* sam.command["command-name"].main(args...)

    Execute a command (extended by modulues) with given arguments.
	The only built-in command currently is "help".

--]] ------------------------------------------------------------------------

-- fprintf alike helper function
local function fprintf(stream, ...)
	stream:write( string.format(unpack(arg)) )
end

-- MODULES ------------------------------------------------------------------

-- load_module(name)
--   Load the previously detected module.
local function load_module(name)
	sam.info(_NAME, "Loading module %s (from %s)\n", name, sam.command[name]._module._FILE)

	-- sanity check for module info
	if not sam.command[name] or not sam.command[name]._module then
		sam.error(_NAME, "No such command module '%s', giving up.\n", name)
		return
	end

	-- load and execute the module
	local module, emsg = loadfile(sam.command[name]._module._FILE)

	if not module then
		print(emsg)
		os.exit(-1)
	end

	module = module()

	-- module sanity check
	if not module.main or not module._NAME then
		sam.error(_NAME, "Command module '%s' is probably not a SAM module.\n", name)
		return
	end

	-- copy module data
	sam.command[name]._NAME         = module._NAME
	sam.command[name]._DESCRIPTION  = module._DESCRIPTION
	sam.command[name]._USAGE        = module._USAGE
	sam.command[name]._module.main  = module.main

	sam.command[name]._load  = nil

	-- set real methods
	sam.command[name].main  = function(self,...) return self._module.main(unpack(arg)) end

	-- set correct metatable
	setmetatable(sam.command[name], {
		__call = function(self, ...) return self._module.main(unpack(arg)) end,
	})
end

-- detect_modules()
--   Detect all SAM modules
local function detect_modules()
	local lfs = require("lfs")
	local moddir = os.getenv("SAM_MODULES") or "/usr/share/sam"

	for file in lfs.dir( moddir ) do
		local name
		local path

		_,_,name = string.find(file, "^sam_([%a][_%w%a]*).lua")
		path = moddir .. "/" .. file

		if name and lfs.attributes(path).mode == "file" and "sam_" .. name .. ".lua" == file then
			sam.dbg(_NAME, "Found '%s' (%s)\n", name, path)			

			-- preset the module structure of the detected module
			-- for auto-loading
			sam.command[name] = {
				_module = {
					_NAME = name,
					_FILE = path,
				},
			
				_load = function(self,...) load_module(self._module._NAME) end,

				_NAME = name,
				_DESCRIPTION = "",
				_USAGE = "",

				main  = function(self,...)
						load_module(self._module._NAME)
						return self:main(unpack(arg))
					end,
			}

			-- add a metatable so the commands can be used, however,
			-- it is anly a intermediate metatable, as the module is not
			-- loaded yet. The module gets loaded (dynamic linker alike)
			-- once it is called

			setmetatable(sam.command[name], {
				__call = function(self, ...)
						load_module(self._module._NAME)
						return self:main(unpack(arg))
					end,
			})
						
		end
	end
end

-- COMMANDS -----------------------------------------------------------------
local function usage(cmd)
	fprintf(io.stdout, "%s v%s %s\n\n", _NAME, _VERSION, _COPYRIGHT)
	if cmd then
		if sam.command[cmd]._load then sam.command[cmd]:_load() end
		fprintf(io.stdout, "Usage: sam %s\n", sam.command[cmd]._USAGE)
	else
		fprintf(io.stdout, "Usage: sam <command> [command options]\n\n%s\n", 
			[[Commands:
                help    Show command overview (this)
      help <command>    Show command specific usage information]])

		for k,_ in pairs(sam.command) do
			if sam.command[k]._load then sam.command[k]:_load() end
			fprintf(io.stdout, "    %16s    %s\n", k, sam.command[k]._DESCRIPTION)
		end
	end
end

-- --------------------------------------------------------------------------
-- INITIALIZE SAM
-- --------------------------------------------------------------------------
detect_modules()

-- --------------------------------------------------------------------------
-- MAIN
-- --------------------------------------------------------------------------

if arg[1] then
	-- help
	if arg[1] == "help" then
		usage(arg[2])
	elseif arg[2] == "help" then
		usage(arg[1])
	else
		-- split command and command arguments
		local cmd = arg[1]
		local args = arg ; table.remove(args, 1)

		sam.command[cmd](unpack(args or {}))
	end
end

