local process = require("@std/process")
local richterm = require("@root/batteries/richterm")

local types = require("@root/cli/types")

-- Parse a command's args then run it. Handles --help and parse errors uniformly.
-- programName is prepended to command.title in help output (e.g. "changewrite gate").
local function runCommand(command: types.Command, args: { string }, programName: string?): ()
	if command.parser then
		local fullTitle = if programName then `{programName} {command.title}` else command.title

		local ok, err = pcall(command.parser.parse, command.parser, args)
		if not ok then
			local message = tostring(err):match(":%d+: (.+)$") or tostring(err)
			print(richterm.red("Error: " .. message))
			print()
			command.parser:printHelp(fullTitle, command.summary)
			process.exit(1)
		end

		if command.parser:has("help") then
			command.parser:printHelp(fullTitle, command.summary)
			process.exit(0)
		end
	end

	command.run(args)
end

return runCommand
