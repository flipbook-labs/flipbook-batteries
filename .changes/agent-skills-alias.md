---
bump: patch
category: Internal
kind: contributing
---

`lute run install` writes an alias in `.config.luau` for every dependency, named after its lowercase kebab-case key in `pkg.luau`. Agents find the shared skills library through the `agent-skills` alias.
