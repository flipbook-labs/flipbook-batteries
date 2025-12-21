local fs = require("@lute/fs")

local function mkdir(dirPath: string)
	dirPath = dirPath:gsub("/+", "/")

	local current: string

	for _, dir in dirPath:split("/") do
		if current then
			current ..= `/{dir}`
		else
			current = dir
		end

		if not fs.exists(dir) then
			print("mkdir", current)
			fs.mkdir(current)
		end
	end
end

return mkdir
