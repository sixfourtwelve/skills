# ObjFW Build, Test, and Portability

Use this reference for application setup, compiler/linker integration, ObjFWTest, and cross-platform work.

## Application Shape

For a normal ObjFW application, prefer ObjFW's application delegate model:

```objc
#import <ObjFW/ObjFW.h>

@interface Application: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Application)

@implementation Application
- (void)applicationDidFinishLaunching: (OFNotification *)notification
{
	[OFStdOut writeLine: @"Hello!"];
	[OFApplication terminate];
}
@end
```

Confirm the exact delegate signature and termination API against the target version. `objfw-new --app Name` is the preferred source for a version-correct scaffold.

Do not assume Cocoa's application lifecycle or use Objective-C message dispatch from a signal handler; follow `OFApplication`'s signal-safety warnings.

## Consumer Build Tools

Prefer ObjFW-provided tools over hand-assembled flags:

- `objfw-new` scaffolds applications, classes, and tests in the current working directory; verify its installed options for other versions.
- `objfw-compile` builds small consumers without a separate build system.
- `objfw-config` provides compiler and linker flags to a custom build system.
- `objfw-config --arc` emits the ARC flags, including exception-safe ARC unwinding.

Example for a small ARC program:

```fish
objfw-compile --arc -o MyApp MyApp.m
```

Verify available options with the installed tool because command-line flags can differ by ObjFW version.

For a custom build, use command substitution in fish rather than hard-coding include/library paths. Inspect `objfw-config --help` and request the relevant cflags/libs/ARC output supported by that version.

## Apple Framework Integration

When integrating ObjFW frameworks manually in Xcode, preserve ObjFW's documented constant-object flags:

```text
-fconstant-string-class=OFConstantString
-fno-constant-cfstrings
-fno-constant-nsnumber-literals
-fno-constant-nsarray-literals
-fno-constant-nsdictionary-literals
```

For ARC targets, also include:

```text
-fobjc-arc
-fobjc-arc-exceptions
```

Prefer flags emitted by the installed ObjFW tools or supplied by its current documentation. Do not assume that linking the framework alone configures constant Objective-C objects correctly.

## Building ObjFW Itself

For a release tarball:

```fish
./configure
make
make check
```

For a repository checkout, run `./autogen.sh` before `./configure` when generated build files are absent or stale.

Follow repository-specific configure options and platform instructions. Do not install system-wide unless the user explicitly asks.

## ObjFWTest

Use ObjFWTest and nearby test structure:

```objc
#import <ObjFW/ObjFW.h>
#import <ObjFWTest/ObjFWTest.h>

#import "MyWidget.h"

@interface MyWidgetTests: OTTestCase
@end

@implementation MyWidgetTests
- (void)testFactoryCopiesName
{
	MyWidget *widget = [MyWidget widgetWithName: @"Status"];

	OTAssertEqualObjects(widget.name, @"Status");
}

- (void)testRejectsInvalidName
{
	OTAssertThrowsSpecific([MyWidget widgetWithName: @""],
	    OFInvalidArgumentException);
}
@end
```

Use the actual import path, test registration, and assertion macros from the target project's neighboring tests. Common macros include equality, object equality, nil/non-nil, boolean, and specific-exception assertions, but names can vary by version.

Test behavior rather than implementation details. For a new type, cover:

- matching factory and initializer results;
- invalid construction and the exact exception class;
- equality/hash/copy contracts when implemented;
- mutable input copied into immutable state;
- nullability and ordinary absence;
- relevant platform/feature branches;
- asynchronous stop/continue and exception paths.

Run the narrowest target first, then the repository's full `make check` or documented equivalent.

## Portability Model

ObjFW targets systems ranging from current desktop/server platforms to older systems, consoles, and bare metal. “Supported by ObjFW” does not mean every subsystem is present on every target.

Establish the intended target set before choosing APIs. Depending on configuration, targets may lack:

- files;
- sockets or specific socket families;
- threads;
- blocks;
- subprocesses;
- shared libraries/modules;
- some filesystem metadata operations;
- full message forwarding.

Use configured feature macros from ObjFW's headers, such as `OF_HAVE_FILES`, `OF_HAVE_SOCKETS`, `OF_HAVE_THREADS`, and `OF_HAVE_BLOCKS`, only after confirming the target version uses them for the relevant declaration.

When an optional capability is absent:

1. Compile the feature-specific declaration and implementation out together.
2. Provide a portable fallback when one is meaningful.
3. Otherwise expose an explicit unsupported build/runtime path.
4. Add CI/build coverage for disabled-feature configurations when the project promises that portability.

## Platform Boundaries

- Prefer ObjFW abstractions over raw POSIX or Win32 APIs.
- Isolate unavoidable native code in platform-specific files or small adapters.
- Keep native handles and structs out of portable public APIs where possible.
- Never assume path separators, filesystem case behavior, newline encoding, socket families, native byte order, or Apple runtime behavior.
- Do not assume forwarding works on an unlisted CPU/ABI combination.
- When using a modern Objective-C feature, verify the project's minimum compiler and runtime rather than the local M4 Mac alone.

## Validation Report

At completion, report:

- ObjFW version/source used for API verification;
- ARC/MRC mode and how flags were obtained;
- commands run and whether they passed;
- target platforms or feature configurations covered;
- any branches not compiled or runtime behavior not exercised.

## Primary Sources

- [ObjFW README](https://github.com/ObjFW/ObjFW/blob/main/README.gmi)
- [Compiling ObjFW](https://github.com/ObjFW/ObjFW/blob/main/documentation/compiling.gmi)
- [Supported platforms](https://git.nil.im/ObjFW/ObjFW/src/branch/main/documentation/platforms.gmi)
- [ObjFW tests](https://github.com/ObjFW/ObjFW/tree/main/tests)
- [ObjFWTest API](https://objfw.nil.im/docs/)
