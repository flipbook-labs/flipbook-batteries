local fs = require("@std/fs")
local path = require("@std/path")

--[[
	DEPRECATED: Use fs.createDirectory from @std with the `makeParents` option
	instead
]]
local function mkdir(dirPath: path.Pathlike)
	fs.createDirectory(dirPath, {
		makeParents = true,
	})
end

return mkdir
