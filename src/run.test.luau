local expect = require("@std/test/assert")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@lute/system")
local test = require("@std/test")

local run = require("./run")

test.case("works with path objects", function()
	local tempFile = path.join(system.tmpdir(), "message.txt")
	fs.writestringtofile(tempFile, "Hello World")

	local res = run("cat", { tempFile }, {
		stdio = "default",
	})

	expect.eq(res, "Hello World")
end)

test.case("go crazy with it", function()
	local res = run("echo", { "Hello", 123, true, process.cwd() }, {
		stdio = "default",
	})

	expect.eq(res, `Hello 123 true {process.cwd()}`)
end)
