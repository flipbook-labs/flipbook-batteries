local path = require("@std/path")

local findWhere = require("@root/findWhere")

local function find(root: path.pathlike, filenamePattern: string): { path.path }
	return findWhere(root, function(filePath)
		local fileName = path.basename(filePath)
		return fileName and fileName:match(filenamePattern) ~= nil
	end)
end

return find
