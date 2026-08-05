# Ada Ownership and Finalization

Use this reference for finite resources, controlled types, access types, allocation, and ownership transfer.

## Prefer Simple Lifetimes

Prefer values, stack/scoped objects, and package encapsulation. Introduce access types for recursive structures, callbacks, polymorphic ownership, shared structures, foreign interfaces, or storage-lifetime requirements—not as the default object model. State whether a handle borrows, shares, or owns.

## Controlled and Limited Controlled

Derive from `Ada.Finalization.Controlled` when a resource-owning value is intentionally copyable. Override `Initialize`, `Adjust`, and `Finalize`. `Adjust` must turn a bitwise assignment result into valid independent ownership (for example by duplicating a handle) or increment a shared reference count.

Derive from `Ada.Finalization.Limited_Controlled` for a noncopyable/unique resource. Override `Initialize` and `Finalize`; it has no `Adjust` operation.

```ada
with Ada.Finalization;
package Files is
   type File_Handle is limited private;
   function Open (Name : String) return File_Handle;
private
   type File_Handle is new Ada.Finalization.Limited_Controlled with record
      Native : Native_Handle := Invalid_Handle;
   end record;
   overriding procedure Initialize (Object : in out File_Handle);
   overriding procedure Finalize   (Object : in out File_Handle);
end Files;
```

For a factory that acquires after default initialization, `Initialize` may intentionally leave the invalid sentinel. `Finalize` should detach the handle first, then use a cleanup operation whose failures are reported without propagating:

```ada
overriding procedure Finalize (Object : in out File_Handle) is
   Handle : constant Native_Handle := Object.Native;
begin
   Object.Native := Invalid_Handle;

   if Handle /= Invalid_Handle then
      Close_Without_Propagating (Handle);
   end if;
end Finalize;
```

`Close_Without_Propagating` must record or report a close failure without raising from finalization. Define the reporting policy at the resource boundary rather than silently ignoring the failure.

Lifecycle details matter:

- `Initialize` occurs after normal default/component initialization.
- `Adjust` is the final adjustment step for copied nonlimited controlled objects.
- `Finalize` runs for successfully initialized objects on normal and exceptional scope exit and before unchecked deallocation reclaims an object.
- If `Initialize` acquires a resource and then raises, that object's `Finalize` is not called. `Initialize` must release anything it acquired before propagating the exception.
- Objects created by declarations are normally finalized in reverse creation order. Objects in an access type's collection, and many composite components, can be finalized in an arbitrary order; never encode resource dependencies around incidental ordering.
- `Adjust` can fail after only some copied state exists. Keep an explicit invalid/empty state; `Finalize` must tolerate successfully initialized partial state, failed adjustment paths, and already-released state.
- Cleanup must be idempotent/no-op-safe. Do not let `Finalize` raise during normal cleanup; lifecycle exceptions have subtle propagation and can leave abnormal objects.

Controlled types add finalization/copy complexity and possible allocation. They are not universal “destructors,” are not C++ move semantics, and are excluded from SPARK. A plain limited type, scoped package operation, or container-owned value is often better.

## Access Types and Accessibility

Named pool-specific, general (`access all`/`access constant`), anonymous, and access-to-subprogram types have different accessibility and ownership implications. Let accessibility checks protect lifetimes. Confine `'Unchecked_Access` to a reviewed low-level adapter with an externally guaranteed lifetime; it bypasses a key dangling-reference defense.

Keep an owning access type private so clients cannot manufacture aliases or call the deallocator:

```ada
with Ada.Unchecked_Deallocation;
package body Trees is
   type Node_Access is access Node;
   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Node, Name => Node_Access);

   procedure Release (P : in out Node_Access) is
   begin
      Free (P); -- finalizes, deallocates, and sets P to null
   end Release;
end Trees;
```

`Free (null)` is harmless, but any other alias remains dangling. Dereferencing an object after its lifetime is erroneous. Deallocating through an access type/storage pool that does not own the allocation is erroneous; task-containing objects have additional hazards. Therefore `Ada.Unchecked_Deallocation` is a narrow implementation mechanism, never a blanket cleanup recommendation.

## Ownership Transfer

A safe unique transfer must be atomic at the abstraction level:

1. Validate that the destination can accept ownership.
2. Move the private handle/access value to the destination.
3. Set the source to its invalid/null state before any path could finalize both.
4. Ensure exceptions cannot leave two owners or no documented owner.

Because ordinary assignment copies nonlimited access values, do not call it a move unless the source is explicitly cleared inside the private operation. For shared ownership, define reference counting and concurrency rules; for borrowing, constrain the borrow's lifetime and prohibit retention.

## Review Checklist

- Is the type copyable? What exactly does `Adjust` do?
- Can every lifecycle hook handle partial/empty/already-finalized state?
- Can cleanup raise, re-enter, block, or race?
- Are allocation and `Free` hidden together with the owning access type?
- Could aliases, pool mismatch, or `'Unchecked_Access` outlive the object?
- Does transfer clear the source on every successful path?
- Would a plain limited/private type avoid controlled machinery?

## Authoritative Primary Sources

- [Ada 2022 RM 7.6, Assignment and Finalization](http://www.ada-auth.org/standards/22rm/html/RM-7-6.html)
- [Ada 2022 RM 7.6.1, Completion and Finalization](http://www.ada-auth.org/standards/22rm/html/RM-7-6-1.html)
- [Ada 2022 RM 3.10.2, Operations of Access Types](http://www.ada-auth.org/standards/22rm/html/RM-3-10-2.html)
- [Ada 2022 RM 13.11.2, Unchecked Storage Deallocation](http://www.ada-auth.org/standards/22rm/html/RM-13-11-2.html)
- [SPARK User's Guide, Language Restrictions](https://docs.adacore.com/spark2014-docs/html/ug/en/source/language_restrictions.html)
