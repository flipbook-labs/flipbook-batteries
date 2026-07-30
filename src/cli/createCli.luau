local process = require("@std/process")
local richterm = require("@root/batteries/richterm")

local runCommand = require("@root/cli/runCommand")
local types = require("@root/cli/types")

local COMMAND_COLUMN_WIDTH = 10

export type Options = {
	name: string,
	summary: string,
	commands: { [string]: types.Command },
	order: { string },
}

local function findSubcommand(args: { string }): (string?, number?)
	local i = 2
	while i <= #args do
		local arg = args[i]
		if string.sub(arg, 1, 2) == "--" then
			i += 2
		elseif string.sub(arg, 1, 1) == "-" then
			i += 1
		else
			return arg, i
		end
	end
	return nil, nil
end

local function buildRootHelp(options: Options): string
	local lines: { string } = {
		options.name,
		options.summary,
		"",
		"USAGE:",
		`  {options.name} <command> [options]`,
		"",
		"COMMANDS:",
	}

	for _, name in options.order do
		local command = options.commands[name]
		if command then
			local padding = math.max(1, COMMAND_COLUMN_WIDTH - #name)
			table.insert(lines, `  {name}{string.rep(" ", padding)}{command.summary}`)
		end
	end

	table.insert(lines, "")
	table.insert(lines, `For more information: {options.name} <command> --help`)

	return table.concat(lines, "\n")
end

local function createCli(options: Options): types.Command
	local function run(args: { string })
		local subcommand, index = findSubcommand(args)

		if not subcommand or subcommand == "help" then
			print(buildRootHelp(options))
			return
		end

		local command = options.commands[subcommand]
		if not command then
			print(richterm.red(`Error: Unknown command '{subcommand}'`))
			print()
			print(buildRootHelp(options))
			process.exit(1)
		end

		local subArgs: { string } = table.move(args, (index :: number) + 1, #args, 1, {})
		runCommand(command, subArgs, options.name)
	end

	return {
		title = options.name,
		summary = options.summary,
		run = run,
	}
end

return createCli
