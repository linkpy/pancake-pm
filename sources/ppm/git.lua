
local tabler = require 'nelua.utils.tabler'
local class = require 'nelua.utils.class'
local stringer = require 'nelua.utils.stringer'

local Executer = require 'ppm.executer'
local SemVer = require 'thirdparty.semver'



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


	local args = {"clone", url}

	if #target > 0 then
		table.insert(args, target)
	end

	return Git("git", args)
end

function Git.pull()
	return Git("git", {"pull"})
end

function Git.fetch(r, b)
	return Git('git', {"fetch", r, b})
end

function Git.checkout(target)
	return Git('git', {'checkout', target})
end



function Git.get_commit_hash(p)
	local out, err = Executer.exec("git", {"log", "-n1", '--pretty="%h"'}, p)

	if not out then
		return nil, err
	end

	return out:sub(1,7)
end

function Git.get_tag(p)
	local hash, err = Git.get_commit_hash(p)

	if not hash then
		return nil, err
	end

	local out, err = Executer.exec("git", {"describe", "--exact-match", "--tags", hash}, p)

	if not out then
		return nil, err
	end

	return stringer.split(out, "\n")[1]
end

function Git.fetch_remote_tags(url)
	local out, err = Executer.exec("git", {"ls-remote", "--tags", url})

	if not out then
		return nil, err
	end

	local result = {}

	for i, line in ipairs(stringer.split(out, '\n')) do
		local ref = stringer.split(line, '\t')[2]

		if stringer.startswith(ref, 'refs/tags/v') and not stringer.endswith(ref, "^{}") then
			table.insert(result, SemVer(ref:sub(12, -1)))
		end
	end

	return result
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
