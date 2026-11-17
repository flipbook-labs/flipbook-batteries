return {
	luau = {
		languagemode = "strict",
		aliases = {
			lint = "~/.lute/typedefs/1.0.1/lint",
			std = "~/.lute/typedefs/1.0.1/std",
			lute = "~/.lute/typedefs/1.0.1/lute",
			pkg = "~/.loom/store",
			repo = ".",
			root = "./src",
			scripts = ".lute",

			-- `lute run install` writes this path from `pkg.lock.luau`.
			-- https://github.com/flipbook-labs/infra/issues/41 tracks removing this injection.
			batteries = "~/.loom/store/lute--github-6e87d56ef86974ca90629c5ef7ab70e40b102f8210ee178dc95916f940d6854e@6dba55fa3cf083d10fb5dcb54a22cb87d3d11735a512215b835f33d3c571033d/batteries",
		},
	},
}
