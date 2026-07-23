# Packaging Policy

## Sources

- Fetch source from the upstream project or its documented release mirror.
- Pin immutable release tags or commit hashes.
- Verify a SHA-256 hash and upstream signature when one exists.
- Record the license and include required notices.
- Do not execute network downloads during `build()` or `package()`.
- Do not use AUR helpers in project builders.

## Builds

Packages build as an unprivileged user in a disposable, project-owned clean
root. Build roots contain only packages from the snapshot being constructed.
Each package retains `.BUILDINFO`, `.PKGINFO`, checks, logs, source hashes, and
an SBOM.

Project recipes use `check()` for upstream tests unless a documented technical
reason prevents it. Disabling tests requires a tracked issue and blocks stable
promotion for core packages.

## Repositories

`testing` receives signed build artifacts. Promotion to `stable` copies the
exact package files, signatures, and repository database from an accepted
snapshot. Promotion never rebuilds or changes compression.

The stable client configuration uses:

```ini
SigLevel = Required DatabaseOptional TrustedOnly
LocalFileSigLevel = Required
```

Before publishing an ISO, `repo/verify-runtime-closure` checks that no Arch,
CachyOS, AUR, or other parent-distribution repository is configured.

## Naming

Project-owned packages use the `sable-` prefix. The product and visible
branding use the exact name `Sable`.
