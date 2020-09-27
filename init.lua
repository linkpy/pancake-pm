
local fs = require 'nelua.utils.fs'
local lfs = require 'lfs'


local ppm = {}
ppm.g = nil
ppm.update = false
ppm.cache = {}




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




function ppm.init(g)
	ppm.g = g
	ppm.update = has_ppm_update_define(g.config)

	ppm.g.config.path = ppm.g.config.path .. ";./sources/?.nelua"
	ppm.g.config.path = ppm.g.config.path .. ";./sources/?/init.nelua"
end

function ppm.package(p)
	if ppm.cache[p] then
		return
	end

	local n = extract_package_name(p)

	if not fs.isdir(fs.join('packages', n)) then
		print("PPM: Getting package '" .. p .. "'...")
		git_clone(n, 'http://github.com/' .. p .. '.git', 'packages/' .. n)

	elseif ppm.update then
		print("PPM: Updating package '" .. p .. "'...")
		chdir(fs.join('packages', n))
		git_pull(p)
		chdir(fs.join('..', '..'))
	end

	ppm.g.config.path = ppm.g.config.path .. ";./packages/" .. n .. "/sources/?.nelua"
	ppm.g.config.path = ppm.g.config.path .. ";./packages/" .. n .. "/sources/?/init.nelua"

	if fs.isfile(fs.join('packages', n, 'init.lua')) then
		require('packages.' .. n)
	end


	ppm.g.PPM_SUB_PACKAGE = true
	ppm.g.inject_astnode(
		ppm.g.aster.Call{
			{ppm.g.aster.String{"packages." .. n .. ".build"}}, 
			ppm.g.aster.Id{"require"}
		}
	)
	ppm.g.PPM_SUB_PACKAGE = nil

	ppm.cache[p] = true
end


return ppm
