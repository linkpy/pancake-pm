
local fs = require 'nelua.utils.fs'
local lfs = require 'lfs'
local utils = require 'ppm.utils'

local Executer = require 'ppm.executer'
local Git = require 'ppm.git'


local cache = {}
cache.path = ""



function cache.check()
	if not fs.isdir(cache.path) then
		local status, err = Executer.exec('mkdir', {cache.path})

		if not status then
			error("Cache invalid : cannot create folder '" .. cache.path .. "'.")
		end
	end
end

function cache.has(n)
	return fs.isdir(cache.get_path(n))
end

function cache.get_path(n)
	return fs.join(cache.path, 'ppm_cache', utils.extract_github_package_name(n))
end

function cache.delete(n)
	return Executer.exec('rm', {"-rf", cache.get_path(n)})
end

function cache.fetch(n, force)
	if cache.has(n) then
		if force then
			cache.delete(n)
		else
			return true, nil
		end
	end

	local path, branch = utils.extract_branch_from_github_package(n)
	local git = Git.clone(path, cache.get_path(n)):set_depth(1)

	if branch ~= "" then
		git:set_branch(branch)
	end

	local status, err = git:execute()

	if not status then
		return false, err
	end

	return true, nil
end



return cache