local fs = require("@std/fs")
local path = require("@std/path")

--[[
	DEPRECATED: Use fs.createdirectory from @std with the `makeparents` option
	instead
]]
local function mkdir(dirPath: path.pathlike)
	fs.createdirectory(dirPath, {
		makeparents = true,
	})
end

return mkdir
