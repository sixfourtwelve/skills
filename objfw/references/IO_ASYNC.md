# ObjFW I/O, Networking, and Asynchronous Work

Use this reference for files, streams, sockets, HTTP, delegates, handlers, timers, and run loops.

## Stream Semantics

`OFStream` is the central abstraction for byte and text I/O. Choose the method by its exact contract:

- an “at most” buffer read can return fewer bytes than requested;
- an exact data or typed read can throw if the stream ends too early;
- line/string methods decode text and can throw encoding exceptions;
- typed integer and float methods encode byte order in the selector;
- buffered writes require an explicit flush before close when pending data must be preserved; closing an `OFStream` does not flush its write buffer.

For a protocol field that must contain a fixed number of bytes, use the documented exact-length API or loop until complete. Do not treat a short read as end-of-stream unless the API says so.

Use endian-specific methods for wire and file formats. Never rely on the host Mac's byte order.

Flush buffered output when required, then close resources at the point ownership ends. ARC releases objects, but it does not communicate application-level completion such as finishing an archive, closing a subprocess input direction, or finishing a protocol exchange.

## Custom Streams

When subclassing `OFStream`, follow the low-level override contract in the target header. Current ObjFW documentation directs subclasses to implement the low-level read/write/end methods rather than replacing higher-level cached methods.

Before implementing a subclass:

1. Read `OFStream.h` for the pinned version.
2. Inspect an existing stream subclass with similar behavior.
3. Preserve short-read, partial-write, end-of-stream, buffering, and exception semantics.
4. Test boundary sizes, zero-length operations, truncation, close behavior, and repeated calls.

Copying a stream does not imply an independent stream; ObjFW documents stream copying as retaining the same stream. Do not use `copy` to create a separately synchronized reader/writer.

## Files and IRIs

- Prefer ObjFW file and IRI abstractions to raw POSIX paths/calls in portable code.
- Distinguish a filesystem path from an IRI; do not pass one where the other is required because both happen to be strings.
- Check whether file support exists for the target before exposing file-backed behavior.
- Preserve the documented ownership of native handles passed to `OFFile` initializers.
- Use `OFFileManager` capability methods and feature guards for platform-dependent metadata or links.

## Sockets and HTTP

- Keep socket addressing in ObjFW's socket-address types and helpers.
- Handle DNS, connect, bind, accept, TLS, read, write, and HTTP failures using their documented specific exceptions.
- Treat network reads as potentially short. Public synchronous `OFStream` writes either complete or throw; handle partial progress only when using a low-level, nonblocking, or asynchronous API whose contract exposes it. Treat asynchronous state as re-entrant unless the API guarantees otherwise.
- Validate HTTP status and application-level response semantics; transport success alone is not domain success.
- Bound response sizes and time/resource consumption for untrusted peers.
- Keep TLS verification enabled unless the user explicitly requests an insecure development path and the risk is made clear.

## Async Handlers and Delegates

ObjFW async I/O is run-loop-based. For each async selector, inspect the typedef and declaration in the target header before writing the callback.

Current patterns commonly include:

- callback exception arguments that are `nil` on success;
- read handlers returning `true` to continue receiving and `false` to stop or yield to the next queued handler;
- write handlers returning the next `OFData` / `OFString`, or `nil` to stop;
- overloads accepting an `OFRunLoopMode`;
- `handler:` APIs replacing deprecated `block:` APIs.

Inside a callback:

1. Check the exception before consuming the result.
2. Make the continue/stop return value explicit.
3. Keep buffers and captured state alive for the full operation.
4. Avoid starting conflicting operations on the same stream.
5. Restore invariants before invoking user code that could re-enter the object.

Prefer current non-deprecated `handler:` selectors in new block-capable code. Use delegates where blocks are unavailable, project style prefers them, or a long-lived object naturally owns the callback lifecycle.

## Run Loops and Timers

- Ensure the relevant `OFRunLoop` is actually running; scheduling alone does not execute work.
- Select a custom run-loop mode only when the application deliberately services that mode.
- In threaded code, verify which thread owns the current/main run loop and where callbacks execute.
- Invalidate timers and cancel queued async work when the owning object's lifecycle ends.
- Do not block a run-loop callback with long CPU work or synchronous I/O when responsiveness matters.

## Feature Guards

Async stream APIs may require both sockets and blocks. Guard declarations and implementation with the macros from the configured ObjFW headers, commonly including:

```objc
#if defined(OF_HAVE_SOCKETS) && defined(OF_HAVE_BLOCKS)
/* handler-based asynchronous socket code */
#endif
```

Do not invent feature macros. Copy the precise guards used by the target ObjFW header.

## Test Checklist

Test the states that make I/O code fail:

- short reads and partial writes;
- zero bytes and exact boundary sizes;
- truncated frames and malformed text;
- wrong byte order;
- exception passed to async callback;
- callback returning continue and stop;
- peer close before completion;
- explicit close/flush behavior;
- feature-disabled compilation where portability matters;
- object owner deallocation/cancellation while work is queued.

## Primary Sources

- [OFStream API](https://objfw.nil.im/docs/interfaceOFStream.html)
- [OFRunLoop API](https://objfw.nil.im/docs/interfaceOFRunLoop.html)
- [OFFile API](https://objfw.nil.im/docs/interfaceOFFile.html)
- [OFStream delegate API](https://objfw.nil.im/docs/protocolOFStreamDelegate-p.html)
- [ObjFW source](https://github.com/ObjFW/ObjFW/tree/main/src)
