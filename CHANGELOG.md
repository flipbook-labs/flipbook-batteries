# Changelog

All notable changes to this project will be documented in this file.


## v0.12.1

### Dependencies

- Add AgentSkills `v0.4.0` as a dev dependency so agents can bootstrap the shared skills library.

### Internal

- Upgrade the Changewrite release action to `v0.7.0` and adopt its `publish-lock` check.


## v0.12.0

### Changes

- Upgrade the pinned Lute nightly `20260612` → `20260701` (Luau `0.727` plus `lute pkg` improvements) across `rokit.toml`, the `loom.config.luau` dependency `rev`, and the `.config.luau` batteries store alias, and bump `luau-lsp` `1.68.0` → `1.68.1` to align with the rest of the fleet.
