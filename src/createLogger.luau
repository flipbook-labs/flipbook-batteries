--!strict
--[[
	Creates a named, leveled logger. Thin compatibility shim over Archivist
	(https://github.com/flipbook-labs/archivist), which is where logging now
	lives; prefer depending on Archivist directly for anything beyond this
	basic surface (sinks, structured fields, batching).

	Kept for API compatibility:
	- dot-style `logger.info(...)` / `debug` / `warn` / `err`
	- `getLogLevel()` reporting the resolved minimum level
	- level resolution from the LOG_LEVEL environment variable
]]

local Archivist = require("@pkg/Archivist@v0.1.0")

type LogLevel = "info" | "warn" | "err" | "debug"

type Logger = {
	getLogLevel: () -> LogLevel,
	info: (...any) -> (),
	debug: (...any) -> (),
	warn: (...any) -> (),
	err: (...any) -> (),
}

local function createLogger(name: string): Logger
	local logger = Archivist.createLogger(name)

	return {
		getLogLevel = function(): LogLevel
			return logger.getLevel() :: LogLevel
		end,
		info = logger.info,
		debug = logger.debug,
		warn = logger.warn,
		err = logger.err,
	}
end

return createLogger
