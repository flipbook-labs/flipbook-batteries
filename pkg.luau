return {
	package = {
		name = "FlipbookBatteries",
		version = "0.13.1",
		files = {
			"/init.luau",
			"/src/**",
			-- Dotfiles need to be explicitly included
			"/src/.config.luau",
			"/README.md",
			"/LICENSE",
		},
		dependencies = {
			archivist = {
				rev = "v0.3.1",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/archivist",
			},
			batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
		},
		dev_dependencies = {
			["agent-skills"] = {
				rev = "v0.9.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
		},
	},
}
