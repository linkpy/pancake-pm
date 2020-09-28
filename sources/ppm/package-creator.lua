

local lfs = require 'lfs'
local fs = require 'nelua.utils.fs'
local sstream = require 'nelua.utils.sstream'
local Executer = require 'ppm/executer'
local Git = require 'ppm/git'
local utils = require 'ppm/utils'



return function(path)
	local status, err = Executer.exec("mkdir", {
		"-p", fs.join(path, "sources")
	})

	if not status then
		print("Failed to create package directories : ")
		print(err)
		os.exit(1)
	end


	utils.write_file(fs.join(path, "build.nelua"), [==[
#[[

-- Put your build configuration here

]]
]==])

	utils.write_file(fs.join(path, "package.lua"), [==[
return {
	name = "mypackage",
	author = "you",
	version = "1.0",

	src_dir = "sources/",  -- for .nelua files (can be "")
	meta_dir = "sources/", -- for .lua files (during preprocessing) (can be "")
	build_cfg = "build.nelua", -- can be ""
	dependencies = {
		-- "username/package-name" -- get latest version from github
		-- "username/package-name#branch-or-tag" -- get specific version from github
		-- other git aren't supported yet, sry
	}
}
]==])

	utils.write_file(fs.join(path, "sources/main.nelua"), [==[

print "Hello world!"

]==])

	utils.write_file(fs.join(path, ".gitignore"), [==[
nelua_cache
ppm_cache
]==])


	if Git.has() then

		local status, err = Git.init():set_directory(path):execute()

		if not status then
			print("Failed to initialize git repo :")
			print(err)
			os.exit(1)
		end


		local status, err = Git.add():set_directory(path):execute()

		if not status then
			print("Failed to add files to git repo :")
			print(err)
			os.exit(1)
		end

		local status, err = Git.commit("Initial commit."):set_directory(path):execute()

		if not status then
			print("Failed to commit to the git repo :")
			print(err)
			os.exit(1)
		end

	else
		print("Git not found, ignoring git repo creation and setup.")
	end

	print("Package '" .. path .. "' created.")
end