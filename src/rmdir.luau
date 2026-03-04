local fs = require("@std/fs")

--[[
	DEPRECATED: Use fs.removedirectory from @std with the`recursive` option
	instead
]]
local function rmdir(filePath: string)
	fs.removedirectory(filePath, {
		recursive = true,
	})
end

return rmdir
