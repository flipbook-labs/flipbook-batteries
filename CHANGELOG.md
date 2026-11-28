# Changelog

All notable changes to this project will be documented in this file.

## v0.14.0

Features 1 · Changes 1 · Internal 2

### Features

<picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-dark.svg" /><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.svg" /><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.png" alt="Packages" height="18" align="texttop" /></picture> Add `overlayWallyPackage` to copy a development build over a Wally package wherever another checkout installs it. ([#38](https://github.com/flipbook-labs/flipbook-batteries/pull/38))

### Changes

<picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-logging-dark.svg" /><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-logging-light.svg" /><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-logging-light.png" alt="Logging" height="18" align="texttop" /></picture> Build `createLogger` on Archivist; levels now order debug < info < warn < err, so the default level shows warnings. ([#24](https://github.com/flipbook-labs/flipbook-batteries/pull/24))

<details>
<summary>Details</summary>

Releases no longer attach `flipbook-batteries.zip`, since the package now depends on Archivist. Install it through `pkg.luau` instead.

</details>

### Internal

<picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-contributing-dark.svg" /><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-contributing-light.svg" /><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-contributing-light.png" alt="Contributing" height="18" align="texttop" /></picture> Rewrite the README for package users and move development setup into CONTRIBUTING.md. ([#37](https://github.com/flipbook-labs/flipbook-batteries/pull/37))

<picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-dark.svg" /><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.svg" /><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.png" alt="Packages" height="18" align="texttop" /></picture> Move to Changewrite v0.16.0 and AgentSkills v0.9.0. ([#37](https://github.com/flipbook-labs/flipbook-batteries/pull/37))

## v0.13.1

Changes 1

### Changes

1. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.png" alt="Packages" height="18" align="texttop"></picture> Install flipbook-batteries with `lute pkg install --vendor` (Lute 1.0.1-nightly.20261117 or newer) and define `lpm = "./.lpm"` in your `.config.luau`. ([#31](https://github.com/flipbook-labs/flipbook-batteries/pull/31))


## v0.13.0

Changes 3 · Dependencies 1 · Internal 2

### Changes

1. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-release-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-release-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-release-light.png" alt="Release" height="18" align="texttop"></picture> Release automation reads the public Flipbook Backend App Client ID from an organization variable. ([#27](https://github.com/flipbook-labs/flipbook-batteries/pull/27))
2. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-contributing-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-contributing-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-contributing-light.png" alt="Contributing" height="18" align="texttop"></picture> Route repository review requests to the `flipbook-engine` team. ([#28](https://github.com/flipbook-labs/flipbook-batteries/pull/28))
3. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.png" alt="Packages" height="18" align="texttop"></picture> Ship the manifest as `pkg.luau` and depend on Lute `1.0.1-nightly.20261115`, so consumers need a Lute nightly newer than `1.0.1-nightly.20261031` to install. ([#29](https://github.com/flipbook-labs/flipbook-batteries/pull/29))

<details>
<summary>Dependencies (1)</summary>

1. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-packages-light.png" alt="Packages" height="18" align="texttop"></picture> Add AgentSkills `v0.7.0` as a dev dependency so agents can bootstrap the shared skills library. ([#25](https://github.com/flipbook-labs/flipbook-batteries/pull/25))

</details>

<details>
<summary>Internal (2)</summary>

1. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-release-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-release-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-release-light.png" alt="Release" height="18" align="texttop"></picture> Upgrade the Changewrite release action to `v0.7.0` and adopt its `publish-lock` check. ([#25](https://github.com/flipbook-labs/flipbook-batteries/pull/25))
2. <picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-release-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-release-light.svg"><img src="https://raw.githubusercontent.com/flipbook-labs/flipbook-batteries/main/.changes/assets/kind-release-light.png" alt="Release" height="18" align="texttop"></picture> Release notes mark each entry with a chip naming the part of FlipbookBatteries it changed, and collapse the Dependencies and Internal sections. ([#30](https://github.com/flipbook-labs/flipbook-batteries/pull/30))

</details>


## v0.12.0

### Changes

- Upgrade the pinned Lute nightly `20260612` → `20260701` (Luau `0.727` plus `lute pkg` improvements) across `rokit.toml`, the `loom.config.luau` dependency `rev`, and the `.config.luau` batteries store alias, and bump `luau-lsp` `1.68.0` → `1.68.1` to align with the rest of the fleet.
