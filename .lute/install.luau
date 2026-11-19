local process = require("@std/process")

-- `--vendor` copies each dependency into a `.lpm/<key>@<rev>` folder, and the
-- `lpm` alias in `.config.luau` points at `.lpm`. A vendored package's own
-- `@lpm` requires resolve through the alias of the project that installed it,
-- so a project that installs a package with `@lpm` requires needs this alias
-- too.
-- https://github.com/flipbook-labs/infra/issues/43 tracks removing that requirement.
local result = process.run({ "lute", "pkg", "install", "--vendor" }, { stdio = "inherit" })
assert(result.ok, "lute pkg install failed")
