# Agent Instructions

Read `docs/AI_HANDOFF.md`, `docs/ARCHITECTURE.md`, and `docs/SECURITY.md` before
making changes.

## Non-Negotiable Invariants

- Sable must not depend on Arch, CachyOS, or AUR repositories at runtime.
- Bootstrap inputs must be pinned, hashed, documented, and removed from the
  final repository closure.
- Never partition, format, resize, or repair a physical disk from automation.
- Build storage may format only a newly created regular image file after
  confirming its parent filesystem is writable.
- Installer storage tests run only against disposable image files.
- Windows partitions are never resized automatically.
- Packages and repository databases are signed before promotion.
- Network services are disabled unless the user explicitly enables them.
- Security tools run unprivileged by default.
- Fullscreen games must not receive shell overlays, blur, or forced opacity.
- Hyprland and in-process plugins are promoted as one tested version set.
- Preserve user data during root rollback.

## Working Practice

- Keep generated artifacts outside the source tree.
- Run `./scripts/check` before handing work to another agent.
- Update `docs/AI_HANDOFF.md` whenever a milestone, blocker, command, interface,
  or architectural assumption changes.
- Record unfinished work as concrete acceptance criteria, not vague TODOs.
- Do not publish signing secrets, machine identifiers, tokens, or user paths.
