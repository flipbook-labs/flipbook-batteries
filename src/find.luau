local path = require("@std/path")

local findWhere = require("@root/findWhere")

local function find(root: string, filenamePattern: string): { string }
	return findWhere(root, function(filePath: path.pathlike)
		local fileName = path.basename(filePath)
		return fileName and fileName:match(filenamePattern) ~= nil
	end)
end

return find
