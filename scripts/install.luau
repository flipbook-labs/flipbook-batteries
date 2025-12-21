local fs = require("@lute/fs")
local process = require("@lute/process")

local project = require("@repo/project")

local function destroy(filePath: string)
	if not fs.exists(filePath) then
		return
	end

	if fs.type(filePath) == "dir" then
		for _, child in fs.listdir(filePath) do
			destroy(`{filePath}/{child.name}`)
		end
		fs.rmdir(filePath)
	else
		fs.remove(filePath)
	end
end

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
			fs.mkdir(current)
		end
	end
end

local function installLuteBatteries()
	destroy(project.LUTE_BATTERIES_PATH)
	mkdir(project.LUTE_BATTERIES_PATH)

	for _, battery in project.LUTE_BATTERIES do
		local res = process.run({
			"curl",
			"-LO",
			`https://raw.githubusercontent.com/luau-lang/lute/{project.LUTE_BATTERIES_COMMIT}/batteries/{battery}`,
		}, {
			cwd = project.LUTE_BATTERIES_PATH,
		})

		assert(res.ok, res.stderr)
	end
end

local res = process.run({ "lute", "setup" })
assert(res.ok, res.stderr)

installLuteBatteries()
