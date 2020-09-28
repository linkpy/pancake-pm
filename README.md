Pancake Package Manager for Nelua
=================================


Simple package manager for Nelua.


Structure of a package
----------------------

 - `package-name/` : root directory of the package.
   - `package.lua` : configuration file of the package.


Structure of a configuration file
---------------------------------

The configuration file returns a table which ***MUST*** (not sanitized or type checked) follows the format :

```lua

return {
	-- Name of the package. Only used for `ppm build`.
	name = "package-name",
	-- Automatically generated, but for now unused.
	author = "username",
	-- Version of the package (not sanitized or verified, you should use the format X.Y.Z)
	version = "1.0.0",

	-- Source directory. Injected in the path for '.nelua' files. Can be empty to disable injection.
	src_dir = "sources/",
	-- Meta source directory. Injected in the path for '.lua' files and in preprocessor source code. Can be empty to disable injection.
	meta_dir = "sources/",
	-- File loaded by the injector. Can be empty to disable.
	build_cfg = "build.nelua", 

	-- List of dependencies
	dependencies = {
		-- Gets the package from the github repo 'username/package-name' as its lastest version (master branch)
		"username/package-name",
		-- Same as above, but get the specific version (branch or tag).
		"username/package-name#version"
	}
}

```


CLI Tool
--------

 - `ppm help` : prints help text
 - `ppm init` : initializes a new package
 - `ppm update` : updates the dependencies
 - `ppm build` : builds the package
 - `ppm test` : builds the package with `-DTEST`

All of these commands can receive an additional argument, being the path to the package to deal with.
