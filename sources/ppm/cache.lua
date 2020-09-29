
local fs = require 'nelua.utils.fs'
local lfs = require 'lfs'
local utils = require 'ppm.utils'

local Executer = require 'ppm.executer'
local Git = require 'ppm.git'
local SemVer = require 'thirdparty.semver'


local cache = {}
cache.path = ""



function cache.check()
	printv("Checking cache...")

	if not fs.isdir(cache.path) then
		printv("Cache not found, creating it...")
		local status, err = Executer.exec('mkdir', {cache.path})

		if not status then
			error("Cache invalid : cannot create folder '" .. cache.path .. "'.")
		end
	end

	printv("Cache is valid.")
end

function cache.has(n)
	return fs.isdir(cache.get_path(n))
end

function cache.version(n)
	return SemVer(Git.get_tag(cache.get_path(n)):sub(2, -1))
end

function cache.get_path(n)
	return fs.join(cache.path, 'ppm_cache', n)
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
	local version = Version(branch)
	local git = Git.clone(path, cache.get_path(n)):set_depth(1)

	if not version:is_any_major() then
		git:set_branch(branch)
	end

	local status, err = git:execute()

	if not status then
		return false, err
	end

	return true, nil
end



return cache