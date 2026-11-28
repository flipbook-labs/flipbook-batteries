# Contributing

## Set up

Install the toolchain from `rokit.toml` with Rokit, then install the dependencies:

```sh
rokit install
lute setup
lute run install
```

`lute run install` vendors each dependency into a gitignored `.lpm/` folder. The shared agent skills land there too.

## Check your changes

```sh
lute test src/
stylua --check src
selene src
lute run build
lute run analyze
lute run smoketest
```

`lute run build` writes the package to `build/`. `lute run smoketest` bundles the package and checks that every require resolves in the bundle.

## Add a changelog entry

Each user-facing change adds one file to `.changes/`. The [`.changes/README.md`](.changes/README.md) lists the fields. Changewrite assembles these entries into `CHANGELOG.md` at release time.
