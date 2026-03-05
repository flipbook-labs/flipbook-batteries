local fs = require("@std/fs")
local path = require("@std/path")

--[[
	DEPRECATED: Use fs.removedirectory from @std with the`recursive` option
	instead
]]
local function rmdir(filePath: path.pathlike)
	fs.removedirectory(filePath, {
		recursive = true,
	})
end

return rmdir
