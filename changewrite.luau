return {
	categories = { "Features", "Changes", "Fixes", "Dependencies", "Internal" },
	collapsed = { "Dependencies", "Internal" },
	version = {
		current = "0.13.1",
		mirror = {
			{ file = "pkg.luau" },
			{ file = "README.md", pattern = 'rev = "v([%d%.]+)"' },
			{ file = "README.md", pattern = "flipbook%-batteries@v([%d%.]+)" },
		},
	},
	kind = {
		release = { text = "Release", color = "#94606f" },
		build = { text = "Build", color = "#5a7396" },
		ci = { text = "CI", color = "#75659a" },
		contributing = { text = "Contributing", color = "#5f7f55" },
		filesystem = { text = "Filesystem", color = "#9a6700" },
		logging = { text = "Logging", color = "#8250df" },
		packages = { text = "Packages", color = "#7a7444" },
		process = { text = "Processes", color = "#0e7490" },
	},
}
