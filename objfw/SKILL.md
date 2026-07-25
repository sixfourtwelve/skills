---
name: objfw
description: |
  Opinionated guide for writing, debugging, reviewing, and testing Objective-C when the target uses ObjFW. Use for ObjFW classes and APIs, ObjFW-style types, ARC, exceptions, strings, collections, streams, sockets, run loops, portability, objfw-compile, or ObjFWTest in an ObjFW project.
compatibility: Verify selectors and availability against the ObjFW version used by the target project.
---

# ObjFW

Write Objective-C that is native to ObjFW rather than Foundation with an `OF` prefix. Use ARC by default for application and library code. Established project conventions take precedence, especially when contributing to ObjFW itself, whose source also supports non-ARC and older toolchains.

## Source Rule

Before guessing an API or ownership rule, check in this order:

1. The nearest `AGENTS.md` / `AGENT.md`, build files, and project conventions.
2. The ObjFW version pinned or installed by the target project: its headers, source, and tests.
3. Current upstream ObjFW headers and tests.
4. The released API documentation, noting that it may differ from `main`.

ObjFW is intentionally incompatible with Foundation. Never derive an API by replacing `NS` with `OF`.

Useful upstream sources:

- [ObjFW repository](https://github.com/ObjFW/ObjFW)
- [Differences to Foundation](https://git.nil.im/ObjFW/ObjFW/src/branch/main/documentation/differences-to-foundation.gmi)
- [Supported platforms](https://git.nil.im/ObjFW/ObjFW/src/branch/main/documentation/platforms.gmi)
- [Released API documentation](https://objfw.nil.im/docs/annotated.html)

## Branch Chooser

Read only the references relevant to the task:

- New classes, initializers, factories, properties, ownership, copying, equality, or exceptions: [`references/API_DESIGN.md`](references/API_DESIGN.md).
- Strings, data, arrays, dictionaries, sets, ranges, encodings, or serialization: [`references/CORE_TYPES.md`](references/CORE_TYPES.md).
- Files, streams, sockets, HTTP, asynchronous I/O, delegates, handlers, or run loops: [`references/IO_ASYNC.md`](references/IO_ASYNC.md).
- Application entry points, compiler flags, build integration, tests, feature macros, or cross-platform work: [`references/BUILD_TEST_PORTABILITY.md`](references/BUILD_TEST_PORTABILITY.md).

Read multiple references when a task crosses those boundaries.

## Core Defaults

- Use ARC unless the existing target explicitly uses manual reference counting or the task modifies ObjFW's own non-ARC source.
- With ARC, compile with both `-fobjc-arc` and `-fobjc-arc-exceptions`. `objfw-config --arc` emits both flags.
- Under ARC, do not emit `retain`, `release`, `autorelease`, `objc_retain`, `objc_release`, `objc_autorelease`, or `[super dealloc]`.
- Prefer a class factory at call sites when one exists. For a new public constructible type, normally pair one designated `initWith...` initializer with a matching factory.
- In ARC code, implement a factory directly as `return [[self alloc] initWithThing: thing];`. Do not copy ObjFW's internal `objc_autoreleaseReturnValue(...)` MRC implementation into ARC application code.
- ObjFW `alloc` and `init` do not return `nil`; initialization failure throws. Do not add Foundation-style nil checks around initialization.
- Use `instancetype` for factories and initializers.
- Use ObjFW's exact types and selectors: commonly `bool`, `size_t`, fixed-width integers, `OFRange`, `OFTimeInterval`, `OFString`, `OFArray`, and other `OF*` APIs. Do not substitute `BOOL`, `NSUInteger`, `NSRange`, `NSError`, or Foundation collections.
- Use exceptions for exceptional failures and `nil` or documented sentinels for ordinary absence. Catch only when the current boundary can recover, translate, add useful context, or perform required cleanup.
- Prefer immutable values and collections by default. Introduce mutable variants only where mutation is part of the operation.
- Treat availability, ownership, nullability, pointer lifetime, and callback continuation semantics in the target version's headers as part of correctness.

## Workflow

1. Establish the target ObjFW version, memory-management mode, supported platforms, and local formatting/build conventions.
2. Read the matching reference files and the exact declarations for every unfamiliar selector.
3. Inspect neighboring implementation and test code for the same kind of operation.
4. Implement with ObjFW-native types, factories, exceptions, and platform abstractions.
5. Add or update ObjFWTest coverage and run the narrowest relevant build/test command, then the project's broader checks.
6. Report validation performed and any unresolved version, runtime, or platform uncertainty.

## Boundary Rules

- Keep Foundation, Core Foundation, POSIX, Win32, and other platform APIs behind explicit adapter boundaries. Do not leak their types into portable ObjFW-facing APIs without a deliberate interoperability requirement.
- At C boundaries, preserve byte counts, encoding, byte order, ownership, null termination, and pointer lifetime explicitly.
- Close files, streams, sockets, subprocess directions, and other finite resources deterministically when their API requires it; ARC manages object lifetime, not protocol/resource completion.
- Guard optional facilities with ObjFW's configured feature macros and provide a fallback or an explicit unsupported path.
- Respect the target's compiler/runtime range. Do not introduce a language or runtime feature merely because it works with the local Apple Clang toolchain.

## Do Nots

- Do not import Foundation into portable ObjFW code or mechanically translate Foundation examples.
- Do not add `NSError **` APIs to model ordinary ObjFW failures.
- Do not assume every target has files, sockets, threads, blocks, shared libraries, or full method forwarding.
- Do not guess selector spelling, exception classes, delegate methods, or async handler return meanings.
- Do not use `OFString.length` as a UTF-8 byte count.
- Do not assume a stream read fills the requested buffer unless using an exact-length API whose contract says so.
- Do not keep borrowed C-string, character-buffer, or collection pointers beyond their documented lifetime.
- Do not swallow `OFException` broadly and continue with invalid state.
