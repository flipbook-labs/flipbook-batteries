---
bump: patch
category: Internal
kind: packages
---

`lute run install` writes an alias in `.config.luau` for every dependency, named after its lowercase kebab-case key in `pkg.luau`. The package now ships its own `root` alias in `src/.config.luau` and lists its files in `pkg.luau`, so a vendored copy resolves `@root` without the repo's store aliases.
