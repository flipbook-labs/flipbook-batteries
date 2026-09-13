-- upstream: https://github.com/luau-lang/lute/blob/main/batteries/cli.luau
-- Fork extends the parser with buildHelp/printHelp and auto-adds --help.

local cli = {}
cli.__index = cli

type ArgKind = "positional" | "flag" | "option" | "variadic"
type ArgOptions = {
	help: string?,
	aliases: { string }?,
	default: string?,
	required: boolean?,
	hidden: boolean?,
}

type ArgData = {
	name: string,
	kind: ArgKind,
	options: ArgOptions,
}

type ParseResult = {
	values: { [string]: string? },
	flags: { [string]: boolean },
	variadics: { string },
	fwdArgs: { string },
}

type ParserData = {
	arguments: { [number]: ArgData },
	positional: { [number]: ArgData },
	variadicArg: ArgData?,
	parsed: ParseResult,
}

type ParserInterface = typeof(cli)
export type Parser = setmetatable<ParserData, ParserInterface>

-- Help formatting constants
local FLAG_COLUMN_WIDTH = 26

local function formatFlagPart(name: string, kind: string, aliases: { string }?): string
	if kind == "option" then
		return `--{name} <{name}>`
	end

	local aliasPart = ""
	if aliases and #aliases > 0 then
		aliasPart = `, -{table.concat(aliases :: { string }, ", -")}`
	end
	return `--{name}{aliasPart}`
end

local function formatHelpSuffix(help: string?, default: string?): string
	local parts: { string } = {}
	if help and help ~= "" then
		table.insert(parts, help)
	end
	if default then
		table.insert(parts, `(default: {default})`)
	end
	return table.concat(parts, " ")
end

local function formatArgLine(name: string, kind: string, options: ArgOptions): string
	local flagPart = formatFlagPart(name, kind, options.aliases)
	local padding = math.max(1, FLAG_COLUMN_WIDTH - #flagPart)
	local helpPart = formatHelpSuffix(options.help, options.default)
	return `  {flagPart}{string.rep(" ", padding)}{helpPart}`
end

local function appendSection(lines: { string }, heading: string, bodyLines: { string })
	table.insert(lines, heading .. ":")
	for _, line in bodyLines do
		table.insert(lines, line)
	end
	table.insert(lines, "")
end

function cli.parser(): Parser
	local self = {
		arguments = {},
		positional = {},
		variadicArg = nil :: ArgData?,
		parsed = { values = {}, flags = {}, variadics = {}, fwdArgs = {} },
	}

	local parser = setmetatable(self, cli)
	parser:add("help", "flag", { hidden = true, help = "Show this help message" })
	return parser
end

function cli.add(self: Parser, name: string, kind: ArgKind, options: ArgOptions): ()
	local argument: ArgData = {
		name = name,
		kind = kind,
		options = options or { aliases = {}, required = false },
	}

	table.insert(self.arguments, argument)
	if kind == "positional" then
		table.insert(self.positional, argument)
	elseif kind == "variadic" then
		self.variadicArg = argument
	end
end

function cli.parse(self: Parser, args: { string }): ()
	local i = 0
	local pos_index = 1

	while i < #args do
		i += 1

		local arg = args[i]

		-- if the argument is exactly "--", we pass everything along
		if arg == "--" then
			table.move(args, i + 1, #args, #self.parsed.fwdArgs + 1, self.parsed.fwdArgs)
			break
		end

		-- if the argument starts with two dashes, we're parsing either a flag or an option
		if string.sub(arg, 1, 2) == "--" then
			local name = string.sub(arg, 3)
			local found = false

			for _, argument in self.arguments do
				local aliases = argument.options.aliases or {}

				if argument.name == name or table.find(aliases, name) then
					found = true

					if argument.kind == "option" then
						-- advance past the argument
						i += 1

						assert(i <= #args, "Missing value for argument: " .. argument.name)
						self.parsed.values[argument.name] = args[i]

						break
					end

					self.parsed.flags[argument.name] = true
					break
				end
			end

			assert(found, "Unknown argument: " .. name)
			continue
		end

		-- if the argument starts with a single dash, we're parsing a flag
		if string.sub(arg, 1, 1) == "-" then
			local flags = string.sub(arg, 2)

			for j = 1, #flags do
				local name = string.sub(flags, j, j)
				local found = false
				for _, argument in self.arguments do
					local aliases = argument.options.aliases or {}
					if argument.name == name or table.find(aliases, name) then
						found = true
						if argument.kind == "option" then
							i += 1
							assert(i <= #args, "Missing value for argument: " .. argument.name)
							self.parsed.values[argument.name] = args[i]
						else
							self.parsed.flags[argument.name] = true
						end
						break
					end
				end

				assert(found, "Unknown argument: " .. name)
			end

			continue
		end

		-- if we have positional arguments left, we can take this argument as one
		if pos_index <= #self.positional then
			self.parsed.values[self.positional[pos_index].name] = arg
			pos_index += 1
			continue
		end

		-- if we have a variadic argument, we can take this argument as part of it
		if self.variadicArg then
			table.insert(self.parsed.variadics, arg)
			continue
		end

		-- otherwise, the argument is forwarded on
		table.insert(self.parsed.fwdArgs, arg)
	end

	-- --help short-circuits required argument validation
	if self.parsed.flags["help"] then
		return
	end

	-- check that all required arguments are present, and set any default values as needed
	for _, argument in self.arguments do
		if argument.options.required then
			if argument.kind == "variadic" then
				assert(#self.parsed.variadics > 0, "Missing required variadic argument: " .. argument.name)
			else
				assert(self.parsed.values[argument.name], "Missing required argument: " .. argument.name)
			end
		end

		if self.parsed.values[argument.name] == nil and argument.options.default then
			self.parsed.values[argument.name] = argument.options.default
		end
	end
end

function cli.get(self: Parser, name: string): string?
	return self.parsed.values[name]
end

function cli.has(self: Parser, name: string): boolean
	return self.parsed.flags[name] ~= nil
end

function cli.variadics(self: Parser): { string }
	return self.parsed.variadics
end

function cli.forwarded(self: Parser): { string }?
	return self.parsed.fwdArgs
end

function cli.usage(self: Parser, name: string): string
	local parts = { name }

	for _, arg in self.positional do
		if not arg.options.hidden then
			if arg.options.required then
				table.insert(parts, `<{arg.name}>`)
			else
				table.insert(parts, `[{arg.name}]`)
			end
		end
	end

	for _, arg in self.arguments do
		if not arg.options.hidden and arg.kind ~= "positional" and arg.kind ~= "variadic" then
			table.insert(parts, "[options]")
			break
		end
	end

	if self.variadicArg and not self.variadicArg.options.hidden then
		local v = self.variadicArg
		if v.options.required then
			table.insert(parts, `<{v.name}...>`)
		else
			table.insert(parts, `[{v.name}...]`)
		end
	end

	return table.concat(parts, " ")
end

function cli.buildHelp(self: Parser, title: string, summary: string?): string
	local lines: { string } = { title }

	if summary then
		table.insert(lines, summary)
	end

	table.insert(lines, "")
	table.insert(lines, "USAGE:")
	table.insert(lines, `  {self:usage(title)}`)
	table.insert(lines, "")

	local requiredLines: { string } = {}
	local optionLines: { string } = {}

	for _, argument in self.arguments do
		if argument.options.hidden then
			continue
		end
		if argument.kind == "positional" or argument.kind == "variadic" then
			continue
		end

		local line = formatArgLine(argument.name, argument.kind, argument.options)
		if argument.options.required then
			table.insert(requiredLines, line)
		else
			table.insert(optionLines, line)
		end
	end

	if #requiredLines > 0 then
		appendSection(lines, "REQUIRED", requiredLines)
	end

	if #optionLines > 0 then
		appendSection(lines, "OPTIONS", optionLines)
	end

	-- Trim trailing blank line from last appendSection
	if lines[#lines] == "" then
		table.remove(lines, #lines)
	end

	return table.concat(lines, "\n")
end

function cli.printHelp(self: Parser, title: string, summary: string?): ()
	print(self:buildHelp(title, summary))
end

-- Preserved from upstream for backwards compatibility
function cli.help(self: Parser, formatter: ((s: string) -> string)?): ()
	local fmt = formatter or function(s)
		return s
	end

	print(fmt("Usage:"))
	for _, argument in self.arguments do
		if argument.options.hidden then
			continue
		end

		local aliasStr = table.concat(argument.options.aliases or {}, ", ")
		local reqStr = if argument.options.required then "(required) " else ""
		print(fmt(string.format("  --%s (-%s) - %s%s", argument.name, aliasStr, reqStr, argument.options.help or "")))
	end
end

return table.freeze(cli)
