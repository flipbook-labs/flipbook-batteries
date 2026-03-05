local path = require("@std/path")
local process = require("@std/process")
local richterm = require("@root/batteries/richterm")

type Options = {
	cwd: path.pathlike?,
	env: { [string]: string }?,
	stdio: ("default" | "inherit" | "none")?,
}

-- By default this function will return nil, but in the case where you want to
-- capture stdout you can set `stdio = "default"`. The reason you have to opt-in
-- to this is because Lute doesn't offer a "stream to terminal output but also
-- propagate stdout when done" option. You can have one or the other.
local function run(program: string, params: { string | number | boolean | path.pathlike }, options: Options?): string?
	local stringParams: { string } = {}
	for _, param in params do
		table.insert(stringParams, tostring(param))
	end

	local command = `{program} {table.concat(stringParams, " ")}`
	print(richterm.dim(`> {command}`))

	local processSystemOptions: process.processsystemoptions = {
		stdio = if options and options.stdio then options.stdio else "inherit",
		cwd = if options and options.cwd then tostring(options.cwd) else nil,
		env = if options then options.env else nil,
	}

	local result = process.system(command, processSystemOptions)

	if result.ok then
		if processSystemOptions.stdio ~= "inherit" then
			local stdout = result.stdout:gsub("^\n", ""):gsub("\n$", "")

			print(stdout)

			return if stdout ~= "" then stdout else nil
		end
	else
		error(result.stderr, 2)
	end

	return nil
end

return run
