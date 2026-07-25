# ObjFW API Design, ARC, and Exceptions

Use this reference when creating or reviewing ObjFW-facing classes and APIs.

## ARC Baseline

Default new application/library code to ARC and ensure the compiler receives both:

```text
-fobjc-arc
-fobjc-arc-exceptions
```

The second flag matters because ObjFW initializers may throw. It lets ARC clean up `self` correctly during exception unwinding. Prefer `objfw-config --arc` when obtaining flags for a custom build system.

When editing an existing target, confirm its mode before changing ownership code. When contributing to ObjFW itself, follow its local MRC/runtime-helper conventions rather than converting isolated files to ARC.

## Initializers and Factories

ObjFW guarantees that `alloc` and `init` do not return `nil`. A failed initializer throws, so the ARC initializer shape is:

```objc
- (instancetype)initWithName: (OFString *)name
{
	self = [super init];

	_name = [name copy];

	return self;
}
```

Do not use either Foundation-style form:

```objc
if ((self = [super init])) { ... }
if (self == nil) return nil;
```

For a public constructible type, prefer:

- one clearly identified designated initializer;
- `init` marked unavailable when it cannot create a valid instance;
- a matching factory that delegates to the initializer;
- `instancetype` so subclass factories preserve their static type.

```objc
OF_ASSUME_NONNULL_BEGIN

@interface MyWidget: OFObject
@property (readonly, copy, nonatomic) OFString *name;

+ (instancetype)widgetWithName: (OFString *)name;
- (instancetype)initWithName: (OFString *)name
    OF_DESIGNATED_INITIALIZER;
- (instancetype)init OF_UNAVAILABLE;
@end

OF_ASSUME_NONNULL_END
```

Under ARC, implement the factory directly:

```objc
+ (instancetype)widgetWithName: (OFString *)name
{
	return [[self alloc] initWithName: name];
}
```

Prefer this factory at call sites:

```objc
MyWidget *widget = [MyWidget widgetWithName: @"Status"];
```

Under ARC, use `[[MyWidget alloc] initWithName: ...]` only when direct initializer use improves clarity or no matching factory exists; ARC balances both forms automatically. Under MRC, factories and `alloc`/`init` carry different caller ownership contracts.

ObjFW's own MRC source wraps factory results in helpers such as `objc_autoreleaseReturnValue`. That is an implementation detail for MRC-compatible ObjFW code, not a pattern for ARC consumers.

## Invariants and Partial Initialization

- Validate required arguments and invariants in the designated initializer.
- Let invalid construction throw a specific documented `OFException` subclass.
- Assign `self = [super init]` before initializing subclass state.
- Under ARC with `-fobjc-arc-exceptions`, do not add a catch solely to release `self`.
- If a superclass initializer can return another instance because it is a class cluster, never assume the originally allocated concrete class survives initialization.
- Delegate convenience initializers to the designated initializer rather than duplicating invariant logic.

## Properties and Ownership

- Prefer `readonly` publicly and keep mutation internal unless callers genuinely need it.
- Use `copy` for externally supplied value-like objects such as strings or collections when later caller mutation must not alter object state.
- Use a retaining/strong relationship only when identity and shared mutation are intentional.
- Use non-retaining delegate relationships only when the target version and surrounding code establish that lifetime contract.
- State nullability using the project's `OF_ASSUME_NONNULL_BEGIN` / `OF_ASSUME_NONNULL_END` and nullable annotations.
- Preserve lightweight generics on collection properties and parameters.
- Avoid exposing writable raw pointers. If unavoidable, document ownership, capacity, and validity duration.

Property attributes in ObjFW headers may reflect support for MRC and older compilers. Match local project conventions instead of performing a mechanical `retain` to `strong` rewrite.

## Exceptions

ObjFW uses exceptions as its ordinary mechanism for exceptional API failure and has no `NSError` equivalent.

- Throw the most specific existing exception class that truthfully describes the failure.
- Document exceptions on public methods when callers can reasonably handle or diagnose them.
- Catch a specific exception near a recovery boundary.
- Use `@finally` for mandatory cleanup when the resource has no safer scoped abstraction.
- Rethrow after adding context unless the boundary has a valid fallback.
- Let missing dictionary keys, end-of-enumeration, and other documented absence remain `nil` or the documented sentinel.

Avoid this:

```objc
@try {
	[self performOperation];
} @catch (OFException *exception) {
	/* ignored */
}
```

A broad catch is appropriate only at a process, request, task, or UI boundary that can report the failure and restore a known-valid state.

## Equality, Hashing, and Copying

For value-like types:

- Implement `isEqual:` and `hash` together; equal objects must have equal hashes.
- Check the expected class/protocol before reading peer state.
- Combine hashes with ObjFW's hash helpers when those are the neighboring convention.
- Adopt `OFCopying` / `OFMutableCopying` only with clear semantics.
- Immutable objects may return themselves from `copy`; mutable copies must be independent where the contract requires it.
- Do not infer that copying a resource creates an independent resource. For example, copying an `OFStream` retains the same stream.

## Public Header Checklist

Before finishing a new API, verify:

- exact ObjFW-native parameter and return types;
- `instancetype` on construction methods;
- designated and unavailable initializer annotations;
- nullability and collection generics;
- property ownership and mutability;
- documented thrown exceptions;
- platform/feature guards;
- matching factory and designated initializer behavior;
- tests for valid construction, invalid inputs, equality/copying where applicable, and thrown exception classes.

## Primary Sources

- [Differences to Foundation](https://git.nil.im/ObjFW/ObjFW/src/branch/main/documentation/differences-to-foundation.gmi)
- [OFObject API](https://objfw.nil.im/docs/interfaceOFObject.html)
- [OFObject header](https://github.com/ObjFW/ObjFW/blob/main/src/OFObject.h)
- [ObjFW exception classes](https://objfw.nil.im/docs/annotated.html)
