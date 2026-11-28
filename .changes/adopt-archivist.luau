return {
	bump = "minor",
	category = "Changes",
	kind = "logging",
	summary = "Build `createLogger` on Archivist; levels now order debug < info < warn < err, so the default level shows warnings.",
	body = "Releases no longer attach `flipbook-batteries.zip`, since the package now depends on Archivist. Install it through `pkg.luau` instead.",
}
