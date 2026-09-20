local cli = require("@root/batteries/cli")

export type Parser = cli.Parser

export type Command = {
	run: (args: { string }) -> (),
	title: string,
	summary: string,
	parser: Parser?,
}

return {}
