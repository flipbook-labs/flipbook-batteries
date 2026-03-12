return {
	-- Processes
	dotenv = require("@self/dotenv"),
	run = require("@self/run"),

	-- Filesystem
	copyInto = require("@self/copyInto"),
	find = require("@self/find"),
	findAndReplace = require("@self/findAndReplace"),
	findWhere = require("@self/findWhere"),
	getDescendants = require("@self/getDescendants"),
	mkdir = require("@self/mkdir"),
	rmdir = require("@self/rmdir"),
	watch = require("@self/watch"),

	-- Logging
	createLogger = require("@self/createLogger"),

	-- Benchmarking
	stopwatch = require("@self/stopwatch"),
}
