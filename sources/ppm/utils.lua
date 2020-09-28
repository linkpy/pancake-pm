
local fs = require 'nelua.utils.fs'


local utils = {}

function utils.write_file(p, c)
	local file = io.open(p, "w")

	if file == nil then
		print("Failed to write " .. p .. " file :")
		print("  Failed to open " .. p .. ".")
		os.exit(1)
	end

	file:write(c)
	file:flush()
	file:close()
end

function utils.extract_branch_from_github_package(p)
	local path = p
	local branch = ""
	local i = p:find("#")

	if i then
		path = p:sub(1, i)
		branch = p:sub(i+1, -1)
	end

	return path, branch
end

function utils.extract_github_package_name(p)
	local path, _ = utils.extract_branch_from_github_package(p)

	return path:sub(path:find('/')+1, -1)
end

function utils.safe_load(p)
	local results = {pcall(dofile, p)}

	if results[1] then
		table.remove(results, 1)
	end

	return table.unpack(results)
end


return utils