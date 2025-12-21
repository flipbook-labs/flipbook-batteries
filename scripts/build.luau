local fs = require("@lute/fs")

local find = require("@root/find")
local log = require("@scripts/lib/log")
local mkdir = require("@root/mkdir")
local project = require("@repo/project")
local rmdir = require("@root/rmdir")
local run = require("@root/run")
local stopwatch = require("@root/stopwatch")

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

local PROJECT_NAME = "flipbook-batteries"
local ARCHIVE_NAME = `{PROJECT_NAME}.zip`

local PROJECT_BUILD_PATH = `{project.BUILD_PATH}/{PROJECT_NAME}`

local elapsed = stopwatch(function()
	log.info(`building project to {PROJECT_BUILD_PATH}...`)
	rmdir(PROJECT_BUILD_PATH)
	mkdir(PROJECT_BUILD_PATH)

	log.info(`copying source files...`)
	for _, includedPath in INCLUDED_PATHS do
		run("cp", { "-R", includedPath, `{PROJECT_BUILD_PATH}/{includedPath}` }, {
			stdio = "default",
		})
	end

	log.info(`pruning development files from build...`)
	for _, excludedPath in EXCLUDED_PATHS do
		local matches = find(PROJECT_BUILD_PATH, excludedPath)

		for _, match in matches do
			fs.remove(match)
		end
	end

	run("zip", { "-r", ARCHIVE_NAME, PROJECT_NAME }, {
		cwd = project.BUILD_PATH,
		stdio = "default",
	})
end)

log.info(`successfully built flipbook-batteries in {elapsed}ms`)
