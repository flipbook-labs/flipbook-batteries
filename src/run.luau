local path = require("@std/path")
local process = require("@std/process")
local richterm = require("@root/batteries/richterm")

type Options = {
	cwd: path.pathlike?,
	env: { [string]: string }?,
	display: boolean?,

	--- @DEPRECATED: Use `display` instead
	stdio: any,
}

local function run(program: string, params: { string | number | boolean | path.pathlike }, options: Options?): string
	local stringParams: { string } = {}
	for _, param in params do
		table.insert(stringParams, tostring(param))
	end

	local shouldDisplay = false
	if options and (options.display or options.stdio == "inherit") then
		shouldDisplay = true
	end

	local command = `{program} {table.concat(stringParams, " ")}`

	if shouldDisplay then
		print(richterm.dim(`> {command}`))
	end

	local result = process.system(command, {
		stdio = if options and options.stdio then options.stdio else "default",
		cwd = if options and options.cwd then tostring(options.cwd) else nil,
		env = if options then options.env else nil,
	})

	local stdout = result.stdout:gsub("^\n", ""):gsub("\n$", "")
	if shouldDisplay and stdout ~= "" then
		print(stdout)
	end

	if result.ok then
		return stdout
	else
		error(result.stderr, 2)
	end
end

return run
