local fs = require("@lute/fs")

local find = require("@root/find")
local mkdir = require("@root/mkdir")
local project = require("@repo/project")
local rmdir = require("@root/rmdir")
local run = require("@root/run")

local INCLUDED_PATHS = {
	"pkg/",
	"src/",
	".luaurc",
	"init.luau",
	"LICENSE",
	"README.md",
}

local EXCLUDED_PATHS = {
	"%.spec%.luau",
}

rmdir(project.BUILD_PATH)
mkdir(project.BUILD_PATH)

for _, includedPath in INCLUDED_PATHS do
	run("cp", { "-R", includedPath, `{project.BUILD_PATH}/{includedPath}` })
end

for _, excludedPath in EXCLUDED_PATHS do
	local matches = find(project.BUILD_PATH, excludedPath)

	for _, match in matches do
		fs.remove(match)
	end
end
