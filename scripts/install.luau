local process = require("@lute/process")

local mkdir = require("@root/mkdir")
local project = require("@repo/project")
local rmdir = require("@root/rmdir")

local function installLuteBatteries()
	rmdir(project.LUTE_BATTERIES_PATH)
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
