
local tabler = require 'nelua.utils.tabler'
local class = require 'nelua.utils.class'
local Executer = require 'ppm.executer'



local function escape_commit_message(mesg)
	return mesg:gsub('([^\\]")', '\\"')
end



local Git = class(Executer)



function Git.has()
	local status, errstr, errno = Executer.exec("git", {"--version"})
	return not not status
end

function Git.init(p)
	p = p or '.'

	assert(type(p) == 'string', "Argument #1 (p) must be a string (if provided")

	return Git("git", {"init", p})
end

function Git.add(p)
	p = p or '.'

	assert(type(p) == 'string', "Argument #1 (p) must be a string (if provided")

	return Git("git", {"add", p})
end

function Git.commit(mesg)
	assert(type(mesg) == "string", "Argument #1 (mesg) must be a string.")

	return Git("git", {"commit", "-m", '"' .. escape_commit_message(mesg) .. '"'})
end

function Git.clone(url, target)
	target = target or ''

	assert(type(url) == 'string', "Argument #1 (url) must be a string")
	assert(type(target) == 'string', "Argument #2 (target) must be a string (if provided)")

	-- github shortcut
	if url:find("^http") ~= 1 then
		url = "https://github.com/" .. url .. ".git"
	end


	local args = {"clone", url}

	if #target > 0 then
		table.insert(args, target)
	end

	return Git("git", args)
end

function Git.pull()
	return Git("git", {"pull"})
end



function Git:set_depth(d)
	return self:add_argument(
		string.format("--depth %d", d),
		"--depth"
	)
end

function Git:set_branch(b)
	return self:add_argument(
		string.format("--branch %s", b),
		"--branch"
	)
end


return Git
