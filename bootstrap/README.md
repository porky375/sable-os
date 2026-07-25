# Bootstrap

The bootstrap is the boundary between using the development host and producing
an independent runtime.

`sources.toml` must contain immutable revisions and hashes for every stage-0
input before the builder is implemented. The stage-0 output is not releasable.
The first releasable package set is rebuilt inside a root created exclusively
from stage-0 Sable packages.

Do not add the host's mirror list or package databases to a generated root.

The current six-component manifest starts the host-seeded bootstrap; it is not
yet a complete self-hosting source closure. Host tools may produce disposable
stage-0 artifacts only. Every transitive source and build dependency must be
pinned before the independent rebuild can be called Sable.

## Source Cache

All source archives are stored on the marked external build volume. Fetching
is a separate network-enabled phase:

```bash
SABLE_BUILD_ROOT=/run/media/$USER/SABLE_BUILD ./bootstrap/fetch-sources
```

The fetcher:

- parses and validates `sources.toml` with Python's standard TOML parser;
- permits HTTPS source URLs only;
- resumes `.partial` downloads;
- verifies every SHA-256 before publishing an archive to the cache; and
- atomically writes `sources/stage0/sources.lock.json` with URL, revision,
  expected hash, byte size, and verification time.

Build steps must run offline against that cache. Verify it at any time with:

```bash
SABLE_BUILD_ROOT=/run/media/$USER/SABLE_BUILD ./bootstrap/verify-sources
```

An existing archive with the wrong digest is never replaced automatically.
This preserves evidence of a mirror or storage failure for inspection.
