local process = require("@std/process")
local richterm = require("@root/batteries/richterm")

-- Returns `never` so the type checker knows this branch terminates.
-- Enables: local key = parser:get("key") or fatal("--key is required")
local function fatal(message: string): never
	print(richterm.red("Error: " .. message))
	process.exit(1)
	return error("") :: never
end

return fatal
