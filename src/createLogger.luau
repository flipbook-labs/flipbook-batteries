--!strict
--[[
	Creates a named, leveled logger on top of Archivist
	(https://github.com/flipbook-labs/archivist), flipbook-labs' logging
	library. It returns a small API: `info`, `debug`, `warn`, and `err`, called
	as `logger.info(...)`, plus `getLogLevel`. Code that needs more, such as
	sinks, structured fields, or child loggers, can depend on Archivist
	directly.

	Archivist reads the starting level from the LOG_LEVEL environment variable
	when the logger is created, and falls back to info.
]]

local Archivist = require("@lpm/archivist@v0.3.1")

type LogLevel = "trace" | "debug" | "info" | "warn" | "err"

type Logger = {
	getLogLevel: () -> LogLevel,
	info: (...unknown) -> (),
	debug: (...unknown) -> (),
	warn: (...unknown) -> (),
	err: (...unknown) -> (),
}

-- Archivist names its levels in PascalCase, and `getLogLevel` reports them in
-- lowercase. Archivist also has a trace level, which LOG_LEVEL=trace selects.
-- This logger has no `trace` function, but `getLogLevel` still reports it.
local LEVEL_NAMES: { [string]: LogLevel } = {
	Trace = "trace",
	Debug = "debug",
	Info = "info",
	Warn = "warn",
	Err = "err",
}

local function createLogger(name: string): Logger
	-- Archivist's console output is `[level] message` by default. The name
	-- middleware adds the logger's name in front: `[name] [level] message`.
	local logger = Archivist.createLogger(name, {
		middleware = { Archivist.middleware.name },
	})

	return {
		getLogLevel = function(): LogLevel
			return LEVEL_NAMES[logger.getLevel()]
		end,
		info = logger.info,
		debug = logger.debug,
		warn = logger.warn,
		err = logger.err,
	}
end

return createLogger
