local luau = require("@std/luau")
local test = require("@std/test")

local find = require("@root/find")
local log = require("@scripts/lib/log")

local function loadTestCases(path: string)
	local files = find(path, "%.spec%.luau")

	log.info("spec files:")
	for _, file in files do
		log.info(`  {file}`)
	end

	for _, file in files do
		luau.loadbypath(file)
	end
end

loadTestCases("src")

test.run()
