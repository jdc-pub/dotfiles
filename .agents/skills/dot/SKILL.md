---
name: dot
description: Manage Joey's dotfiles with the `dot` CLI, a thin git wrapper whose work tree is $HOME. Use when tracking, inspecting, or committing dotfiles.
---

# dot

`dot` is plain git with a bare repo at `~/.local/share/dot` and `$HOME` as the work tree. Every git subcommand and flag works.

```sh
dot status --short
dot diff
dot add -f <path>      # -f needed: untracked files in $HOME are ignored
dot commit -m "..."
dot push
```

## Rules

- Run from `~` (or pass absolute paths). Paths are relative to `$HOME`.
- Track new files with `dot add -f`; already-tracked files take a plain `dot add`.
- Stage explicitly by path. Never `dot add -A` or `dot add .`, which would sweep in all of `$HOME`.
- Commits follow the `commit` skill: load it, and resolve `Assisted-by` with the `model` skill immediately before committing.
- Commits and tags are SSH-signed. Check with `dot log -1 --format='%h %G? %s'`; `G` means good.
- Don't push unless asked.
- Never track secrets or private keys (e.g. `~/.ssh/id_*` without `.pub`).
- Use `dot`, not `git`, for anything in the dotfiles repo; plain `git` in `~` isn't this repo.

## Workflow

1. `dot status --short` and `dot diff` to review.
2. `dot add [-f] <paths>`.
3. Load `commit` skill, then `dot commit -m "<scope>: <description>"` with the trailer.
4. Confirm with `dot log -1 --format='%h %G? %s'` and `dot status --short`.
