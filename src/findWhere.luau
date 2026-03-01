local fs = require("@std/fs")
local path = require("@std/path")

local function findWhere(rootDirPath: path.pathlike, matcher: (path: path.pathlike) -> boolean?): { string }
	assert(fs.type(rootDirPath) == "dir", "rootDirPath must be a directory")

	local descendants: { string } = {}

	local function search(rootPath: path.pathlike)
		local isMatch = matcher(rootPath)
		if isMatch == nil then
			return
		elseif isMatch == true then
			table.insert(descendants, tostring(rootPath))
		end

		if fs.type(rootPath) == "dir" then
			for _, child in fs.listdirectory(rootPath) do
				search(path.join(rootPath, child.name))
			end
		end
	end

	search(rootDirPath)

	return descendants
end

return findWhere
