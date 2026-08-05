# Ada Interoperability and Portability

Use this reference for C interfaces, representation, allocation across ABIs, implementation-specific code, runtime profiles, and target claims.

## C Interfaces

Model the C declaration, not a convenient Ada approximation. Prefer `Interfaces.C` scalar types, `Interfaces.C.char_array`, `Interfaces.C.Strings.chars_ptr`, and `Interfaces.C.Pointers`. Use `Import`, `Export`, `Convention => C`, and `External_Name` explicitly:

```ada
with Interfaces.C;
function C_Close (FD : Interfaces.C.int) return Interfaces.C.int
  with Import, Convention => C, External_Name => "close";
```

Use `Convention => C_Pass_By_Copy` only for eligible C records actually passed by value. Variadic conventions (`C_Variadic_n`) and compiler support require exact target verification. Prevent Ada exceptions from crossing a C ABI boundary; catch/translate at exported entry points and convert C error/status conventions deliberately.

## Strings, Pointers, and Allocators

Define whether text is NUL-terminated, its encoding, mutability, length units, embedded-NUL policy, and pointer lifetime. `Interfaces.C.Strings.New_String`/`New_Char_Array` allocations must be released by that package's matching `Free`. Memory from `malloc` must be released with the matching C allocator; Ada pool allocations with their owning Ada mechanism; library-owned pointers with that library's release function. Never cross allocator families.

For callbacks, keep both code pointer and context/object alive for the full C retention period, establish calling convention, and specify thread/reentrancy behavior. Confine address conversion and `'Unchecked_Access` to the adapter.

## Representation and ABI Tests

`Convention => C` does not guarantee a guessed layout for every struct, union, enum, or bitfield. Use representation aspects/clauses (`Size`, `Alignment`, record component clauses, `Bit_Order`, `Scalar_Storage_Order` where applicable) only from ABI facts. Prefer generated/vendor headers and typed bindings over hand guesses.

Add paired C/Ada tests that compare `sizeof`, alignment, field offsets, enum values, calling/return convention, packed/bitfield behavior, NUL/length handling, allocator ownership, and callback lifetime on each target. Treat compiler warnings about questionable representation as correctness signals.

## Portable Numeric and System Assumptions

Do not assume:

- `Integer` width or overflow mode;
- byte size (`System.Storage_Unit`), endianness, alignment, or floating representation;
- enumeration representation codes;
- filesystem naming/case/encoding;
- default task scheduling or character encoding;
- optional annex/library/runtime availability.

Use domain ranges for portable logic, `Interfaces.C` for C ABI types, and supported `Interfaces.Integer_n`/`Unsigned_n` types for exact-width external formats. Serialize explicitly rather than overlaying records onto bytes.

## Isolation

Keep `System.*`, `GNAT.*`, unchecked conversion, address clauses, target pragmas, OS bindings, assembly, and compiler intrinsics in small adapter packages. Expose portable domain types and operations above them. Name target-specific bodies/configuration clearly and test the portable contract against each implementation.

Runtime profile is part of the platform. Full, light/embedded, zero-footprint, Ravenscar, and Jorvik runtimes differ in tasking, exceptions, finalization, I/O, allocation, and annex support. Safety restrictions may be mandatory for a particular system, but must not leak into universal application advice.

## Portability Validation

For every portability claim, record compiler/version, target triple, runtime, build profile, and tested capabilities. Compile and run on materially different targets where promised; a cross-compile alone does not test ABI/runtime behavior. Check the implementation-defined characteristics documented by the selected compiler and provide explicit unsupported behavior when no fallback exists.

## Review Checklist

- Do Ada and C declarations exactly agree in type, convention, layout, and name?
- Who allocates/releases every pointer, with which allocator?
- Can exceptions or callbacks cross the boundary unsafely?
- Are record layout facts verified by paired ABI tests?
- Are implementation-specific packages isolated?
- Does the selected runtime provide required facilities?
- Is every claimed target actually built/tested or clearly marked unverified?

## Authoritative Primary Sources

- [Ada 2022 RM B.3, Interfacing with C and C++](http://www.ada-auth.org/standards/22rm/html/RM-B-3.html)
- [Ada 2022 RM B.3.1, The Package Interfaces.C.Strings](http://www.ada-auth.org/standards/22rm/html/RM-B-3-1.html)
- [Ada 2022 RM B.2, The Package Interfaces](http://www.ada-auth.org/standards/22rm/html/RM-B-2.html)
- [Ada 2022 RM 13.1, Representation Items](http://www.ada-auth.org/standards/22rm/html/RM-13-1.html)
- [Ada 2022 RM 13.3, Operational and Representation Aspects](http://www.ada-auth.org/standards/22rm/html/RM-13-3.html)
- [Ada 2022 RM M.2, Implementation-Defined Characteristics](http://www.ada-auth.org/standards/22rm/html/RM-M-2.html)
- [GNAT Reference Manual](https://docs.adacore.com/gnat_rm-docs/html/gnat_rm/gnat_rm.html)
