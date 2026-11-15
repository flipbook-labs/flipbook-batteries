local fs = require("@std/fs")
local luau = require("@std/luau")

local log = require("@scripts/lib/log")
local run = require("@root/run")

local CONFIG_PATH = ".config.luau"
local LOCKFILE_PATH = "pkg.lock.luau"

-- `lute pkg install` puts each dependency in the Loom store under a folder
-- named by a hash of its source and rev. The lockfile records that folder, but
-- `lute check` and editors read aliases only from `.config.luau`. So after
-- installing, this writes each dependency's folder into the alias for it.
-- Keys are aliases in `.config.luau`, and values are dependency names in
-- `pkg.luau`.
local DEPENDENCY_ALIASES: { [string]: string } = {
	batteries = "Lute",
}

type Lockfile = {
	dependencies: { [string]: string },
	devDependencies: { [string]: string }?,
	packages: { [string]: { installPath: string } },
}

local function getStorePath(lockfile: Lockfile, name: string): string
	local key = lockfile.dependencies[name] or (lockfile.devDependencies and lockfile.devDependencies[name])
	assert(key, `{name} is not a dependency in {LOCKFILE_PATH}`)

	-- The lockfile writes `@pkg/` for the store, and an installPath without a
	-- target ends in `/.`.
	local installPath = lockfile.packages[key].installPath
	return (installPath:gsub("^@pkg/", "~/.loom/store/"):gsub("/%.$", ""))
end

run("lute", { "pkg", "install" })

local lockfile: Lockfile = luau.loadModule(LOCKFILE_PATH)
local config = fs.readFileToString(CONFIG_PATH)

for alias, name in DEPENDENCY_ALIASES do
	local storePath = getStorePath(lockfile, name)
	local updated, count = config:gsub(`(%f[%w]{alias}%s*=%s*")[^"]*(")`, `%1{storePath}%2`)
	assert(count == 1, `Expected one "{alias}" alias in {CONFIG_PATH}, found {count}`)
	config = updated
end

fs.writeStringToFile(CONFIG_PATH, config)
log.info(`wrote dependency aliases to {CONFIG_PATH}`)
