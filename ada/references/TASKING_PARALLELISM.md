# Ada Tasking and Parallelism

Use this reference for tasks, protected objects, rendezvous, termination, and Ada 2022 parallel execution.

## Tasks and Rendezvous

A `task type` defines active objects. Entries and `accept` statements implement rendezvous: caller and task synchronize, parameters transfer, the accepting task executes the rendezvous body while the caller waits, and both continue afterward. If the accept body propagates an exception, the same exception is raised at the corresponding entry call; this rendezvous rule is an exception to the general rule that task failures do not propagate to their creators. Use selective accept, delays, and termination alternatives only after defining cancellation and shutdown behavior.

```ada
task type Worker is
   entry Submit (Item : Job);
   entry Stop;
end Worker;

task body Worker is
begin
   loop
      select
         accept Submit (Item : Job) do
            Process (Item);
         end Submit;
      or
         accept Stop;
         exit;
      end select;
   end loop;
end Worker;
```

Keep rendezvous bodies bounded when callers must not be held. Define who owns task objects and how their master waits for them. An unhandled exception terminates the task; it does not propagate like a nested subprogram call. Supervise/report termination explicitly, using `Ada.Task_Termination` when appropriate.

## Protected Objects

A protected type encapsulates shared state:

- protected functions observe state and may execute concurrently;
- protected procedures update with exclusive access;
- protected entries update with exclusive access once their barrier is open, with queued callers.

Keep protected actions short. Calling a potentially blocking operation—including delay, task entry calls, and many I/O operations—during a protected action is a bounded error: detection raises `Program_Error`; otherwise deadlock or a nested protected action can result. Move slow work outside: acquire/update minimal state, release protection, then perform work. Do not return references that let callers mutate protected state unsafely.

Use protected objects for shared mutable state and queues; use rendezvous when synchronous interaction with an active task is the abstraction. Atomic/volatile aspects solve narrower visibility/atomicity concerns and do not replace compound synchronization.

## Ada 2022 Parallel Constructs

Ada 2022 provides parallel loops, parallel blocks (`parallel do ... and ... end do`), parallel iteration, and reductions. `Global` and `Nonblocking` contracts help tools reason about interference and blocking.

Parallel loop iterations may be partitioned into chunks/logical threads. Never assume iteration order, worker identity, or deterministic scheduling. Do not mutate unsynchronized shared state. Use a language-defined reduction, per-chunk independent state, protected synchronization, or an atomic scheme whose complete operation is valid.

```ada
Total : constant Long_Integer :=
  [parallel for X of Values => Long_Integer (X)]'Reduce ("+", 0);
```

A parallel reducer must be associative. Using a non-associative operation is a bounded error and can raise `Program_Error` or produce a different result from sequential reduction; floating-point addition and other order-sensitive operations need explicit analysis or a sequential reduction.

Treat syntax as illustrative until compiled against the project's selected Ada 2022 implementation. Confirm semantics and supported reduction syntax in the exact compiler manual; provide a sequential implementation where portability or determinism requires it.

`Global` describes global data read/written by a subprogram; `Nonblocking` constrains potentially blocking operations. Use truthful aspects at API boundaries, especially for parallel/proof code; do not stamp them on code without checking callees and dispatching behavior.

## Runtime Profiles and Support

Full tasking, parallel execution, Annex D facilities, Ravenscar, Jorvik, embedded runtimes, and zero-footprint runtimes differ. Language acceptance does not prove runtime support. Inspect the selected runtime, target, binder/runtime documentation, and CI image. Ravenscar/Jorvik and safety-critical restrictions are intentional deployment/verification choices, not defaults for ordinary applications.

Test concurrency with deterministic coordination where possible—not sleeps. Cover queue full/empty states, shutdown while blocked, task exceptions, cancellation, races, and repeated runs. Avoid tests that assert a scheduling order the language does not promise.

## Review Checklist

- Who owns each task, and how does it stop and report failure?
- Could rendezvous or protected actions block indefinitely?
- Is every shared mutation synchronized as one complete operation?
- Does parallel code assume ordering or share unsafe state?
- Are `Global` and `Nonblocking` aspects truthful?
- Does the chosen target runtime support each required facility?
- Is a sequential/profile-compatible fallback needed?

## Authoritative Primary Sources

- [Ada 2022 RM 9.1, Task Units and Task Objects](http://www.ada-auth.org/standards/22rm/html/RM-9-1.html)
- [Ada 2022 RM 9.4, Protected Units and Protected Objects](http://www.ada-auth.org/standards/22rm/html/RM-9-4.html)
- [Ada 2022 RM 9.5.2, Entries and Accept Statements](http://www.ada-auth.org/standards/22rm/html/RM-9-5-2.html)
- [Ada 2022 RM 5.5, Loop Statements](http://www.ada-auth.org/standards/22rm/html/RM-5-5.html)
- [Ada 2022 RM 5.6.1, Parallel Block Statements](http://www.ada-auth.org/standards/22rm/html/RM-5-6-1.html)
- [Ada 2022 RM 4.5.10, Reduction Expressions](http://www.ada-auth.org/standards/22rm/html/RM-4-5-10.html)
- [Ada 2022 RM D.13, Ravenscar Profile](http://www.ada-auth.org/standards/22rm/html/RM-D-13.html)
- [Ada 2022 Overview](http://www.ada-auth.org/standards/overview22.html)
