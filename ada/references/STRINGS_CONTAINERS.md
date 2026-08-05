# Ada Strings and Containers

Use this reference to choose text and collection representations and to review invalidation and allocation behavior.

## Strings

`String` is an array type; each object has fixed bounds. Use fixed `String` objects for known-size buffers/local values, and unconstrained `String` parameters or function results when the caller need not store a mutable-size object.

Use `Ada.Strings.Unbounded.Unbounded_String` for stored text whose length changes:

```ada
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

Name : Unbounded_String := To_Unbounded_String ("Ada");
-- Prefer Append/Length/package operations; convert at an external boundary.
```

Use `Length`, `Append`, `To_Unbounded_String`, and `To_String` deliberately. The type is private and may allocate/finalize; repeated conversion/concatenation can be costly. The overload `To_Unbounded_String (Length : Natural)` creates represented but uninitialized characters—fully assign them before reading.

Alternatives:

- `Ada.Strings.Bounded.Generic_Bounded_Length` when a maximum is a meaningful invariant.
- Fixed `String` when exact storage and bounds suit the protocol.
- Wide/wide-wide packages for the selected character model.
- `Ada.Text_IO.Unbounded_IO` for unbounded text I/O.

Do not default to `Ada.Strings.Unbounded.String_Access` or its `Free`; those are low-level legacy facilities. Define encoding and byte conversion explicitly at external boundaries.

## Vectors

The exact definite package is plural: `Ada.Containers.Vectors`. Instantiate it with a discrete index and definite element type:

```ada
with Ada.Containers.Vectors;
package Job_Vectors is new Ada.Containers.Vectors
  (Index_Type   => Positive,
   Element_Type => Job);

Jobs : Job_Vectors.Vector;
Job_Vectors.Append (Jobs, New_Job);
```

Use vectors for random access and growth/insertion mainly at the high end. Length/capacity use `Ada.Containers.Count_Type`. If growth is predictable, `Reserve_Capacity` can reduce reallocations, but capacity and allocation cost remain implementation/target concerns.

Treat structural mutation as invalidating cursors and references unless the exact operation guarantees otherwise. Check `Has_Element` before cursor dereference. Do not retain values returned by reference accessors past mutation or container lifetime. Iteration and callback operations enforce tampering rules: never insert/delete/clear the same container from a callback that prohibits it. Ada 2022 `Stable` views trade allowed mutation for fewer relevant tampering checks; verify tool support and exact contract.

## Definite, Indefinite, and Bounded

- Use `Ada.Containers.Indefinite_Vectors` (and other `Indefinite_*`) when key/element types are indefinite, such as unconstrained strings.
- Use `Bounded_Vectors` and other `Bounded_*` packages when fixed maximum capacity/no implicit growth is part of deployment policy. Handle capacity failure deliberately.
- A container holding `Unbounded_String` is definite because `Unbounded_String` itself is definite; do not choose indefinite solely because the text length varies.

## Choose by Operations

- `Vectors`: indexed access, compact sequence, high-end append.
- `Doubly_Linked_Lists`: stable-node sequence editing where random access is unnecessary.
- `Hashed_Maps`/`Hashed_Sets`: average constant-time lookup with correct hash/equality consistency.
- `Ordered_Maps`/`Ordered_Sets`: sorted iteration and range/order operations.
- Synchronized queues: producer/consumer communication; choose bounded vs unbounded based on backpressure/resource policy.

Do not force every collection into a vector. Account for ordering, duplicate policy, key stability, iterator/reference validity, worst-case allocation, and concurrency. General containers are not inherently thread-safe.

## Review Checklist

- Is text fixed, bounded, or dynamically sized? Which encoding is external?
- Are conversions/allocations hidden from hot loops?
- Is the element/key definite, and is bounded capacity required?
- Can mutation invalidate a cursor/reference retained by the code?
- Does callback mutation violate tampering rules?
- Does the chosen container match lookup, ordering, insertion, and queue semantics?
- Are shared containers protected or otherwise synchronized?

## Authoritative Primary Sources

- [Ada 2022 RM A.4.5, Unbounded-Length String Handling](http://www.ada-auth.org/standards/22rm/html/RM-A-4-5.html)
- [Ada 2022 RM A.4.4, Bounded-Length String Handling](http://www.ada-auth.org/standards/22rm/html/RM-A-4-4.html)
- [Ada 2022 RM A.18, The Containers Library](http://www.ada-auth.org/standards/22rm/html/RM-A-18.html)
- [Ada 2022 RM A.18.2, The Generic Package Containers.Vectors](http://www.ada-auth.org/standards/22rm/html/RM-A-18-2.html)
- [Ada 2022 RM A.18.19, The Generic Package Containers.Indefinite_Vectors](http://www.ada-auth.org/standards/22rm/html/RM-A-18-19.html)
