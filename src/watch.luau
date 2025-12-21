local fs = require("@lute/fs")
local process = require("@lute/process")
local task = require("@lute/task")

local findWhere = require("@root/findWhere")
local richterm = require("@pkg/batteries/richterm")

type Options = {
	roots: { string },
	excludedFilePatterns: { string }?,
	onChanged: ((changedFiles: { string }) -> ())?,
}

local function watch(options: Options)
	local foldersToWatch = findWhere(process.cwd(), function(path): boolean?
		if fs.type(path) == "dir" then
			if options.excludedFilePatterns then
				for _, excludedFilePattern in options.excludedFilePatterns do
					if path:match(excludedFilePattern) then
						return nil
					end
				end
			end

			for _, root in options.roots do
				if path:match(root) then
					return true
				end
			end
		end

		return false
	end)

	print("watching folders:")
	for _, watchedFolder in foldersToWatch do
		print(richterm.dim(`> {watchedFolder}`))

		task.spawn(function()
			fs.watch(watchedFolder, function(filename)
				if options.onChanged then
					options.onChanged({ filename })
				end
			end)
		end)
	end
	print("listening for file changes...")

	task.wait(math.huge)
end

return watch
