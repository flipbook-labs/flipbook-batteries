local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local copyInto = require("@root/copyInto")

export type Options = {
	-- Wally name of the package, such as `flipbook-labs/module-loader`.
	package: string,
	-- Folder holding the development build, such as the package's `dist/`.
	build: path.Pathlike,
	-- The package's own `wally.toml`, read for the dependencies of the build.
	manifest: path.Pathlike,
	-- Root of the checkout that receives the build.
	target: path.Pathlike,
}

export type LinkChange = {
	link: path.Path,
	isCreated: boolean,
	addedTypes: { string },
	removedTypes: { string },
}

export type Report = {
	installs: { path.Path },
	links: { LinkChange },
	warnings: { string },
}

type PendingLink = {
	link: path.Path,
	source: string,
	isCreated: boolean,
}

local function escapePattern(text: string): string
	return (text:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end

local function parseWallyName(name: string): (string, string)
	local scope, packageName = name:match("^([%w%-_]+)/([%w%-_]+)$")
	assert(scope and packageName, `expected a Wally name like "scope/name", got "{name}"`)
	return scope, packageName
end

-- Wally names each install folder `<scope>_<name>@<version>`.
local function findInstallFolderNames(index: path.Path, wallyName: string): { string }
	local scope, packageName = parseWallyName(wallyName)
	local pattern = `^{escapePattern(scope)}_{escapePattern(packageName)}@`
	local folderNames = {}
	for _, entry in fs.listDirectory(index) do
		if entry.type == "dir" and entry.name:match(pattern) then
			table.insert(folderNames, entry.name)
		end
	end
	table.sort(folderNames)
	return folderNames
end

-- Passes each argument to the program as is. The scratch folder lives in the
-- system's temporary folder, whose path can contain spaces.
local function runTool(args: { string })
	print(`> {table.concat(args, " ")}`)
	local result = process.run(args, {
		stdio = "inherit",
	})
	if not result.ok then
		error(`{args[1]} failed with exit code {result.exitcode}`)
	end
end

local function readExportedTypes(link: path.Pathlike): { [string]: true }
	local types = {}
	if fs.exists(link) then
		for name in fs.readFileToString(link):gmatch("export type ([%w_]+)") do
			types[name] = true
		end
	end
	return types
end

local function listMissing(names: { [string]: true }, from: { [string]: true }): { string }
	local missing = {}
	for name in names do
		if not from[name] then
			table.insert(missing, name)
		end
	end
	table.sort(missing)
	return missing
end

--[[
	Copies a development build of a Wally package over every copy of that
	package in another checkout's `Packages/_Index`, then rewrites the Wally
	link files that point at those copies.

	Wally can't install path or git dependencies, so this is how a checkout
	tries an unreleased build of a package it depends on. Wally gives each
	installed package a folder in `_Index`, whether the checkout depends on it
	directly or only through another package, as Flipbook gets ModuleLoader
	through Storyteller. So every copy is found and overlaid, and the checkout
	needn't depend on the package itself.

	A link file is the small module Wally writes so one package can require
	another, such as `Packages/Storyteller.lua`. wally-package-types adds a
	re-export to it for each type the installed version exports. A
	development build can add or remove types, so each link to an overlaid
	copy is rewritten from the build. The function prints the types each link
	gained or lost, and returns the same details as a report.

	The build can also depend on a package the installed version didn't. When
	the checkout installs that package anywhere in `_Index`, the overlaid copy
	gets a new link to the first installed copy, by folder name. Otherwise the
	report warns that the link is missing.

	This needs `rojo` and `wally-package-types` on the PATH. The next `wally
	install` in the checkout puts the released packages back.
]]
local function overlayWallyPackage(options: Options): Report
	local _, packageName = parseWallyName(options.package)
	local target = path.resolve(tostring(options.target))
	local packagesRoot = path.join(target, "Packages")
	local index = path.join(packagesRoot, "_Index")
	local report: Report = {
		installs = {},
		links = {},
		warnings = {},
	}

	if not fs.exists(index) then
		error(`{target} has no Packages/_Index. Install its Wally packages first`)
	end

	local installFolderNames = findInstallFolderNames(index, options.package)
	if #installFolderNames == 0 then
		error(`{target} doesn't install {options.package}, directly or through another package`)
	end

	if fs.type(options.build) ~= "dir" then
		error(`the build folder {options.build} doesn't exist. Build the package first`)
	end

	--[[
		Only the `[dependencies]` table matters. Wally doesn't install a
		package's `[dev-dependencies]` for a checkout that depends on it. Each
		entry there is an alias and a quoted `scope/name@version`.

		Lute's TOML parser uses syntax that luau-lsp can't parse yet. Requiring
		it here would fail analysis in every project that requires this
		package, so this reads the table by line instead and errors on a line
		it can't read.
	]]
	local dependencies: { [string]: string } = {}
	local isInDependencies = false
	for lineNumber, line in fs.readFileToString(options.manifest):split("\n") do
		local content = line:gsub("#.*$", ""):match("^%s*(.-)%s*$") :: string
		local section = content:match("^%[([^%]]+)%]$")
		if section then
			isInDependencies = section == "dependencies"
		elseif isInDependencies and content ~= "" then
			local alias, _, dependency = content:match("^([%w_%-]+)%s*=%s*([\"'])([^\"'@]+)@[^\"']*%2$")
			if not alias or not dependency then
				error(`could not read line {lineNumber} of {options.manifest} as a Wally dependency`)
			end
			parseWallyName(dependency)
			dependencies[alias] = dependency
		end
	end

	--[[
		Each install folder holds the package in a `<name>` folder. The
		package's Rojo project file maps its whole tree to the folder inside
		that one where its code lives, so the first `$path` in the file names
		it. Without a project file, the code is assumed to be in `dist`, where
		the flipbook-labs packages keep it.

		Each of those folders is deleted before the build is copied in, so a
		`$path` that leads outside the package is refused. Everything above
		and here is checked before the first file changes, so a bad argument
		leaves the checkout as it was.
	]]
	local bundles: { path.Path } = {}
	for _, folderName in installFolderNames do
		local install = path.join(index, folderName, packageName)
		local bundleDirName = "dist"
		local projectFile = path.join(install, "default.project.json")
		if fs.exists(projectFile) then
			local bundlePath = fs.readFileToString(projectFile):match('"%$path"%s*:%s*"([^"]+)"')
			if bundlePath then
				bundleDirName = bundlePath
			end
		end

		local bundle = path.resolve(tostring(install), bundleDirName)
		local relative = path.format(path.relative(install, bundle))
		if relative == "" or relative == "." or relative:sub(1, 2) == ".." or path.isAbsolute(relative) then
			error(`{projectFile} points outside its package, at {bundle}`)
		end
		table.insert(bundles, bundle)
		table.insert(report.installs, install)
	end

	for _, bundle in bundles do
		if fs.exists(bundle) then
			fs.removeDirectory(bundle, {
				recursive = true,
			})
		end
		copyInto(options.build, bundle)
	end

	--[[
		Links live at the root of `Packages` for the checkout's own
		dependencies, and in each install folder for that package's
		dependencies. This collects each link to rewrite, along with its
		plain form, the `return require(...)` line Wally first writes.
		wally-package-types only adds types to a link in that form.
	]]
	local pendingLinks: { [string]: PendingLink } = {}

	local linkFolders = { packagesRoot }
	for _, entry in fs.listDirectory(index) do
		if entry.type == "dir" then
			table.insert(linkFolders, path.join(index, entry.name))
		end
	end

	for _, folder in linkFolders do
		for _, entry in fs.listDirectory(folder) do
			if entry.type ~= "file" or not entry.name:match("%.lua$") then
				continue
			end
			local link = path.join(folder, entry.name)
			local requirePath = fs.readFileToString(link):match("require%((script[^%)]*)%)")
			if not requirePath then
				continue
			end
			for _, folderName in installFolderNames do
				if requirePath:find(`["{folderName}"]["{packageName}"]`, 1, true) then
					pendingLinks[tostring(link)] = {
						link = link,
						source = `return require({requirePath})\n`,
						isCreated = false,
					}
					break
				end
			end
		end
	end

	for alias, dependency in dependencies do
		local _, dependencyName = parseWallyName(dependency)
		local dependencyFolderName = findInstallFolderNames(index, dependency)[1]
		for _, folderName in installFolderNames do
			local link = path.join(index, folderName, `{alias}.lua`)
			if fs.exists(link) then
				continue
			end
			if dependencyFolderName then
				pendingLinks[tostring(link)] = {
					link = link,
					source = `return require(script.Parent.Parent["{dependencyFolderName}"]["{dependencyName}"])\n`,
					isCreated = true,
				}
			else
				table.insert(
					report.warnings,
					`the build requires {dependency} as {alias}, but {target} doesn't install it, so {folderName} has no link to it`
				)
			end
		end
	end

	--[[
		wally-package-types reads the types from a Rojo sourcemap, which has to
		cover each link and the package it points at. Running it over a scratch
		copy of just those files leaves the checkout's other links alone.
	]]
	if next(pendingLinks) then
		local scratch = path.join(system.tmpdir(), `overlay-wally-package-{os.time()}-{math.random(1e6)}`)
		local scratchPackages = path.join(scratch, "Packages")

		local function getScratchPath(link: path.Path): path.Path
			return path.join(scratchPackages, tostring(link):sub(#tostring(packagesRoot) + 2))
		end

		for _, pending in pendingLinks do
			local scratchLink = getScratchPath(pending.link)
			fs.createDirectory(path.dirname(scratchLink), {
				makeParents = true,
			})
			fs.writeStringToFile(scratchLink, pending.source)

			local folderName, linkedName = pending.source:match('%["([^"]+)"%]%["([^"]+)"%]')
			assert(folderName and linkedName, `could not read the require in {pending.link}`)
			local scratchInstall = path.join(scratchPackages, "_Index", folderName, linkedName)
			if not fs.exists(scratchInstall) then
				copyInto(path.join(index, folderName, linkedName), scratchInstall)
			end
		end

		local projectFile = path.join(scratch, "default.project.json")
		local sourcemap = path.join(scratch, "sourcemap.json")
		fs.writeStringToFile(
			projectFile,
			json.serialize({
				name = "Packages",
				tree = {
					["$path"] = "Packages",
				},
			})
		)
		runTool({ "rojo", "sourcemap", tostring(projectFile), "--absolute", "-o", tostring(sourcemap) })
		runTool({ "wally-package-types", "--sourcemap", tostring(sourcemap), tostring(scratchPackages) })

		for _, pending in pendingLinks do
			local typesBefore = readExportedTypes(pending.link)
			fs.copy(getScratchPath(pending.link), pending.link)
			local typesAfter = readExportedTypes(pending.link)
			table.insert(report.links, {
				link = pending.link,
				isCreated = pending.isCreated,
				addedTypes = listMissing(typesAfter, typesBefore),
				removedTypes = listMissing(typesBefore, typesAfter),
			})
		end

		fs.removeDirectory(scratch, {
			recursive = true,
		})
	end

	table.sort(report.links, function(a, b)
		return tostring(a.link) < tostring(b.link)
	end)

	for _, install in report.installs do
		print(`overlaid {options.package} at {install}`)
	end
	for _, change in report.links do
		local verb = if change.isCreated then "added link" else "rewrote link"
		local details = {}
		if #change.addedTypes > 0 then
			table.insert(details, `gained {table.concat(change.addedTypes, ", ")}`)
		end
		if #change.removedTypes > 0 then
			table.insert(details, `lost {table.concat(change.removedTypes, ", ")}`)
		end
		local suffix = if #details > 0 then ` ({table.concat(details, "; ")})` else ""
		print(`{verb} {change.link}{suffix}`)
	end
	for _, warning in report.warnings do
		print(`warning: {warning}`)
	end
	print(`installing Wally packages in {target} again replaces this overlay with the released packages`)

	return report
end

return overlayWallyPackage
