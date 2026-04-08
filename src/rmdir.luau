local fs = require("@std/fs")
local path = require("@std/path")

--[[
	DEPRECATED: Use fs.removeDirectory from @std with the`recursive` option
	instead
]]
local function rmdir(filePath: path.Pathlike)
	fs.removeDirectory(filePath, {
		recursive = true,
	})
end

return rmdir
