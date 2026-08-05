---
name: ada
description: |
  Opinionated guide for designing, writing, reviewing, building, testing, and incrementally verifying modern Ada applications and libraries. Use for Ada 2022, GNAT, GPRbuild, Alire, AUnit, GNATcheck, GNATprove, SPARK, tasking, containers, controlled types, or C interoperability.
compatibility: Verify Ada 2022 feature and runtime support against the compiler, target runtime, and pinned project files.
---

# Ada

Write strongly modeled, package-oriented Ada. Target Ada 2022 when the project and toolchain support it; do not introduce new syntax without checking the selected compiler and runtime. Default to GNAT, GPRbuild, and Alire for commands, while keeping language-facing design compiler-neutral.

## Source Hierarchy

Before guessing semantics or a tool option, check:

1. The nearest `AGENT.md`/`AGENTS.md`, `alire.toml`, lockfile, `.gpr` files, CI, and neighboring code/tests.
2. The Ada 2022 RM/AARM and official [Ada 2022 Overview](http://www.ada-auth.org/standards/overview22.html).
3. Manuals matching the installed GNAT, GPRbuild, SPARK, AUnit, and analysis tools.
4. Official Alire documentation and the resolved manifest/toolchain.

The RM defines the language; compiler manuals define implementation support. Record uncertainty rather than extrapolating from another release.

## Branch Chooser

- Types, packages, generics, tagged dispatch, exceptions, and API contracts: [`references/LANGUAGE_API_DESIGN.md`](references/LANGUAGE_API_DESIGN.md).
- Resources, controlled types, access types, allocation, and deallocation: [`references/OWNERSHIP_FINALIZATION.md`](references/OWNERSHIP_FINALIZATION.md).
- Strings and containers: [`references/STRINGS_CONTAINERS.md`](references/STRINGS_CONTAINERS.md).
- Contracts, assertion policy, SPARK, and GNATprove: [`references/CONTRACTS_SPARK.md`](references/CONTRACTS_SPARK.md).
- Tasks, protected objects, rendezvous, and Ada 2022 parallelism: [`references/TASKING_PARALLELISM.md`](references/TASKING_PARALLELISM.md).
- Alire, GPRbuild, AUnit, formatting, and analysis: [`references/BUILD_TEST_TOOLING.md`](references/BUILD_TEST_TOOLING.md).
- C ABI, representation, implementation dependencies, runtimes, and portability: [`references/INTEROP_PORTABILITY.md`](references/INTEROP_PORTABILITY.md).

Read every branch crossed by the task.

## Core Defaults

- Use a new type for a genuine semantic domain; use a subtype for a constraint/view within one type.
- Hide representations with private types and package bodies. Use `limited private` when copying is not meaningful.
- Prefer ordinary records and composition. Use tagged types only for genuine extension or dynamic dispatch, and generics for compile-time reusable algorithms/components.
- Put stable public contracts in specs. Keep assertion expressions deterministic and side-effect-free; do not treat possibly disabled assertions as hostile-input validation.
- Let specific exceptions represent exceptional failures. Catch only where recovery, translation, context, or boundary reporting is possible; bare `raise;` preserves the current exception.
- Prefer values and scoped objects. Confine access types, unchecked operations, representation details, `System`, and `GNAT.*` behind narrow packages.
- Use controlled types only when a resource lifecycle requires them. Choose copy semantics deliberately; they are not a universal record base class.
- Adopt SPARK incrementally around high-value logic. “Valid SPARK” is not the same as proved code.
- Keep safety-critical restrictions and Ravenscar/Jorvik profiles explicit, project-specific choices—not defaults for ordinary applications.

## Workflow

1. Inspect pinned manifests, lockfiles, `.gpr` files, compiler/runtime versions, target, language mode, assertion policy, and local style.
2. Read the relevant references and exact declarations; identify ownership, exception, concurrency, portability, and proof boundaries.
3. Model invariants in types, private packages, and contracts before adding representation or access-level machinery.
4. Implement the smallest portable design; isolate compiler/OS/foreign code.
5. Add AUnit or project-native tests. Run the narrow build/test first, then formatting/static checks and any selected GNATprove proof.
6. Test enabled-check and production profiles where they differ. Report versions, commands, targets, proof level, and untested branches.

## Boundary Rules

- At allocation boundaries, state owner, aliases, storage pool, transfer operation, and matching deallocator.
- At C boundaries, state ABI types/layout, allocator family, NUL/length rules, callback lifetime, and exception policy.
- At concurrent boundaries, state task ownership, blocking behavior, synchronization, termination, and ordering assumptions.
- At proof boundaries, specify what is proved, what is assumed, and which code remains outside `SPARK_Mode`.
- At portability boundaries, isolate implementation-defined widths, endianness, alignment, runtime facilities, and target-specific pragmas.

## Do Nots

- Do not confuse subtypes with distinct types, or private visibility with secrecy.
- Do not make every record tagged or controlled.
- Do not use `Ada.Unchecked_Deallocation`, `'Unchecked_Access`, unchecked conversion, or check suppression as convenience features.
- Do not swallow `when others`, assume task exceptions propagate to the creator, or block inside protected actions.
- Do not structurally mutate a container through an iteration callback or retain invalidated cursors/references.
- Do not enable blanket `Suppress`/`-gnatp`, blanket safety restrictions, or blanket SPARK requirements.
- Do not assume Ada 2022 syntax, parallel execution, annex packages, or a full runtime exists merely because the compiler accepts Ada.
