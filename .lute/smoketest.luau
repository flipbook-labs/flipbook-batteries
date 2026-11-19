local fs = require("@std/fs")
local process = require("@std/process")

local log = require("@scripts/lib/log")
local project = require("@repo/project")
local run = require("@root/run")
local stopwatch = require("@root/stopwatch")

-- flipbook-batteries is a library, so its own build never bundles it into an
-- executable with `lute compile`. Downstream projects do. A require can resolve
-- under `lute run` and in luau-lsp analysis yet fail inside a bundle, because
-- the bundler resolves paths and aliases on its own.
--
-- This smoketest compiles a tiny entry that requires `src/init.luau`, which
-- loads every module, into a real bundle and runs it. If any require in
-- the package doesn't resolve when bundled, the executable aborts and this
-- script fails.

local ENTRY_PATH = `{project.BUILD_PATH}/smoketest-entry.luau`
local OUTPUT_PATH = `{project.BUILD_PATH}/smoketest`

local ENTRY_SOURCE = [[
require("@root")
print("flipbook-batteries bundle loaded")
]]

local elapsed = stopwatch(function()
	if not fs.exists(project.BUILD_PATH) then
		fs.createDirectory(project.BUILD_PATH, {
			makeParents = true,
		})
	end

	log.info("writing the smoketest entry...")
	fs.writeStringToFile(ENTRY_PATH, ENTRY_SOURCE)

	log.info("bundling the entry into an executable...")
	run("lute", { "compile", ENTRY_PATH, "--output", OUTPUT_PATH })

	log.info("running the bundled executable...")
	local ok, result = pcall(function()
		return run(OUTPUT_PATH, {}, {
			captureOutput = true,
		})
	end)

	fs.remove(ENTRY_PATH)

	if not ok then
		log.err("the bundled executable failed to run; the package's aliases likely do not resolve when bundled:")
		log.err(tostring(result))
		process.exit(1)
	end
end)

log.info(`smoketest passed in {elapsed}ms`)
