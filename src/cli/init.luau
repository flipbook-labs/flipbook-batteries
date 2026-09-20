local cliParser = require("@root/batteries/cli")

return {
	parser = cliParser.parser,
	types = require("@root/cli/types"),
	fatal = require("@root/cli/fatal"),
	runCommand = require("@root/cli/runCommand"),
	createCli = require("@root/cli/createCli"),
}
