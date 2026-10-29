---
name: commit
description: Write concise commits using Scoped Commits.
---

# Commit messages

Use [Scoped Commits](https://scopedcommits.com):

```text
<scope>: <description>

<optional body>

<optional trailers>
```

Use a specific subsystem as the scope and a concise, imperative description. Use a broader scope such as `treewide` when needed; special commits may use Git's normal format.

Agent contributions are **never** `Co-authored-by`. When an agent contributed, add this trailer at the end:

```text
Assisted-by: <Titlecase harness>:<model-name>
```

## Runtime attribution

Use the `model` skill to find the harness and model of the session making this commit, and use the value it resolves as the `Assisted-by` value:

```text
Assisted-by: Goose:deepseek-v4.1-flash
```

- If the user has already explicitly provided or confirmed both values in this conversation, use that confirmation instead.
- Resolve it immediately before committing, because it describes the session that runs it. A subagent has its own session and its own model, so whoever writes the commit must be whoever resolves it.
- Never hand-write the value and never infer it from the agent's own answer, `GOOSE_MODEL`, `config.yaml`, `goose term info`, Zed, or `TERM_PROGRAM`.
- When the `model` skill reports it unresolved, do not guess and do not substitute the configured default. Ask the user, and do not commit until they confirm:

  > Please confirm the runtime attribution for this commit: the harness name and exact model ID (for example, `Goose`, `z-ai/glm-5.3-flash`).

- If the user says the model or harness changed, resolve it again before committing.
- Normalize user-confirmed values the same way: title-case the harness (`goose` → `Goose`), remove one provider/vendor prefix from the model ID (`z-ai/glm-5.3-flash` → `glm-5.3-flash`).
- Preserve existing trailers, keep `Assisted-by` as the final trailer, and never add `Co-authored-by` for agent assistance.
