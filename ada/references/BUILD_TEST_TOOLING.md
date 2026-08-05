# Ada Build, Test, and Tooling

Use this reference for Alire, GPRbuild, AUnit, formatting, static checks, proof commands, and reproducibility.

## Inspect Before Running

First read `alire.toml`, the Alire lockfile (commonly `alire.lock`), every relevant `.gpr`, CI configuration, and wrapper scripts. These pin dependencies/toolchains, source directories, mains, target/runtime, language mode, build profiles, and switches. Do not invent commands before learning the project's project graph.

Record installed versions when diagnosing differences:

```fish
alr --version
gprbuild --version
gnatls --version
```

## Alire

`alire.toml` is the crate manifest; the lockfile captures resolution and should follow the project's committed-file policy. Use `alr with` to modify dependencies, `alr build`, `alr run`, and `alr test` where the manifest defines the expected actions. Alire prepares `GPR_PROJECT_PATH`; use `alr printenv` for external tooling rather than reconstructing dependency paths.

When the user asks to scaffold a new crate, prefer Alire's generated project over a hand-written layout:

```fish
alr init --bin my_project # Use --lib for a library.
cd my_project
alr build
alr run
```

Toolchains include GNAT and GPRbuild and can be selected with `alr toolchain --select`. Inspect the existing selection and lock state before changing it. Do not casually update a lockfile or toolchain during an unrelated fix. Cross compilation also requires the correct GPR `Target` and runtime, not merely a cross-named executable.

## GPRbuild

Use `.gpr` files as the build integration spine:

```fish
gprbuild -P app.gpr
```

Keep source/object/executable directories, mains, dependencies, target, and profile-specific switches in project files rather than personal shell aliases. Set the intended language mode (for GNAT commonly `-gnat2022`) in a reviewed project/profile configuration. Verify compiler support before doing so. GPRbuild2 remains version-dependent/experimental in some manuals; do not require `--gpr=2` unless the pinned project does.

## AUnit

Follow neighboring registration/runner style. AUnit commonly derives tests from `AUnit.Test_Cases.Test_Case`, or fixtures from `AUnit.Test_Fixtures.Test_Fixture` with `AUnit.Test_Caller`; routines are registered, collected with `AUnit.Test_Suites`, and run via an instantiation of `AUnit.Run.Test_Runner` or `Test_Runner_With_Status`. Use exact `AUnit.Assertions.Assert` and `Assert_Exception` APIs from the pinned AUnit release.

Cover observable behavior: type bounds and contracts under enabled checks, expected exception identity, controlled cleanup after normal/exceptional paths, ownership transfer, cursor invalidation-sensitive operations, task shutdown, and foreign adapters. AUnit is not a substitute for ABI integration tests or GNATprove.

## Formatting and Analysis

- `gnatpp`: format according to a committed/project-agreed configuration; inspect options/version before rewriting files.
- Compiler warnings: enable useful warnings by profile and fix/classify them; blanket warnings-as-errors can be nonportable across releases.
- `gnatcheck`: run with a committed LKQL/rule configuration. It enforces selected coding rules; it does not prove correctness. Packaging/licensing may differ across GNAT releases.
- `gnatprove`: run separately on intended SPARK regions; see `CONTRACTS_SPARK.md`. Tool availability and a zero exit status alone do not mean every check was proved.

Representative commands, only after project inspection:

```fish
alr build
alr test
gprbuild -P tests.gpr
gnatcheck -P app.gpr --rules-from=rules.lkql
gnatpp -P app.gpr
gnatprove -P app.gpr --checks-as-errors=on
```

## CI and Reporting

Pin or record GNAT, GPRbuild, Alire, AUnit, GNATcheck, GNATprove, and prover versions. Cache only artifacts safe for the exact lock/toolchain. Run checks/assertions in test profiles and validate materially different production profiles. For claimed portability, build at least the promised target/runtime matrix.

Report exact commands and exits, selected target/runtime/language mode, tests executed, proof mode/results including unproved checks, formatting/static-rule configuration, and skipped unavailable tools. Never present an uninstalled tool as a passed check.

## Authoritative Primary Sources

- [Alire Getting Started](https://alire.ada.dev/docs/getting-started)
- [Alire Manifest Format](https://alire.ada.dev/docs/catalog-format-spec)
- [Alire Toolchains](https://alire.ada.dev/docs/toolchains)
- [GPRbuild User's Guide](https://docs.adacore.com/gprbuild-docs/html/gprbuild_ug/building_with_gprbuild.html)
- [AUnit Cookbook, Overview](https://docs.adacore.com/aunit-docs/html/aunit_cb/aunit_cb/overview.html)
- [GNAT User's Guide](https://docs.adacore.com/gnat_ugn-docs/html/gnat_ugn/gnat_ugn.html)
- [GNATcheck Reference Manual](https://docs.adacore.com/live/wave/lkql/pdf/gnatcheck_rm/gnatcheck_rm.pdf)
- [SPARK User's Guide, How to Run GNATprove](https://docs.adacore.com/spark2014-docs/html/ug/en/source/how_to_run_gnatprove.html)
