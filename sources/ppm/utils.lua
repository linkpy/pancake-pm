
local fs = require 'nelua.utils.fs'
local sstream = require 'nelua.utils.sstream'


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
	printd(p)
	local path, _ = utils.extract_branch_from_github_package(p)

	return path:sub(path:find('/')+1, -1)
end

function utils.safe_load(p)
	local results = {pcall(dofile, p)}

	if not results[1] then
		return nil, "Failed to load '" .. p .. "': " .. results[2]
	end

	return table.unpack(results)
end

function utils.value_to_file(v, ss, inden)
	local t = type(v)
	ss = ss or stream()
	inden = inden or 0

	if t == "table" then
		utils.table_to_file(v, ss, inden)
	elseif t == "string" then
		ss:add('[=[' .. v .. ']=]')
	elseif t == "number" then
		ss:add(tostring(v))
	end

	return ss:tostring()
end

function utils.table_to_file(t, ss, inden)
	ss = ss or sstream()
	inden = inden or 0
	inden = inden+1

	ss:add("{\n")

	-- first write numbered keys
	for k, v in ipairs(t) do
		ss:add(string.rep('\t', inden))
		utils.value_to_file(v, ss, inden)
		ss:add(",\n")
	end

	-- then strings
	for k, v in pairs(t) do
		if type(k) == "string" then
			ss:add(string.rep('\t', inden))
			ss:add(k)
			ss:add(" = ")
			utils.value_to_file(v, ss, inden)
			ss:add(",\n")
		end
	end

	ss:add(string.rep('\t', inden-1))
	ss:add("}")
	return ss:tostring()
end



return utils