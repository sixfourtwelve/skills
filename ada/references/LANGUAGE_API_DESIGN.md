# Ada Language and API Design

Use this reference for type modeling, package APIs, generics, dispatch, and exceptions.

## Types and Subtypes

A derived type creates a distinct type; a subtype preserves the parent type and constrains its values.

```ada
type Metres is new Long_Float;
type Seconds is new Long_Float;
subtype Percentage is Integer range 0 .. 100;
```

`Metres` and `Seconds` cannot be mixed accidentally; `Percentage` is still `Integer`. Prefer constrained scalar subtypes for simple ranges. Use `Static_Predicate` or `Dynamic_Predicate` for meaningful non-contiguous conditions, considering when their checks occur. Do not create conversion noise by deriving a type for every range.

## Packages and Private Views

Put the public vocabulary and stable contracts in a package spec. Hide representation and helper operations in the private part/body:

```ada
package Accounts is
   type Account is private;
   Insufficient_Funds : exception;

   function Open (Initial : Amount) return Account
     with Pre => Initial >= 0;
   procedure Debit (From : in out Account; Sum : Amount)
     with Pre => Sum >= 0;
   function Balance (Of_Account : Account) return Amount;
private
   type Account is record
      Current : Amount := 0;
   end record;
end Accounts;
```

Use `limited private` when assignment/copying has no valid meaning. A private extension is appropriate when clients need tagged polymorphism while representation remains hidden. Private child units can see an ancestor's private part: privacy is an abstraction/compilation boundary, not confidentiality.

## Tagged Types and Dispatch

Tagged records add extension, run-time tags, and dispatch. Use them for a genuinely open family whose clients need class-wide operations. Prefer ordinary records, variants, composition, or generics for closed designs and static reuse.

- Mark abstract roots and primitive operations `abstract` where appropriate.
- Use interfaces for multiple interface inheritance.
- Write `overriding`/`not overriding` to have the compiler check intent.
- Use `T'Class` only where dynamic dispatch is intended.
- Preserve substitutability with class-wide contracts; see `CONTRACTS_SPARK.md`.

## Generics

Use generics when an algorithm or package should be checked and specialized at compile time. Keep formal requirements minimal and explicit (types, operations, equality/ordering). Instantiate at a package boundary with a descriptive name. Do not use tagged dispatch merely to avoid writing a generic, or a generic merely to hide one trivial operation.

## Exceptions and Results

Use language exceptions such as `Constraint_Error` when a violated language check is the real failure, and package-specific exceptions for meaningful API failures. Use ordinary return/status/variant results for common expected alternatives when that makes control flow clearer.

```ada
begin
   Update_File;
exception
   when E : Device_Error =>
      Log (Ada.Exceptions.Exception_Information (E));
      raise;
end;
```

Catch the narrowest exception the boundary can handle. A `when others` handler belongs mainly at process, request, task, or subsystem boundaries and must restore/report a known state; do not silently continue. Scoped finalization is preferable to duplicated cleanup handlers. Exceptions escaping a task terminate that task rather than propagating normally to its creator.

## Ada 2022 Gating

Useful Ada 2022 facilities include target-name `@`, declare expressions, delta/container aggregates, iterator filters, reductions, parallel constructs, and `Global`/`Nonblocking`. Use them when clearer, but first inspect the GPR language switches and selected GNAT implementation list. Compiler parsing, standard library, and runtime support are distinct concerns; retain an Ada 2012/sequential alternative when promised targets require it.

## Review Checklist

- Does each derived type represent a real domain distinction?
- Are representations and invalid states hidden behind package operations?
- Is copying intentionally allowed or prohibited?
- Is dispatch genuinely needed, and are overrides explicit?
- Do generic formals state only necessary capabilities?
- Are exceptions specific, documented, and handled only at useful boundaries?
- Is every Ada 2022 feature supported by the pinned toolchain/runtime?

## Authoritative Primary Sources

- [Ada 2022 RM 3.2, Types and Subtypes](http://www.ada-auth.org/standards/22rm/html/RM-3-2.html)
- [Ada 2022 RM 3.4, Derived Types and Classes](http://www.ada-auth.org/standards/22rm/html/RM-3-4.html)
- [Ada 2022 RM 3.9, Tagged Types and Type Extensions](http://www.ada-auth.org/standards/22rm/html/RM-3-9.html)
- [Ada 2022 RM 7.3, Private Types and Private Extensions](http://www.ada-auth.org/standards/22rm/html/RM-7-3.html)
- [Ada 2022 RM 11, Exceptions](http://www.ada-auth.org/standards/22rm/html/RM-11.html)
- [Ada 2022 Overview](http://www.ada-auth.org/standards/overview22.html)
- [GNAT Implementation of Ada 2022 Features](https://docs.adacore.com/gnat_rm-docs/html/gnat_rm/gnat_rm/implementation_of_ada_2022_features.html)
