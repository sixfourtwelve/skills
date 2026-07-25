# ObjFW Core Types, Collections, and Strings

Use this reference for ObjFW values, text, binary data, collections, and serialization.

## ObjFW-native Types

Copy signatures from the target ObjFW headers. Typical ObjFW choices include:

- `bool` with `true` / `false`, not Foundation's `BOOL`, `YES`, or `NO`;
- `size_t` for collection counts, indexes, and buffer lengths;
- fixed-width integers such as `uint16_t` and `uint32_t` for wire formats;
- `OFRange` and `OFMakeRange(...)`, not `NSRange`;
- `OFTimeInterval` for time intervals;
- `OFUnichar`, `OFChar16`, and `OFChar32` for Unicode units exposed by ObjFW;
- `OFNotFound` when an API documents it as the missing-index sentinel.

Do not assume Objective-C number, array, or dictionary literals map to ObjFW. Use documented factories unless the target build explicitly proves support for the literal form. ObjFW string literals work when the required constant-string compiler configuration is present.

## Strings and Encodings

`OFString.length` counts Unicode code points. `OFString.UTF8StringLength` counts encoded UTF-8 bytes. Those values differ whenever a character uses more than one UTF-8 byte.

Use the value matching the operation:

- character-oriented slicing/searching: code-point-oriented ObjFW APIs;
- C writes, protocol frames, allocation, and byte offsets: encoded byte count;
- external text: an explicit `OFStringEncoding` unless the API's UTF-8 default is deliberately desired.

The pointers returned by `UTF8String`, `characters`, UTF-16 accessors, UTF-32 accessors, and encoding conversion methods have documented limited lifetimes, commonly until the current autorelease pool is popped. Copy the bytes if a C API stores the pointer or work outlives that scope.

Do not assume every character buffer is null-terminated. For example, the `characters` view is documented as not null-terminated, while UTF-16 and UTF-32 views may be documented differently. Check the exact accessor.

At C boundaries, pass both pointer and length whenever the C API supports it. This avoids accidental truncation on embedded null bytes and avoids rescanning.

## Arrays, Dictionaries, and Sets

- Prefer immutable `OFArray`, `OFDictionary`, and `OFSet` for stored/public values.
- Use `OFMutableArray`, `OFMutableDictionary`, and `OFMutableSet` only while mutation is needed.
- Use lightweight generics in declarations where supported by the target.
- End ObjFW varargs collection factories with `nil`.
- Use `size_t` indexes and counts.
- Treat a missing dictionary key as ordinary `nil`.
- Treat enumeration mutation as an error; do not mutate a collection while fast-enumerating it unless the API explicitly supports the operation.
- When building a mutable value and then publishing it as immutable, use the target version's documented copy or `makeImmutable` pattern and verify the resulting ownership/identity semantics.

Example:

```objc
OFArray OF_GENERIC(OFString *) *names =
    [OFArray arrayWithObjects: @"Ada", @"Grace", nil];

OFString *value = [dictionary objectForKey: @"name"];
if (value == nil)
	value = @"Unknown";
```

Some collection accessors return non-retained objects or internal buffers for performance. Do not extend those pointers/references beyond the collection's valid lifetime without retaining/copying as appropriate to the target's memory mode.

## Data and Binary Formats

- Use `OFData` / `OFMutableData` for owned binary values instead of treating arbitrary bytes as strings.
- Keep item count and item size distinct; check both when an API models structured items.
- For no-copy initializers, verify who frees the memory and whether the buffer may be mutated.
- Check multiplication and addition for overflow before allocating or computing byte spans from untrusted counts.
- Use explicit endian conversions or stream methods for persistent and network binary formats.
- Prefer `OFSecureData` for secrets when its locking/swappability behavior fits the threat model and target platform.

## Serialization

ObjFW collections and values expose format-specific APIs such as JSON and MessagePack where supported.

- Parse untrusted input with the documented parser and catch only the specific format/encoding exceptions at a useful boundary.
- Keep format validation separate from domain validation: syntactically valid JSON can still violate application invariants.
- Do not rely on dictionary ordering unless the specific API contract guarantees it.
- Choose JSON options deliberately rather than post-processing serialized text.
- Keep binary and text representations distinct; do not round-trip arbitrary bytes through `OFString`.

## Review Checklist

- Are counts bytes, items, code points, or UTF-8 bytes?
- Is every varargs collection terminated with `nil`?
- Are generics, nullability, and mutability truthful?
- Can a borrowed pointer outlive its object or autorelease pool?
- Is a missing value ordinary absence or a documented exception?
- Is encoding and byte order explicit at external boundaries?
- Can untrusted sizes overflow before allocation or slicing?

## Primary Sources

- [OFString API](https://objfw.nil.im/docs/interfaceOFString.html)
- [OFArray API](https://objfw.nil.im/docs/interfaceOFArray.html)
- [OFDictionary API](https://objfw.nil.im/docs/interfaceOFDictionary.html)
- [OFData API](https://objfw.nil.im/docs/interfaceOFData.html)
- [ObjFW annotated class list](https://objfw.nil.im/docs/annotated.html)
