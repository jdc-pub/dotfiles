---
name: model
description: Determine which harness and model the current goose session is running as, for provenance and attribution.
---

# Session model

Report the model this session is running as. Use it for provenance — commit trailers, logs, handoff notes — and never guess: an agent cannot introspect its own model, and asked directly it will confabulate a plausible wrong answer.

## Resolve it

Load this skill with `load_skill(name: "model")`, then run the helper beside this file. `model` is the name of this skill, not a tool — never call it as one.

```bash
~/.agents/skills/model/whoami.sh
```

It writes one line to stdout, the `<Titlecase harness>:<model>` value:

```text
Goose:glm-5.3-flash
```

Pass `-v` to see the provenance of the value on stderr. It exits `0` when resolved, `1` when the model cannot be established, and `2` outside a goose session.

Resolve on each new user message; within a turn the value does not change.

## What it resolves

`AGENT_SESSION_ID` names the session, and goose's session record holds that session's model. The helper prefers the id the provider billed, then the id the session requested, then title-cases the harness and removes one provider/vendor prefix.

- Attribution follows the **session, not the process**: a subagent has its own id and its own model, so whoever writes the artifact must be whoever runs the helper.
- `GOOSE_MODEL`, `config.yaml`, and the model you believe you are describe the *configured default*, which is regularly a different model than the session's. Never use them. `goose term info` is the documented display but shows the same default when the record is missing, so the helper reads the session record instead.
- A session with no recorded model is reported as unresolved, never answered with the default.
- Nothing records which weights actually served a request, so this is the session's model, not a verified serving record.

## When it cannot be resolved

Do not substitute a guess or the configured default. Ask the user to confirm the harness and exact model ID — for example `Goose`, `z-ai/glm-5.3-flash` — and wait for their answer.
