
local lfs = require 'lfs'
local class = require 'nelua.utils.class'




local function prepare_command(cmd, args)
	for i, v in ipairs(args) do
		cmd = cmd .. " " .. tostring(v) 
	end

	return cmd
end




local Executer = class()



function Executer:_init(cmd, args, dir)
	args = args or {}
	dir = dir or '.'

	assert(type(cmd) == 'string', "Argument #1 (cmd) must be a string")
	assert(type(args) == 'table', "Argument #2 (args) must be a table (if provided)")
	assert(type(dir) == 'string', "Argument #3 (dir) must be a string (if provided)")


	self.command = cmd
	self.arguments = args
	self.directory = dir
	self.print = false
end

function Executer.exec(cmd, args, dir)
	return Executer(cmd, args, dir):execute()
end



function Executer:enable_printing()
	self.print = true
	return self
end

function Executer:set_directory(dir)
	self.directory = dir
	return self
end

function Executer:add_argument(arg, dupkey)
	if dupkey then
		for i, v in ipairs(self.arguments) do
			if v:find(dupkey) then
				self.arguments[i] = arg
				return self
			end
		end
	end

	table.insert(self.arguments, arg)
	return self
end



function Executer:execute()
	local cmd = prepare_command(self.command, self.arguments)
	local cwd, err = lfs.currentdir()

	if not cwd then
		return nil, 'Executer: failed to retreive current working directory: ' .. tostring(err)
	end

	if self.directory ~= '.' then
		local status, err = lfs.chdir(self.directory)

		if not status then
			return nil, 'exec: failed to changed directory to "' .. t.dir .. '": ' .. tostring(err)
		end
	end

	if self.print then
		cmd = cmd .. " 1>&2"
	else
		cmd = cmd .. " 2>&1"
	end

	local proc = io.popen(cmd .. " 2>&1", "r")

	if not proc then
		return nil, 'exec: failed to execute command: popen failed.'
	end

	local output = proc:read("*all")
	local success, errstr, errno = proc:close()

	if not success then
		print("exec: here is the full command : " .. cmd)
		print("exec: here is the command output :")
		print(output)
		print("exec: end of the command output.")
		return nil, string.format('exec: failed to execute command: command failed (%d: %s)', errno, errstr)
	end

	if self.directory ~= '.' then
		local status, err = lfs.chdir(cwd)

		if not status then
			return nil, 'exec: failed to return to original working director ("' .. cwd .. '"): ' .. err
		end
	end

	return output, nil
end

return Executer
