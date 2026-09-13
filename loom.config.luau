return {
	package = {
		name = "FlipbookBatteries",
		version = "0.12.0",
		dependencies = {
			Archivist = {
				rev = "v0.1.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/archivist",
			},
			Lute = {
				rev = "v1.0.1-nightly.20260701",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
			},
		},
		dev_dependencies = {
			AgentSkills = {
				rev = "v0.4.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
		},
	},
}
