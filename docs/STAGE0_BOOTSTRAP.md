# Stage-0 Bootstrap Audit

Last updated: 2026-07-25

Owner: `claude` (task `stage0-dependency-audit`, handed off by `codex`).

This document audits the six pinned stage-0 inputs in
[`bootstrap/sources.toml`](../bootstrap/sources.toml), enumerates the
transitive self-hosting closure in
[`bootstrap/dependencies.toml`](../bootstrap/dependencies.toml), and proposes a
defensible build order. **It does not assert that Sable is independent.** The
closure below is a reviewed enumeration; per-leaf pinning and verification are
future work tracked as acceptance criteria at the end.

## Phase model

The bootstrap is a boundary, not a single build. Four phases move from the
disposable host to an independent, self-hosting base:

| # | Phase | Builds against | Output |
|---|-------|----------------|--------|
| 0 | `seed` | the Arch/CachyOS host | disposable stage-0 artifacts only |
| 1 | `toolchain` | the seed | a two-pass toolchain that no longer references the seed sysroot |
| 2 | `temp-tools` | the pass-2 toolchain | a minimal POSIX userland sufficient to enter a clean chroot |
| 3 | `chroot-base` | itself, in a clean chroot | the independent base rebuilt as signed Sable packages |

The seed's exact package provenance is captured separately by
`bootstrap/capture-host-seed` (task `host-seed-provenance`, owned by `codex`)
and must not appear in the phase-3 closure.

## Where the six pinned inputs sit

The current manifest spans **two different phases**, which is worth making
explicit:

- **Toolchain phase:** `binutils`, `gcc`, `glibc`, and `linux-lts` (the last as
  API headers first, full kernel later). These are the self-hosting toolchain.
- **Base phase:** `systemd` and `pacman`. These are not toolchain components;
  they are ordinary base packages built *inside the chroot* with the finished
  toolchain, via `makechrootpkg`, using `packages/*/PKGBUILD` recipes.

Recommendation: keep `systemd` and `pacman` pinned, but treat their large build
closures (crypto, TLS, `util-linux`) as **phase-3 package dependencies pinned in
their PKGBUILDs**, not as stage-0 toolchain sources. Pulling the full
systemd/pacman graph into stage-0 is unnecessary and explodes it.

## The transitive closure

`bootstrap/dependencies.toml` lists 60 components grouped by phase and role.
The shape of the closure:

- **Toolchain core:** binutils, gcc, glibc, Linux API headers.
- **GCC math prerequisites:** gmp, mpfr, mpc, and (optional) isl.
- **Compression libraries:** zlib, zstd, xz, bzip2 — required both to unpack
  `.tar.*` sources and by later targets (LTO, kernel, libarchive).
- **Core POSIX build userland (temp-tools):** make, bash, coreutils, sed, gawk,
  grep, diffutils, findutils, m4, autoconf, automake, libtool, bison, flex,
  gperf, texinfo, perl, python, gettext, pkgconf, patch, gzip, tar, file,
  ncurses, readline.
- **Build systems:** meson (+python-jinja) and ninja for the meson targets.
- **Kernel build extras:** bc, cpio, elfutils.
- **Base system libraries:** util-linux, kmod, libcap, libxcrypt.
- **Crypto / TLS frontier:** openssl, libarchive, curl, nghttp2, and the gnupg
  stack (libgpg-error, libassuan, libgcrypt, libksba, npth, gnupg, gpgme).

### Pinning progress (2026-07-25)

The **toolchain phase is now fully pinned** — 11 of 11 components. Building on
the four core inputs (binutils, gcc, glibc, linux-lts), the following transitive
toolchain sources were pinned with immutable revisions and SHA-256 in
[`bootstrap/sources.toml`](../bootstrap/sources.toml):

- GCC math prerequisites: `gmp 6.3.0`, `mpfr 4.2.2`, `mpc 1.3.1`, `isl 0.27`.
- Compression libraries: `zlib 1.3.1`, `zstd 1.5.7`, `xz 5.8.1`.

`xz` is pinned at **5.8.1**, deliberately past the compromised 5.6.0/5.6.1 line
(CVE-2024-3094); a security base must never seed from the backdoored release.
The `gmp`, `mpc`, and `zlib` digests were cross-checked against their
well-known published values.

The **temp-tools phase is also fully pinned** — the 27-component minimal POSIX
userland (make, bash, coreutils, sed, gawk, grep, diffutils, findutils, m4,
autoconf, automake, libtool, bison, flex, gperf, texinfo, perl, python, gettext,
pkgconf, patch, gzip, tar, file, ncurses, readline, bzip2). Versions match the
host seed's current releases. GNU tarballs record the canonical `ftp.gnu.org`
URL; their SHA-256 was computed from a byte-identical mirror
(`mirrors.kernel.org`) when `ftp.gnu.org` rate-limited the bulk fetch — the
digest identifies the exact bytes regardless of which mirror serves them.

The **chroot-base phase is now pinned as well** — build systems (meson, ninja),
kernel-build extras (bc, cpio, elfutils), system libraries (util-linux, kmod,
libcap, libxcrypt), and the full crypto/TLS stack (openssl, libarchive, nghttp2,
curl, and the gnupg stack: libgpg-error, libassuan, libgcrypt, libksba, npth,
gnupg, gpgme). bc/cpio record the canonical `ftp.gnu.org` URL with the
mirror-computed digest; the gnupg stack comes from `gnupg.org`, openssl from
`openssl.org`, curl from `curl.se`.

Manifest state: **60 pinned, 0 unpinned, 3 frontier** (`bootstrap/check-sources`
and `bootstrap/check-dependencies` both pass). **Every enumerated stage-0
component is now pinned** with an immutable revision and SHA-256 — acceptance
criterion 1 is met for the current enumeration.

Two things still stand between this and a `COMPLETE`/independent manifest:

1. **Frontier subtree review.** `openssl`, `curl`, and `gnupg` remain flagged
   `frontier = true`. Their *listed* dependencies are all pinned now, but each
   subtree must be re-audited for leaves not yet enumerated (e.g. curl's
   optional psl/brotli/zstd, gnupg's optional ntbtls/sqlite) before the flag can
   be cleared. Clearing all three is required for `status = "COMPLETE"`.
2. **Signature verification** (acceptance criterion 2) is still the next layer to
   add to the fetch/verify tooling; today's pins rest on SHA-256 over
   TLS-authenticated upstreams, several cross-checked against well-known
   published digests.

Independence (`independence = true`) additionally requires a phase-3 chroot build
with zero seed packages and a passing `repo/verify-runtime-closure` — the build,
not the manifest, is what remains after that.

### Expansion frontier

Components marked `frontier = true` in `dependencies.toml` (openssl, curl,
gnupg, and by extension gpgme) have substantial transitive closures of their
own. They are intentionally confined to phase 3 and need a dedicated follow-up
recursion before their subtrees can be called complete. Enumerating them here,
rather than in the toolchain phases, keeps stage-0 minimal.

## Defensible build order

Adapted from the well-trodden LFS two-pass method, targeting a pacman/systemd
base:

1. **Seed check.** Record host toolchain provenance (`capture-host-seed`).
2. **binutils pass 1** — built with the seed, installed to a private prefix.
3. **gcc pass 1** — C-only, using gmp/mpfr/mpc (+isl), configured
   `--without-headers`. Its compiler executable runs on the seed, but target
   output must not include or link against the seed libc.
4. **Linux API headers** — sanitized headers from `linux-lts`, installed only.
5. **glibc** — built with the pass-1 toolchain and the API headers.
6. **libstdc++** — from the gcc source tree, against the new glibc.
7. **binutils pass 2** and **gcc pass 2** — rebuilt against the new glibc so the
   toolchain is self-referential and seed-free.
8. **temp-tools** — build the minimal POSIX userland (make, bash, coreutils,
   sed, gawk, grep, m4, bison, flex, perl, python, tar, xz, …) with the pass-2
   toolchain, enough to enter a chroot with no seed binaries on `PATH`.
9. **Enter chroot** — mount API filesystems, chroot in, drop the seed entirely.
10. **chroot-base** — rebuild everything as signed Sable packages via
    `makechrootpkg`: the toolchain itself, the full userland, the kernel, then
    the base libraries and, last, `systemd` and `pacman` with their crypto/TLS
    dependencies.
11. **Verify independence** — run the acceptance criteria below.

## Findings on the six current inputs

- All four large tarball URLs (binutils, gcc, glibc on ftp.gnu.org; linux on
  cdn.kernel.org) resolve (HTTP 200). The two forge archives (systemd, pacman)
  were stream-hashed and their SHA-256 values **match the manifest exactly**.
- **Durability risk (systemd, pacman):** both pin auto-generated forge archives
  (`github …/archive/refs/tags/…` and `gitlab …/-/archive/…`). Those archives
  are not guaranteed byte-stable across forge regenerations, so a pinned SHA-256
  can silently break later. Arch verifies both via **signed git tags** instead.
  Recommend switching those two to git-tag + signature verification (or an
  upstream release tarball) before promotion. Tracked as a note to `codex`.
- **Version notes:** upstream systemd is 261.2 (manifest pins 261.1); `linux`
  is pinned to 6.12.96, a solid LTS line — worth confirming the intended LTS
  series against Arch's current `linux-lts`. `binutils 2.46.1` / `gcc 16.1.0` /
  `glibc 2.43` are recent releases with stable ftp.gnu.org tarballs (low risk).

## Acceptance criteria for declaring independence

Independence may be claimed only when **all** of the following hold:

1. Every component in `dependencies.toml` is pinned with an immutable revision
   and SHA-256 in `sources.toml` (toolchain phases) or a `packages/*/PKGBUILD`
   (chroot-base), with `frontier` subtrees fully expanded.
2. Signatures are verified wherever upstream publishes one.
3. `dependencies.toml` reaches `status = "COMPLETE"` and lists no unpinned
   component.
4. A phase-3 chroot builds with **zero** seed binaries or seed packages present.
5. `repo/verify-runtime-closure` (task `runtime-closure`) confirms no Arch,
   CachyOS, AUR, or other parent-distribution repository or package remains in
   the runtime closure.

Until every item passes, `status` stays `DRAFT` and `independence = false`.

## Open questions for `codex`

1. Do `systemd` and `pacman` stay in `sources.toml`, or move to a base-package
   manifest with their deps pinned in PKGBUILDs (this audit recommends the
   latter)?
2. Confirm the intended Linux LTS series (6.12.x here vs. Arch's current
   `linux-lts`).
3. Should a `dependencies.toml` validator live alongside `check-sources`? It
   would sit in `bootstrap/` (your scope), so it is yours to add or delegate.
