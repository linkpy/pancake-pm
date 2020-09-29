

local lfs = require 'lfs'
local fs = require 'nelua.utils.fs'
local sstream = require 'nelua.utils.sstream'
local Executer = require 'ppm/executer'
local Git = require 'ppm/git'
local utils = require 'ppm/utils'



return function(path)
	printv("Creating a new package at '" .. path .. "'...")

	local status, err = Executer.exec("mkdir", {
		"-p", fs.join(path, "sources")
	})

	if not status then
		print("Failed to create package directories : ")
		print(err)
		os.exit(1)
	end

	printv("Writing initial files...")

	utils.write_file(fs.join(path, "package.lua"), [==[
ppm.include_sources("sources/")
]==])

	utils.write_file(fs.join(path, "sources/main.nelua"), [==[
print "Hello world!"
]==])

	utils.write_file(fs.join(path, ".gitignore"), [==[
nelua_cache
ppm_cache
.neluacfg.*
]==])


	if Git.has() then

		printv("Initializing git in the package...")

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