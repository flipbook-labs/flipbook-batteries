local process = require("@lute/process")

local log = require("@scripts/lib/log")
local project = require("@repo/project")
local run = require("@root/run")

local failures: { string } = {}

local function catchFailure(job: string, callback: () -> ())
	local ok = pcall(callback)

	if not ok then
		table.insert(failures, job)
	end
end

log.info("linting with Selene...")
catchFailure("selene", function()
	run("selene", { table.unpack(project.FOLDERS_TO_LINT) })
end)

log.info("checking formatting with Stylua...")
catchFailure("stylua", function()
	run("stylua", { "--check", table.unpack(project.FOLDERS_TO_LINT) })
end)

log.info("analyzing Luau source...")
catchFailure("luau-lsp", function()
	run("luau-lsp", {
		"analyze",
		"--settings=./.vscode/settings.json",
		"src",
		"scripts",
	})
end)

if #failures > 0 then
	local failedJobs
	if #failures > 2 then
		local last = table.remove(failures, #failures)
		failedJobs = `{table.concat(failures, ", ")}, and {last}`
	else
		failedJobs = failures[1]
	end

	log.err(`one or more analysis steps failed: {failedJobs}`)
	process.exit(1)
end
