return {
	luau = {
		languagemode = "strict",
		aliases = {
			lint = "~/.lute/typedefs/1.0.1/lint",
			std = "~/.lute/typedefs/1.0.1/std",
			lute = "~/.lute/typedefs/1.0.1/lute",
			repo = ".",
			root = "./src",
			scripts = ".lute",

			-- `lute run install` copies these from the Loom store.
			-- https://github.com/flipbook-labs/flipbook/issues/689 tracks removing this vendoring.
			batteries = "./LuauPackages/Batteries",
		},
	},
}
