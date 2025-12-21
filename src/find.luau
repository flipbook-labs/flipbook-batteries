local findWhere = require("@root/findWhere")

local function find(root: string, filenamePattern: string): { string }
	return findWhere(root, function(path)
		local parts = path:split("/")
		local filename = parts[#parts]
		return if filename:match(filenamePattern) then true else false
	end)
end

return find
