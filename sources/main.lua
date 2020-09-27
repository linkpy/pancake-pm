


local function git_clone(url, path)
	local status, errstr, errno = os.execute(string.format("git clone %s %s", url, path))

	if not status then
		print(string.format("Failed to clone '%s' :", url))
		print(errstr)
		os.exit(1)
	end
end




local function print_usage()
	print("USAGE: ppm command [package_path]")
	print("")
	print("Commands :")
	print("  init : Initialize a new package in [package_path].")
	print("  update : Updates the dependencies of [package_path].")
	print("")
	print("Package path :")
	print("  Path to the package. By default, '.'.")
	os.exit(1)
end

local function initialize(p)
	local status, errstr, errno = os.execute(string.format("mkdir -p %s/packages", p))

	if not status then
		print("Failed to initialize package : ")
		print(errstr)
		os.exit(1)
	end

	status, errstr, errno = os.execute(string.format("mkdir -p %s/sources", p))

	if not status then
		print("Failed to initialize package : ")
		print(errstr)
		os.exit(1)
	end

	git_clone("https://github.com/linkpy/pancake-pm.git", string.format("%s/packages/pancake-pm", p))

	local file = io.open(string.format("%s/build.nelua", p), "w")

	if file == nil then
		print("Failed to initialize package :")
		print("  Can't write to build.nelua")
		os.exit(1)
	end

	file:write("\n##[[\n\n")
	file:write("ppm = require 'packages/pancake-pm'\n")
	file:write("ppm.init(config)\n\n]]\n\n")
	file:write("require 'main'")
	file:flush()
	file:close()


	file = io.open(string.format("%s/sources/main.nelua", p), "w")

	if file == nil then
		print("Failed to initialize package :")
		print("  Can't write to sources/main.nelua")
		os.exit(1)
	end

	file:write("\n")
	file:flush()
	file:close()
end

local function update(p)

end








for i, v in ipairs(arg) do
	print(i, v)
end

if #arg <= 1 or #arg >= 3 then
	print_usage()
end

local command = arg[1]
local path = '.'

if #arg == 2 then
	path = arg[2]
end


if command == "init" then
	initialize(path)
elseif command == "update" then
	update(path)
else
	print_usage()
end