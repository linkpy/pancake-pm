Pancake Package Manager
=======================


Simple package manager for Nelua.


Structure of a package
----------------------

 - `package-name/` : root directory of the package.
   - `package.lua` : configuration file of the package.


How to use
----------

 1. `ppm new mypackage` : this will create a new package in the folder 'mypackage' ;
 2. Add your dependencies in `mypackage/package.lua` ;
 3. `ppm update` : this will fetches the dependencies and generates the package's nelua configuration.
 4. `nelua sources/main.nelua` : compiles and run your package.


Structure of a configuration file
---------------------------------

The configuration file is a simple Lua file with the `ppm` global variable. Example of a configuration file : 

```lua
-- Includes the given folder into the path when nelua is ran in this folder.
ppm.include_sources('sources/')

-- Automatically fetches the sources of that extension from the given website/url.
-- A version must be specified (after #) which is a tag from the package repository.
ppm.add_dependency("github:username/repo#v1.2.3")
ppm.add_dependency("gitlab:username/repo#v1.2.3")
ppm.add_dependency("https://website.com/mypackage.git#v1.2.3")
```

Note : The configuration file is not ran or loaded by Nelua when building the package.


CLI Tool
--------

 - `ppm help` : prints help text
 - `ppm new [path]` : creates a new package
 - `ppm update [force] [path]` : updates the dependencies
 - `ppm clean [path]` : removes the caches folders
