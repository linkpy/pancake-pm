Pancake Package Manager for Nelua
=================================


Simple package manager for Nelua.


Structure of a package
----------------------

 - `package-name/` : root directory of the package.
   - `packages/` : folder containing all fetched packages.
   - `sources/` : folder containing the package's sources.
     - `main.nelua` : (optional) main entry point of package.
   - `build.nelua` : build configuration of the package.
   - `init.lua` : (optional) loaded by the package manager when the package is registered.

