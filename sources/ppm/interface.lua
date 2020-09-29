
local fs = require 'nelua.utils.fs'
local utils = require 'ppm.utils'
local cache = require 'ppm.cache'

local pkg = require 'ppm.package'



local ppm = {}
ppm.root_path = ""
ppm.included_paths = {}

ppm.package_cache = {}
ppm.force_update = false



function ppm.has_package(n)
	return not not ppm.package_cache[n]
end

function ppm.get_package(n)
	assert(ppm.has_package(n), "The package '" .. n .. "' isn't known.")
	return ppm.package_cache[n]
end



function ppm.include_sources(p)
	table.insert(ppm.included_paths, fs.join(ppm.root_path, p))
end

function ppm.add_dependency(p)
	local pk = pkg.Package(p)

	-- was already referenced during this update
	if ppm.package_cache[pkg.name] then
		local cver = pk:get_cached_version()
		local dver = pk.version

		-- the already referenced version is newer
		if dver < cver then
			-- if the newer version is compatible with the wanted one
			if dver ^ cver then
				return
			end

			error(string.format("The package '%s' was already referenced with version v%s, but the current package depends on the incompatible version %s.", pkg.name, cver, dver))
		end

	else
		ppm.package_cache[pk.name] = pk
		pk:update(ppm.force_update)
	end
end



return ppm
