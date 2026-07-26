# Sable Multi-model Collaboration

`scripts/ai-collab` lets multiple AI models share one Sable checkout without
silently editing the same files. It provides an atomic task workboard,
path-level claims, directed handoffs, notes, and a generated context packet.

Runtime state lives in `.sable-ai/` and is intentionally ignored by Git:

- `state.json` contains registered agents and current tasks.
- `events.jsonl` is an append-only audit log.
- `lock` serializes all mutations with `flock`.

Durable decisions, validation results, and blockers belong in
`docs/AI_HANDOFF.md`, not only in the runtime event log.

## Model Startup

Each model chooses a stable short ID for the current checkout:

```bash
./scripts/ai-collab register codex "OpenAI Codex"
./scripts/ai-collab context codex
./scripts/ai-collab inbox codex
```

Before editing, claim a task and every path that may be changed:

```bash
./scripts/ai-collab claim codex boot-image \
  "Repair and verify the disposable boot image" \
  scripts/build-dev-image-root scripts/test-dev-image dev-image
```

Claims conflict when either path is the other path or its parent. `*` claims
the whole repository and should be reserved for short global migrations.
Absolute paths and `..` components are rejected.

## Communication

Send a general or directed note:

```bash
./scripts/ai-collab note codex "Image rebuild is still running."
./scripts/ai-collab note codex "Please inspect the QML warning." gemini
```

General notes appear in every registered model's inbox. Directed notes appear
in the sender and recipient inboxes.

Transfer an active task to another registered model:

```bash
./scripts/ai-collab handoff codex gemini boot-image \
  "Rebuild completed; run the OVMF test and inspect screenshots."
```

Finish, block, or release work:

```bash
./scripts/ai-collab done gemini boot-image "OVMF test reached SABLE_GUI_READY."
./scripts/ai-collab block gemini boot-image "Needs an Intel graphics tester."
./scripts/ai-collab release gemini boot-image "Available for another model."
```

Inspect shared state:

```bash
./scripts/ai-collab status
./scripts/ai-collab inbox gemini
./scripts/ai-collab context gemini
```

## Rules

1. Read `docs/AI_HANDOFF.md`, then register and inspect the workboard.
2. Claim paths before changing files. Keep claims narrow enough for parallel work.
3. Do not edit a path covered by another model's active claim.
4. Use notes for discoveries that affect another task.
5. Use `handoff` when responsibility changes; do not create duplicate tasks.
6. Run proportionate tests before `done`, and include their result.
7. Record durable outcomes in `docs/AI_HANDOFF.md` before ending a substantial session.
8. Never use the collaboration tool as an approval mechanism for destructive host actions.

This protocol coordinates models that can access the same filesystem. Models
working in separate clones should use separate Git branches and synchronize
through commits or pull requests; `.sable-ai/` is not a network transport.
