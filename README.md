# signal-transport

Asynchronous Signal framing over `tokio` streams, for Nexus transports.

Signal owns the frame: the four-byte big-endian length prefix, the 8 MiB
body capacity, and blocking `FrameReading` and `FrameWriting`. This crate
carries the same frame over any `tokio` `AsyncRead` or `AsyncWrite`:

- `AsyncFrameReading::read_frame` reads one whole frame, refusing a body
  past its `FrameCapacity` before allocating it.
- `AsyncFrameWriting::write_frame` writes one whole frame and flushes.

Both futures are `Send`, so a Nexus can spawn a connection that holds them.

Transport is its own crate rather than a signal feature. A feature is a
build input, so signal with and without it would be two builds; as a crate,
signal is one build for every consumer, a contract crate builds it without
`tokio`, and only a Nexus that speaks over an asynchronous stream takes this
one.
