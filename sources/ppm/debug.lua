
VERBOSE = true
DEBUG = true

NAMESPACE = "ppm"


function printv(m, ...)
	if VERBOSE then print("[verbose | " .. NAMESPACE .. "] " .. m, ...) end
end

function printd(m, ...)
	if DEBUG then 
		local info = debug.getinfo(2, "nSl")
		local infostr = string.format("%s:%d, in %s (%d)", info.short_src, info.currentline, info.name, info.linedefined)
		print("[debug | " .. NAMESPACE .. "]{" .. infostr .. " } " .. m, ...) 
	end
end
