local fs = require("@lute/fs")

local function findWhere(rootDirPath: string, matcher: (path: string) -> boolean?): { string }
	assert(fs.type(rootDirPath) == "dir", "rootDirPath must be a directory")

	local descendants: { string } = {}

	local function search(path: string)
		local isMatch = matcher(path)
		if isMatch == nil then
			return
		elseif isMatch == true then
			table.insert(descendants, path)
		end

		if fs.type(path) == "dir" then
			for _, child in fs.listdir(path) do
				search(`{path}/{child.name}`)
			end
		end
	end

	search(rootDirPath)

	return descendants
end

return findWhere
