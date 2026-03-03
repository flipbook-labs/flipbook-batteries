local path = require("@std/path")
local process = require("@std/process")
local richterm = require("@root/batteries/richterm")

type Options = {
	cwd: string?,
	env: { [string]: string }?,
	display: boolean,

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

	local command = { program, table.unpack(stringParams) }
	print(richterm.dim(`> {table.concat(command, " ")}`))

	local result = process.run(command, {
		stdio = "default",
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	if result.ok then
		local trimmed = result.stdout:gsub("^\n", ""):gsub("\n$", "")

		if shouldDisplay then
			print(trimmed)
		end

		return trimmed
	else
		error(result.stderr, 2)
	end
end

return run
