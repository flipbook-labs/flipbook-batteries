local process = require("@std/process")

-- Installs the dependencies in `pkg.luau`. `--vendor` copies each one into a
-- `.lpm/<key>@<rev>` folder, and the `lpm` alias in `.config.luau` points at
-- `.lpm`. When a vendored package requires through `@lpm`, the require uses
-- the `lpm` alias of whichever project vendored it. So any project that
-- vendors such a package has to define the same alias.
-- flipbook-labs/infra#43 tracks removing that requirement:
-- https://github.com/flipbook-labs/infra/issues/43
local result = process.run({ "lute", "pkg", "install", "--vendor" }, { stdio = "inherit" })
assert(result.ok, "lute pkg install failed")
