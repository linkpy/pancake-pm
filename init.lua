
local fs = require 'nelua.utils.fs'


local ppm = {}
ppm.config = nil


function ppm.init(c)
	ppm.config = c
	ppm.config.path = ppm.config.path .. ";./sources/?.nelua"
	ppm.config.path = ppm.config.path .. ";./sources/?/init.nelua"
end

function ppm.package(n)
	ppm.config.path = ppm.config.path .. ";./packages/" .. n .. "/sources/?.nelua"
	ppm.config.path = ppm.config.path .. ";./packages/" .. n .. "/sources/?/init.nelua"

	if fs.isfile(fs.join('packages', n, 'init.lua')) then
		require('packages.' .. n)
	end
end


return ppm
