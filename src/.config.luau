-- The package's own aliases. This file ships with the package (see `files` in
-- `pkg.luau`), so `@root` resolves inside a vendored copy too. Dependencies
-- come through `@lpm`, which a consumer's own config defines.
return {
	luau = {
		aliases = {
			root = "./",
		},
	},
}
