
local class = require 'nelua.utils.class'
local stringer = require 'nelua.utils.stringer'
local fs = require 'nelua.utils.fs'

local SemVer = require 'thirdparty.semver'

local cache = require 'ppm.cache'
local utils = require 'ppm.utils'
local Git = require 'ppm.git'


local pkg = {}

local Descriptor = class()
pkg.Descriptor = Descriptor


function Descriptor:_init(descriptor)
	self.descriptor = descriptor
end



function Descriptor:get_socket()
	local i = self.descriptor:find(':')
	return self.descriptor:sub(1, i-1)
end

function Descriptor:get_path()
	local i = self.descriptor:find(':')
	return self.descriptor:sub(i+1, -1)
end




function Descriptor:get_url()
	if self:is_github() then
		return self:gh_get_host() .. "/" .. self:gh_get_user() .. "/" .. self:gh_get_repo_name() .. ".git"
	elseif self:is_http() then
		return self:http_get_url()
	end

	return self.descriptor
end

function Descriptor:get_version()
	if self:is_github() then
		return self:gh_get_repo_version()
	elseif self:is_http() then
		return self:http_get_repo_version()
	end

	return nil
end

function Descriptor:get_name()
	if self:is_github() then
		return self:gh_get_repo_name()
	elseif self:is_http() then
		return self:http_get_repo_name()
	end

	error("Not supported for this kind of descriptor.")
end



function Descriptor:is_github()
	return self:get_socket() == "github" or self:get_socket() == "gitlab"
end

function Descriptor:is_http()
	return self:get_socket() == "http" or self:get_socket() == "https"
end



function Descriptor:gh_get_user()
	assert(self:is_github(), "This is not a github descriptor.")
	local p = self:get_path()
	local i = p:find('/')
	return p:sub(1, i-1)
end

function Descriptor:gh_get_repo()
	assert(self:is_github(), "This is not a github descriptor.")
	local p = self:get_path()
	local i = p:find('/')
	return p:sub(i+1, -1)
end

function Descriptor:gh_get_repo_name()
	assert(self:is_github(), "This is not a github descriptor.")
	local p = self:gh_get_repo()
	local i = p:find('#')

	return i and p:sub(1, i-1) or p
end

function Descriptor:gh_get_repo_version()
	assert(self:is_github(), "This is not a github descriptor.")
	local p = self:gh_get_repo()
	local i = p:find('#')

	return i and SemVer(p:sub(i+2, -1)) or nil
end

function Descriptor:gh_get_host()
	assert(self:is_github(), "This is not a github descriptor.")

	return "https://" .. self:get_socket() .. ".com"
end



function Descriptor:http_get_url()
	assert(self:is_http(), "This is not an http descriptor.")
	local p = self.descriptor
	local i = p:find('#')
	return i and p:sub(1, i-1) or p
end

function Descriptor:http_get_repo_version()
	local i = p:find('#')
	return i and SemVer(p:sub(i+2, -1)) or nil
end

function Descriptor:http_get_repo_name()
	local p = self:http_get_url()
	local parts = stringer.split(p, '/')
	local name = parts[#parts]

	if stringer.endswith(name, ".git") then
		return name:sub(1, -5)
	end

	return name
end



local Package = class()
pkg.Package = Package


function Package:_init(desc)
	if desc == "." then
		self.descriptor = nil
		self.name = "."

	else
		self.descriptor = Descriptor(desc)

		self.name = self.descriptor:get_name()
		self.url = self.descriptor:get_url()
		self.version = self.descriptor:get_version()
	end
end



function Package:is_cached()
	return cache.has(self.name)
end

function Package:get_cached_version()
	return cache.version(self.name)
end

function Package:get_cached_path()
	if self.descriptor == nil then
		return self.path
	end

	return cache.get_path(self.name)
end


function Package:get_version_string()
	if self.version == nil then
		return ""
	else
		return "v" .. tostring(self.version)
	end
end



function Package:does_need_update()
	if self.descriptor == nil then return false end

	if not self:is_cached() then
		return true
	end

	local cver = self:get_cached_version()
	local dver = self.version

	return cver ~= dver -- if cver > dver, we need to downgrade
end

function Package:update(force)
	NAMESPACE = "pkg(" .. self.name .. ")"
	printv("Updating package '" .. self.name .. "'...")

	local ok,err

	if self.descriptor ~= nil then
		if not force and not self:does_need_update() then
			printv("Package up to date (already up to date).")
		else		
			printv(".... Fetching package...")
			if self:is_cached() then
				ok, err = self:_checkout()
			else
				ok, err = self:_fetch()
			end

			if not ok then 
				error("Failed to update package '" .. self.name .. "': " .. err)
			end
		end
	end

	printv(".... Loading package configuration...")
	ok, err = utils.safe_load(fs.join(self:get_cached_path(), 'package.lua'))
	if not ok then
		error("Failed to load package '" .. self.name .. "': " .. err)
	end

	printv("Packaged updated.")
	NAMESPACE = "ppm"
end



function Package:_checkout()
	printv("........ Package already cached, fetching the new version...")

	local v = self:get_version_string()
	local p = self:get_cached_path()

	if v == "" then v = "master" end

	local ok, err = Git.fetch('origin', v):set_directory(p):execute()
	if not ok then return nil, err end

	local ok, err = Git.checkout('FETCH_HEAD'):set_directory(p):execute()
	if not ok then return nil, err end

	printv(".... Packaged up to date (checked out).")
	return true
end

function Package:_fetch()
	printv("........ Packaged not cached, fetching it...")

	local v = self:get_version_string()
	local p = self:get_cached_path()

	local git = Git.clone(self.url, p):set_depth(1)

	if v ~= "" then git:set_branch(v) end

	local ok, err = git:execute()
	if not ok then return nil, err end

	printv(".... Packaged updated (fetched).")
	return true
end



return pkg