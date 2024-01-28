

require 'ppm.debug'

local lfs = require 'lfs'
local fs = require 'nelua.utils.fs'
local sstream = require 'nelua.utils.sstream'

local utils = require 'ppm.utils'
local pkg = require 'ppm.package'
local cache = require 'ppm.cache'
local interface = require 'ppm.interface'

local Executer = require 'ppm.executer'



local function path_or_cwd(p)
	if p then return p end

	local cwd, err = lfs.currentdir()

	if not cwd then
		print("Failed to get current working directory: " .. err)
		os.exit(1)
	end

	return cwd
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

helps.new = {
	syntax = "[path]",
	desc = [[Initializes a new package.]]
}
function handlers.new(path)
	path = path_or_cwd(path)

	require('ppm.package-creator')(path)
end

--------------------------------------------------------------------------------

helps.update = {
	syntax = "[force] [path]",
	desc = [[Updates all the dependencies.]]
}
function handlers.update(a, b)
	local force = not not a
	local path = path_or_cwd(b)


	cache.path = path
	cache.check()

	local localpkg = pkg.Package(".")
	localpkg.path = path

	-- global ppm
	ppm = require 'ppm.interface'
	ppm.root_path = path
	ppm.current_path = path

	localpkg:update(force)

	local fg_path = fs.join(path, '.neluacfg.ppm.lua')
	local cfg = {}
	cfg.cache_dir = fs.join(path, "nelua_cache")
	cfg.add_path = ppm.included_paths

	utils.write_file(fg_path, 'return ' .. utils.table_to_file(cfg) .. "\n")

	print("Update successful")
end

--------------------------------------------------------------------------------

helps.clean = {
	syntax = "[path]",
	desc = [[Remove all uneccesary files. Empties the caches.]]
}
function handlers.clean(p)
	p = path_or_cwd(p)
	
	local ok, err = Executer.exec('rm', {"-rf", fs.join(p, "ppm_cache")})
	if not ok then error("Failed to clean PPM's cache : " .. err) end

	local ok, err = Executer.exec('rm', {"-rf", fs.join(p, "nelua_cache")})
	if not ok then error("Failed to clean Nelua's cache : " .. err) end

	print("Cleaning done.")
end







local function main()
	if #arg < 1 then
		print("No command given.")
		handlers.help()
	end

	local command = arg[1]:gsub("-", "_")
	local handler = handlers[command]


	if not handler then
		print(command .. ": Not a command")
		handlers.help() -- exit
	end


	local params = {}

	for i=5,#arg do
		table.insert(params, arg[i])
	end

	handler(table.unpack(params))
end


main()
