
local fs = require 'nelua.utils.fs'
local lfs = require 'lfs'


local ppm = {}
ppm.config = nil
ppm.update = false




local function has_ppm_update_define(c)
	for k, v in pairs(c.define) do
		if v == "PPM_UPDATE = true" then
			return true
		end
	end

	return false
end

local function git_clone(p, url, path)
	local status, errstr, errno = os.execute(string.format("git clone %s %s", url, path))

	if not status then
		print(string.format("Failed to get '%s' :", p))
		print(errstr)
		os.exit(1)
	end
end	

local function chdir(p)
	lfs.chdir(p)
end

local function git_pull(p)
	local status, errstr, errno = os.execute("git pull")

	if not status then
		print(string.format("Failed to update '%s' :", p))
		print(errstr)
		os.exit(1)
	end
end

local function extract_package_name(n)
	return n:sub(n:find('/')+1, -1)
end




function ppm.init(c)
	ppm.config = c
	ppm.update = has_ppm_update_define(c)

	ppm.config.path = ppm.config.path .. ";./sources/?.nelua"
	ppm.config.path = ppm.config.path .. ";./sources/?/init.nelua"
end

function ppm.package(p)
	local n = extract_package_name(n)

	if not fs.isdir(fs.join('packages', n)) then
		print("PPM: Getting package '" .. p .. "'...")
		git_clone(n, 'https://github.com/' .. p .. '.git')

	elseif ppm.update then
		print("PPM: Updating package '" .. p .. "'...")
		chdir(fs.join('packages', n))
		git_pull(p)
		chdir(fs.join('..', '..'))
	end

	ppm.config.path = ppm.config.path .. ";./packages/" .. n .. "/sources/?.nelua"
	ppm.config.path = ppm.config.path .. ";./packages/" .. n .. "/sources/?/init.nelua"

	if fs.isfile(fs.join('packages', n, 'init.lua')) then
		require('packages.' .. n)
	end
end


return ppm
