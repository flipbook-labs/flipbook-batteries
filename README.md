# FlipbookBatteries

FlipbookBatteries is a set of Luau modules for [Lute](https://github.com/luau-lang/lute) scripts. They cover running programs, working with files and folders, loading `.env` files, logging, and timing code.

## Install

FlipbookBatteries ships as a Lute package. Add it to the `dependencies` table in `pkg.luau`:

```luau
["flipbook-batteries"] = {
	rev = "v0.13.1",
	sourceKind = "github",
	source = "https://github.com/flipbook-labs/flipbook-batteries",
},
```

Then run `lute pkg install --vendor`. This copies the package into `.lpm/`, so your project's `.config.luau` needs an `lpm` alias that points there. Add `lpm = "./.lpm"` to the `aliases` table. This setup requires Lute `1.0.1-nightly.20261117` or newer. [flipbook-labs/flipbook#694](https://github.com/flipbook-labs/flipbook/issues/694) tracks removing the alias requirement.

## Use

Require the package from a Lute script and call its modules:

```luau
local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")

local createLogger = FlipbookBatteries.createLogger
local run = FlipbookBatteries.run

local log = createLogger("format")

log.info("Checking formatting")
run("stylua", { "--check", "src" })
```

## Modules

- `createLogger(name)`: returns `debug`, `info`, `warn`, and `err` functions that print with a `[name]` prefix, built on [Archivist](https://github.com/flipbook-labs/archivist). The `LOG_LEVEL` environment variable sets the lowest level that prints, from `debug` up to `err`. It defaults to `info`, which prints info, warnings, and errors.
- `dotenv()`: loads the `.env` file in the current directory into `process.env`. Only keys made of uppercase letters and underscores load.
- `run(program, params, options?)`: runs a program with the given arguments and prints the command first. Set `captureOutput = true` to return its trimmed stdout. `options` also accepts `cwd` and `env`. The call errors if the program fails.
- `find(root, filenamePattern)`: returns the paths under `root` whose file name matches a Lua pattern.
- `findWhere(root, matcher)`: returns the paths under `root` for which `matcher` returns `true`. If `matcher` returns `nil`, that path and everything beneath it are skipped.
- `findAndReplace(filePath, match, replacement)`: replaces every match of a Lua pattern in a file and writes the file back.
- `getDescendants(dirPath)`: returns every file and folder under `dirPath`, or an empty list if it is not a folder.
- `copyInto(src, dest)`: copies a file to `dest`, or a folder's contents into `dest`. A folder copy creates any missing folders, but a file copy needs `dest`'s parent folder to exist.
- `watch({ roots, excludedFilePatterns?, onChanged? })`: watches the folders inside each root and calls `onChanged` with the watched folder that changed. It runs until the script stops.
- `overlayWallyPackage({ package, build, manifest, target })`: copies a development build of a Wally package, such as its `dist/` folder, over every copy of that package in another checkout's `Packages/_Index`. That includes copies the checkout only gets through another package. It then rewrites the Wally link files that point at those copies so their type re-exports match the build, adds links for dependencies the build gained, and prints what changed. It needs `rojo` and `wally-package-types` on the PATH. The checkout's next `wally install` undoes it.
- `stopwatch(callback)`: runs `callback` and returns how long it took, in milliseconds, rounded to three decimal places.
- `mkdir` and `rmdir`: deprecated. Use `createDirectory(dirPath, { makeParents = true })` and `removeDirectory(dirPath, { recursive = true })` from Lute's `@std/fs` instead.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT.
