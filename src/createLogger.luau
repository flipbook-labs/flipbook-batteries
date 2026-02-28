local process = require("@lute/process")

local richterm = require("@scripts/batteries/richterm")

type LogLevel = "info" | "warn" | "err" | "debug"

local LOG_LEVEL_ORDER = {
	"err",
	"info",
	"warn",
	"debug",
}

type Logger = {
	getLogLevel: () -> LogLevel,
	info: (...any) -> (),
	debug: (...any) -> (),
	warn: (...any) -> (),
	err: (...any) -> (),
}

local function createLogger(name: string): Logger
	local function getLogLevel(): LogLevel
		local logLevel = process.env.LOG_LEVEL
		if logLevel and logLevel ~= "" then
			return logLevel:lower() :: LogLevel
		else
			return "info"
		end
	end

	local function canLog(logLevelToCheck: LogLevel): boolean
		local maxPriority = table.find(LOG_LEVEL_ORDER, getLogLevel())
		local priorityToCheck = table.find(LOG_LEVEL_ORDER, logLevelToCheck)

		if maxPriority and priorityToCheck then
			return priorityToCheck <= maxPriority
		else
			return false
		end
	end

	local function info(...)
		if canLog("info") then
			local prefix = richterm.blue(`[{name}] [info]`)
			print(`{prefix} {...}`)
		end
	end

	local function warn(...)
		if canLog("warn") then
			print(richterm.yellow(`[{name}] [warn] {...}`))
		end
	end

	local function err(...)
		if canLog("err") then
			print(richterm.red(`[{name}] [err] {...}`))
		end
	end

	local function debug(...)
		if canLog("debug") then
			print(richterm.black(`[{name}] [debug] {...}`))
		end
	end

	return {
		getLogLevel = getLogLevel,
		info = info,
		warn = warn,
		err = err,
		debug = debug,
	}
end

return createLogger
