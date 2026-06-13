local fs = require("@std/fs")
local process = require("@std/process")

local log = require("@scripts/lib/log")
local project = require("@repo/project")
local run = require("@root/run")
local stopwatch = require("@root/stopwatch")

-- flipbook-batteries is a library, so it is never bundled into an executable as
-- part of its own build. That leaves a blind spot: an alias can resolve fine in
-- non-bundled runs and in luau-lsp analysis yet still break every downstream
-- project that bundles the package via `lute compile`. This is exactly what
-- happened with the `@root` alias being written as `src` instead of `./src` --
-- the bundler reads a value without a leading `./` as another alias name and
-- aborts with `could not jump to alias "src"`, but only inside a consumer's
-- bundle.
--
-- This smoketest closes the gap: it compiles a tiny entry that requires a
-- battery through `@root` into a real bundle and runs it. If the bundled
-- aliases are broken, the executable aborts on require and we surface it here.

local ENTRY_PATH = `{project.BUILD_PATH}/smoketest-entry.luau`
local OUTPUT_PATH = `{project.BUILD_PATH}/smoketest`

-- Requiring `run` pulls in `@root/batteries/richterm`, exercising the `@root`
-- alias the same way a downstream consumer's bundle does.
local ENTRY_SOURCE = [[
local _ = require("@root/run")
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
