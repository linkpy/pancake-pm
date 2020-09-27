Pancake Package Manager for Nelua
=================================


Simple package manager for Nelua.


Structure of a package
----------------------

 - `package-name/` : root directory of the package.
   - `packages/` : folder containing all fetched packages.
   - `sources/` : folder containing the package's sources.
     - `main.nelua` : (optional) main entry point of package.
   - `build.nelua` : build configuration of the package. loaded by the compiler when the package is registered
   - `init.lua` : (optional) loaded by the package manager when the package is registered.


CLI Tool
--------

 - `ppm init [path]` : initialize a new package at the given path ('.' if not specified)
 - `ppm update [path]` : updates the packages of the package at the given path ('.' if not specified)
 - `ppm build [path]` : build the package at the given path ('.' if not specified)


Usage
-----


In the generate `build.nelua`, to add a new package just add :

```lua
## ppm.package('username/repo-name')
```

This will fetch the package from `https://github.com/username/repo-name.git`.

If the package has the file `package-name/sources/myfile.nelua`, it can be loaded by doing `require 'myfile'` (also works with `.lua` files for the preprocessor).

If the package is loaded by another package, the global PPM_SUB_PACKAGE will be set to true in the preprocessor.

PPM automatically creates a .gitignore file with `packages/*` excluded **but** `packages/pancake-pm` included (removing that folder makes everything to fail) and automatically setup a git repo.