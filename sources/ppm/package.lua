
local fs = require 'nelua.utils.fs'
local lfs = require 'lfs'

local DepGraph = require 'ppm.dep-graph'
local utils = require 'ppm.utils'
local cache = require 'ppm.cache'



local pkg = {}


function pkg.load_config(p)
	local cfg, err = utils.safe_load(fs.join(p, 'package.lua'))

	if not cfg then
		error("Failed to load package configuration for '" .. p .. "': " .. err)
	end

	return cfg
end

function pkg.load_package_config(p)
	return pkg.load_config(cache.get_path(p))
end

function pkg.fetch_deps(cpkg, force)
	local indent = ""
	local depg = DepGraph()
	local first = true


	local function on_visited(node)
		if first then
			first = false
			return
		end

		local just_fetched = false


		if not cache.has(node.data) or force then
			print(indent .. "Fetching '" .. node.data .. "'...")
			local status, err = cache.fetch(node.data, force)

			if not status then
				error("Failed to fetch package '" .. node.data .. "': " .. err)
			end

			just_fetched = true
		end


		local pcfg = pkg.load_package_config(node.data)
		local path, branch = utils.extract_branch_from_github_package(node.data)


		-- want a new version
		if pcfg.version < branch or (branch == "" and pcfg.version ~= "") and not just_fetched then
			print(indent .. "Fetching new version of '" .. node.data .. "'...")
			local status, err = cache.fetch(node.data, force)

			if not status then
				error("Failed to fetch package '" .. node.data .. "': " .. err)
			end
		end


		if pcfg.version ~= branch and branch ~= "" then
			error(string.format("Version mismatch for '%s'. Wanted '%s', got '%s'",
				path, branch, pcfg.version))
		end

		for _, p in ipairs(pcfg.dependencies) do
			node:add_edge(depg:add_package(utils.extract_github_package_name(p), p))
		end

		indent = indent .. "  "
	end

	local function on_resolved(node)
		indent = indent:sub(2, -2)
	end



	depg.on_visited = on_visited
	depg.on_resolved = on_resolved

	local root = depg:add_package(cpkg.name, cpkg, true)

	for _, p in ipairs(cpkg.dependencies) do
		root:add_edge(depg:add_package(utils.extract_github_package_name(p), p))
	end

	return depg:resolve()
end



return pkg