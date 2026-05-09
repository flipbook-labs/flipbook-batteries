return {
	luau = {
		languagemode = "strict",
		aliases = {
			lint = "~/.lute/typedefs/1.0.1/lint",
			std = "~/.lute/typedefs/1.0.1/std",
			lute = "~/.lute/typedefs/1.0.1/lute",
			pkg = "~/.loom/store",
			repo = ".",
			root = "src",
			scripts = ".lute",

			-- Remove this alias once we don't have to write such unwieldy paths
			-- to our batteries
			batteries = "~/.loom/store/Lute@v1.0.1-nightly.20260508/batteries",
		},
	},
}
