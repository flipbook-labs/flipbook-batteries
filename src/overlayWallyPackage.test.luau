local expect = require("@std/test/assert")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")
local test = require("@std/test")

local overlayWallyPackage = require("./overlayWallyPackage")

local function getProjectFile(name: string, bundleDirName: string): string
	return `\{"name": "{name}", "tree": \{"$path": "{bundleDirName}"}}`
end

-- A checkout whose only copy of `scope/loader` comes through `scope/app`, the
-- way Flipbook gets ModuleLoader through Storyteller.
local function createCheckout(): path.Path
	local root = path.join(system.tmpdir(), `overlay-wally-package-test-{os.time()}-{math.random(1e6)}`)
	local index = path.join(root, "Packages", "_Index")
	local loader = path.join(index, "scope_loader@0.1.0", "loader")
	local app = path.join(index, "scope_app@1.0.0", "app")

	fs.createDirectory(path.join(loader, "dist"), {
		makeParents = true,
	})
	fs.writeStringToFile(path.join(loader, "default.project.json"), getProjectFile("loader", "dist"))
	fs.writeStringToFile(path.join(loader, "dist", "init.luau"), "export type Class = {}\nreturn {}\n")

	fs.createDirectory(path.join(app, "src"), {
		makeParents = true,
	})
	fs.writeStringToFile(path.join(app, "default.project.json"), getProjectFile("app", "src"))
	fs.writeStringToFile(path.join(app, "src", "init.luau"), "return {}\n")
	fs.writeStringToFile(
		path.join(index, "scope_app@1.0.0", "Loader.lua"),
		'local REQUIRED_MODULE = require(script.Parent.Parent["scope_loader@0.1.0"]["loader"])\n'
			.. "export type Class = REQUIRED_MODULE.Class\n"
			.. "return REQUIRED_MODULE\n"
	)
	fs.writeStringToFile(
		path.join(root, "Packages", "App.lua"),
		'return require(script.Parent._Index["scope_app@1.0.0"]["app"])\n'
	)

	return root
end

-- A development build of `scope/loader` that drops `Class` for `Loader`.
local function createBuild(dependencies: string?): (path.Path, path.Path)
	local root = path.join(system.tmpdir(), `overlay-wally-package-build-{os.time()}-{math.random(1e6)}`)
	local build = path.join(root, "dist")
	fs.createDirectory(build, {
		makeParents = true,
	})
	fs.writeStringToFile(path.join(build, "init.luau"), "export type Loader = {}\nreturn {}\n")

	local manifest = path.join(root, "wally.toml")
	fs.writeStringToFile(
		manifest,
		`[package]\nname = "scope/loader"\nversion = "1.0.0"\n\n[dependencies]\n{dependencies or ""}\n`
	)

	return build, manifest
end

test.case("copies the build over a package the checkout only installs through another package", function()
	local checkout = createCheckout()
	local build, manifest = createBuild()

	local report = overlayWallyPackage({
		package = "scope/loader",
		build = build,
		manifest = manifest,
		target = checkout,
	})

	local install = path.join(checkout, "Packages", "_Index", "scope_loader@0.1.0", "loader")
	expect.eq(#report.installs, 1)
	expect.eq(tostring(report.installs[1]), tostring(install))
	expect.eq(fs.readFileToString(path.join(install, "dist", "init.luau")), "export type Loader = {}\nreturn {}\n")
end)

test.case("rewrites links to the overlaid package with the build's types", function()
	local checkout = createCheckout()
	local build, manifest = createBuild()

	local report = overlayWallyPackage({
		package = "scope/loader",
		build = build,
		manifest = manifest,
		target = checkout,
	})

	local link = path.join(checkout, "Packages", "_Index", "scope_app@1.0.0", "Loader.lua")
	local source = fs.readFileToString(link)
	expect.strContains(source, "export type Loader = REQUIRED_MODULE.Loader")
	expect.strNotContains(source, "Class")

	expect.eq(#report.links, 1)
	expect.eq(tostring(report.links[1].link), tostring(link))
	expect.eq(report.links[1].isCreated, false)
	expect.eq(report.links[1].addedTypes, { "Loader" })
	expect.eq(report.links[1].removedTypes, { "Class" })
end)

test.case("leaves links to other packages as they are", function()
	local checkout = createCheckout()
	local build, manifest = createBuild()

	overlayWallyPackage({
		package = "scope/loader",
		build = build,
		manifest = manifest,
		target = checkout,
	})

	expect.eq(
		fs.readFileToString(path.join(checkout, "Packages", "App.lua")),
		'return require(script.Parent._Index["scope_app@1.0.0"]["app"])\n'
	)
end)

test.case("adds a link for a new dependency the checkout already installs", function()
	local checkout = createCheckout()
	local build, manifest = createBuild('App = "scope/app@1.0.0"')

	local report = overlayWallyPackage({
		package = "scope/loader",
		build = build,
		manifest = manifest,
		target = checkout,
	})

	local link = path.join(checkout, "Packages", "_Index", "scope_loader@0.1.0", "App.lua")
	expect.eq(fs.readFileToString(link), 'return require(script.Parent.Parent["scope_app@1.0.0"]["app"])\n')

	local created = {}
	for _, change in report.links do
		if change.isCreated then
			table.insert(created, tostring(change.link))
		end
	end
	expect.eq(created, { tostring(link) })
	expect.eq(#report.warnings, 0)
end)

test.case("warns about a new dependency the checkout doesn't install", function()
	local checkout = createCheckout()
	local build, manifest = createBuild('Signal = "scope/signal@2.0.0"')

	local report = overlayWallyPackage({
		package = "scope/loader",
		build = build,
		manifest = manifest,
		target = checkout,
	})

	expect.eq(fs.exists(path.join(checkout, "Packages", "_Index", "scope_loader@0.1.0", "Signal.lua")), false)
	expect.eq(#report.warnings, 1)
	expect.strContains(report.warnings[1], "scope/signal")
end)

test.case("errors when the checkout doesn't install the package", function()
	local checkout = createCheckout()
	local build, manifest = createBuild()

	expect.throwsWith(
		`{path.resolve(checkout)} doesn't install scope/missing, directly or through another package`,
		overlayWallyPackage,
		{
			package = "scope/missing",
			build = build,
			manifest = manifest,
			target = checkout,
		}
	)
end)

test.case("refuses a project file that points outside its package", function()
	local checkout = createCheckout()
	local build, manifest = createBuild()
	local install = path.join(checkout, "Packages", "_Index", "scope_loader@0.1.0", "loader")
	fs.writeStringToFile(path.join(install, "default.project.json"), getProjectFile("loader", ".."))

	expect.throws(overlayWallyPackage, {
		package = "scope/loader",
		build = build,
		manifest = manifest,
		target = checkout,
	})

	expect.eq(fs.readFileToString(path.join(install, "dist", "init.luau")), "export type Class = {}\nreturn {}\n")
end)

test.case("leaves the installed package alone when the build folder is missing", function()
	local checkout = createCheckout()
	local _, manifest = createBuild()

	expect.throws(overlayWallyPackage, {
		package = "scope/loader",
		build = path.join(checkout, "missing-dist"),
		manifest = manifest,
		target = checkout,
	})

	local install = path.join(checkout, "Packages", "_Index", "scope_loader@0.1.0", "loader")
	expect.eq(fs.readFileToString(path.join(install, "dist", "init.luau")), "export type Class = {}\nreturn {}\n")
end)

test.case("reads dependencies written with single quotes", function()
	local checkout = createCheckout()
	local build, manifest = createBuild("App = 'scope/app@1.0.0'")

	overlayWallyPackage({
		package = "scope/loader",
		build = build,
		manifest = manifest,
		target = checkout,
	})

	local link = path.join(checkout, "Packages", "_Index", "scope_loader@0.1.0", "App.lua")
	expect.eq(fs.readFileToString(link), 'return require(script.Parent.Parent["scope_app@1.0.0"]["app"])\n')
end)

test.case("rewrites links when the temporary folder's path has a space", function()
	local checkout = createCheckout()
	local build, manifest = createBuild()
	local previousTmpdir = process.env.TMPDIR
	local tmpdir = path.join(system.tmpdir(), `overlay wally package {os.time()}-{math.random(1e6)}`)
	fs.createDirectory(tmpdir, {
		makeParents = true,
	})

	process.env.TMPDIR = tostring(tmpdir)
	local ok, result = pcall(overlayWallyPackage, {
		package = "scope/loader",
		build = build,
		manifest = manifest,
		target = checkout,
	})
	process.env.TMPDIR = previousTmpdir
	if not ok then
		error(result, 0)
	end

	local link = path.join(checkout, "Packages", "_Index", "scope_app@1.0.0", "Loader.lua")
	expect.strContains(fs.readFileToString(link), "export type Loader = REQUIRED_MODULE.Loader")
end)

test.case("errors on a dependency line it can't read, before changing the checkout", function()
	local checkout = createCheckout()
	local build, manifest = createBuild('App = { version = "1.0.0" }')

	expect.throwsWith(`could not read line 6 of {manifest} as a Wally dependency`, overlayWallyPackage, {
		package = "scope/loader",
		build = build,
		manifest = manifest,
		target = checkout,
	})

	local install = path.join(checkout, "Packages", "_Index", "scope_loader@0.1.0", "loader")
	expect.eq(fs.readFileToString(path.join(install, "dist", "init.luau")), "export type Class = {}\nreturn {}\n")
end)
