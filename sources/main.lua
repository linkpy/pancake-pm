

local lfs = require 'lfs'
local fs = require 'nelua.utils.fs'
local sstream = require 'nelua.utils.sstream'

local Executer = require 'ppm.executer'
local Git = require 'ppm.git'
local DepGraph = require 'ppm.dep-graph'
local utils = require 'ppm.utils'
local pkg = require 'ppm.package'
local cache = require 'ppm.cache'


local ppm_src_path = ""

do 
	local script_path = debug.getinfo(1, 'S').source:sub(2)
	ppm_src_path = fs.dirname(script_path)
end



local function make_nelua_executer(p)
	cache.path = p
	cache.check()

	local pkg_cfg = pkg.load_config(p)
	pkg.fetch_deps(pkg_cfg, false)

	local ex = Executer("nelua", {}, p)

	ex:add_argument(fs.join(ppm_src_path, "runtime/injector.nelua"))
	ex:add_argument("-o " .. fs.join(p, 'nelua_cache', pkg_cfg.name))
	return ex:enable_printing()
end



local helps = {}
local handlers = {}

--------------------------------------------------------------------------------

helps.help = {
	syntax = "",
	desc = [[Prints this text and exit.]]
}
function handlers.help()
	local ss = sstream()

	ss:add"USAGE: ppm command [...args]\n"
	ss:add"\n"
	ss:add"Commands:\n"

	for k, v in pairs(helps) do
		k = k:gsub("_", "-")

		ss:add"  - "
		ss:add(k)
		if v.syntax ~= "" then
			ss:add(" ")
			ss:add(v.syntax)
		end
		ss:add(": ")
		ss:add(v.desc)
		ss:add("\n")
	end

	ss:add"\n"
	ss:add"Path:\n"
	ss:add"  All commands can receive an extra argument to define the package's\n"
	ss:add"path. By default, it is set to the current working directory.\n"

	print(ss:tostring())
	os.exit(1)
end

--------------------------------------------------------------------------------

helps.init = {
	syntax = "",
	desc = [[Initializes a new package.]]
}
function handlers.init(path)
	require('ppm.package-creator')(path)
end

--------------------------------------------------------------------------------

helps.update = {
	syntax = "",
	desc = [[Updates all the dependencies.]]
}
function handlers.update(p)
	cache.path = p
	cache.check()

	local pkg_cfg = pkg.load_config(p)
	pkg.fetch_deps(pkg_cfg, true)
end

--------------------------------------------------------------------------------

helps.build = {
	syntax = "",
	desc = [[Builds the package.]]
}
function handlers.build(p)
	local status, err = make_nelua_executer(p):execute()

	if not status then
		print("\nBuild failed: ")
		print(err)
		os.exit(1)
	end
end

--------------------------------------------------------------------------------

helps.test = {
	syntax = "",
	desc = [[Builds the pacakge in test mode. Defines the global TEST in the preprocessor.]]
}
function handlers.test(p)
	local status, err = make_nelua_executer(p):add_argument('-DTEST'):execute()

	if not status then
		print("\nBuild failed: ")
		print(err)
		os.exit(1)
	end
end






local function main()
	if #arg < 4 then
		print_usage()
	end

	local command = arg[4]:gsub("-", "_")
	local handler = handlers[command]
	local cwd, err = lfs.currentdir()

	if not cwd then
		print("Failed to get current working directory: " .. err)
		os.exit(1)
	end

	if not handler then
		handlers.help() -- exit
	end

	local nparams = debug.getinfo(handler).nparams

	if nparams == 0 then -- help
		handler()
	else
		local params = {}
		local param_count = nparams - 1

		for i=5,#arg do
			table.insert(params, arg[i])
		end

		if #params < param_count or #params > nparams then
			handlers.help()
		end

		if #params < nparams then
			table.insert(params, cwd)
		end

		handler(table.unpack(params))
	end
end



main()