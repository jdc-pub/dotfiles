---
name: reduce-code
description: Remove slop from an existing change set — committed or uncommitted — by delegating rounds of deletion to subagents and keeping only the verified, net-reducing ones. Use to tighten, de-slop, or shrink a diff.
---

# reduce-code

Remove slop from a change set. You delete what should not be there; you do not
restructure what should. Whatever is left afterwards is the elegance, and a
smaller diff is the evidence that you deleted rather than shuffled.

You orchestrate; the subagent edits files, and you own git.

## Rules

- **Never change behaviour.** A round that alters the public API, wire or
  persisted format, output, exit codes, error contracts, or semantics is rejected,
  however much shorter it is. Nothing on the brief's keep list goes, and never an
  assertion or a test case.
- **Net line reduction is required**, and it is the *last* check, not the first:
  safety is judged before size, and a reduction achieved by a forbidden means is
  rejected even when the number goes down.
- **Never delete what you cannot explain.** Deleting provably dead code is cheap;
  deleting load-bearing code is how this breaks a project.
- **Clean up your own mess.** Scope is the change set plus code the change set made
  dead. Pre-existing rot outside it is not your business.
- **The report is a claim; git is the evidence.** Accept on the diff you read,
  never on the summary you were handed.
- **Every round ends in accept or revert**, and the tree never ends worse than you
  found it. You commit each accepted round as a fixup and fold them in at the end,
  and you never push.

## Run it

**Fix the change set first.** `uncommitted` — the tree is dirty — is index plus
worktree versus HEAD, untracked files included, `BASE=HEAD`, nothing to fold back.
`commit <ref>` is that commit's own changes, `BASE=<ref>^`, fixed up as you accept
rounds and folded back once at the end. Default to `uncommitted` when the tree is
dirty, else to `commit HEAD`. Refuse ranges, merges, and rebases.

**Find the one command that verifies the project** (AGENTS.md, Makefile, CI, package
scripts, `cargo test`, a typecheck) and run it on the untouched change set. If it
already fails, gate on it not getting worse rather than on it passing. If there is
none, gate on a typecheck, and say the confidence is lower.

Then run up to **max-turns** rounds, 10 by default — a round is one subagent plus
one judgement.

1. **Checkpoint** (see Git mechanics below). It is the undo point for the round.
2. **Delegate one round.** `instructions` is the brief below with its placeholders
   filled. `context` is BASE, the change set's paths, what the change set is for,
   the verification command, and why previous rounds were rejected — a fresh
   subagent has no memory and will otherwise re-propose exactly what you threw
   away. Nothing else: every round reviews the whole change set, so never hand it a
   subset of the paths, a shortlist of files to "focus on", or the slop you already
   suspect. Give it the `developer` extension and enough turns to read the whole
   change set and run the verification — but it dies at five minutes with **no
   output at all**, so the round has to finish and report inside that.
3. **Judge it.** `RESULT: none` means it found nothing — stop. Otherwise compute the
   delta yourself and reject when: verification fails or regresses; behaviour, API,
   or output changed; a file outside the change set was touched; something on the
   brief's keep list was removed, or the tripwire fired; the reduction is
   typographic — blank lines, comments, one-lining, shortened names — rather than
   structural; or the round is larger than you can read in full, because a round you
   cannot read is a round you cannot judge. On reject, undo it and carry the reason
   into the next round. On accept, leave the tree alone, log the round, and for
   `commit <ref>` make it durable with a fixup commit (Git mechanics below).
4. **Fold back and report.** Nothing to do for `uncommitted`. For `commit <ref>`,
   fold the accepted rounds into the change-set commit once, when the rounds stop.
   Squashing a fixup keeps that commit's message and trailers, so the result is the
   commit you started from plus the rounds you kept — but if it is on a
   remote-tracking branch you are rewriting published history, so ask the user
   first. If the change set reduced to nothing, the commit was all slop: tell the
   user to drop it.

Stop when a round finds nothing, when the budget runs out, or when two rounds in a
row are rejected for the same reason. Rounds are sequential; each builds on the
accepted state. Report net lines before and after, say which parts of the change set
no round touched, and say plainly if the reduction was small.

## Git mechanics

Each shell invocation is a fresh shell, so define `snap` again in every block.

```sh
RC="$(git rev-parse --absolute-git-dir)/rc-index"
snap() { rm -f "$RC"; GIT_INDEX_FILE="$RC" git add -A -- . >/dev/null && GIT_INDEX_FILE="$RC" git write-tree; }

# checkpoint: a tree of the whole worktree, tracked and untracked, leaving your
# real index untouched. Keep the session's first checkpoint: it is the restore
# point you return to if you stop early.
SNAP=$(snap)
# ... delegate one round, then ...
NOW=$(snap)

# the round's diff — new files included, since both sides are trees
git diff --numstat --no-renames "$SNAP" "$NOW" |
  awk -F'\t' '{a+=$1;d+=$2} END{printf "added=%d deleted=%d net=%d\n",a,d,a-d}'
git diff --name-status --no-renames "$SNAP" "$NOW"

# tripwire: a removed assertion or test case must stop you. Verification cannot
# catch this — a suite with its assertions deleted still passes.
git diff --no-renames -U0 "$SNAP" "$NOW" |
  grep -nE '^-.*(assert|expect\(|\.should|toBe|t\.Errorf|require\.|@Test|#\[test\]|def test_|it\(|test\(|describe\()'

# undo the round: restores modified and deleted files, then removes the files the
# round created. Both halves are needed — restoring does not delete new files, and
# `git stash create`, the obvious snapshot, does not record untracked files at all,
# so a rejected round would silently leave its edits in them.
git restore --source="$SNAP" --worktree -- .
comm -13 <(git ls-tree -r --name-only "$SNAP" | sort -u) \
        <(git ls-files -c -o --exclude-standard | sort -u) | xargs -rd '\n' rm -f

# accept, for `commit <ref>`: record the round as a fixup of the change-set commit.
# One fixup per accepted round, so `git show <fixup>` is that round's diff on its
# own and the accept is durable if the run stops early. BASE does not move:
# `git diff <ref>^` still shows the whole change set, current round included.
git add -A -- <change-set paths> && git commit --fixup=<ref>

# fold the fixups in once, when the rounds stop: squashing keeps the original
# message and trailers, so nothing is lost and nothing is pushed
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <ref>^
```

`GIT_INDEX_FILE` keeps your real index — including anything half-staged — exactly as
it was. Don't use `git stash push`, which mutates the tree, or temp commits for the
checkpoint: HEAD moves for an accepted round's fixup, and nowhere else. Stage the
change set's paths in that fixup, never `.`, so the commit stays inside the change
set; and if a commit hook rewrites a file, the fixup is refused — re-add, commit
again, and count the rewrite as part of the round.

## The subagent brief

````text
Remove slop from an existing change set. You delete what should not be there; you
do not restructure what should.

The change set is the diff between {{BASE}} and the working tree — `git diff
{{BASE}}`, plus the untracked files listed below. Read all of it, every round, as it
stands now: the whole change set, including the files an earlier round already
worked on, and including whatever those accepted rounds changed. The paths listed
below are that whole change set, not a subset of it, and they are the only code you
may edit.

Delete:
- narration: comments that restate the code, docstrings that echo the signature,
  section banners, changelog-in-comments, TODO and apology comments
- ceremony: single-call wrappers, forwarding layers, one-method classes, getters
  over a public field, `x = ...; return x`, `else` after `return`, intermediates
  used once
- speculative generality: options nobody sets, unused config, factories, builders
  and strategies for one case, type parameters used once, injection scaffolding
  for one dependency, flags whose branch is gone
- defensive noise: catch-and-rethrow-unchanged, swallowing try/catch, null checks
  the type already guarantees, re-validating validated input, unreachable fallbacks
- redundancy: near-copies of a helper that already exists, hand-rolled stdlib
  (is_blank, min_by, a set difference), three ways to do one thing, parallel lists
  that must stay in step
- verbose constructs with a direct idiom: manual loops that are an iterator
  adapter, nested if that is a guard clause, `if c: return True else: return False`,
  hand-built strings, manual index juggling
- dead code: unreferenced functions, imports, fields, parameters, commented-out
  blocks, leftovers from an earlier approach
- test infrastructure: duplicated fixtures and setup helpers, mocks that change
  nothing about what is asserted, ceremony in test bodies, narration in tests —
  but never an assertion or a test case itself
- AI tells: over-symmetric structure, bulleted prose docstrings, emoji in logs,
  result_of_the_operation names, leftover debug prints, unwrap / as any with a
  reassuring comment

Keep. These are reasons, not categories, and they outrank everything above:
- validation at a trust boundary, error context, cleanup, security checks
- comments that explain why: a workaround, an invariant, a bug reference
- an abstraction with two real call sites
- compatibility shims and workarounds with a stated reason
- logging with operational meaning
- code that looks dead but is reached by reflection, registration, or an entry point

If you cannot say why a piece of code is there, keep it and flag it in NOTES.
Never delete code you only fail to understand.

Do not: change behaviour, the public API, the wire or persisted format, output,
exit codes, or error contracts; remove or weaken an assertion or a test case, or
loosen a check to make a test pass; remove validation, error handling, cleanup,
security checks, or meaningful logs; add features, options, abstractions, or
generality; rewrite for style alone — reformatting, rename sweeps, comment reflow,
moving code around; edit, create, or delete files outside the change set; or run
git write commands, no add, commit, stash, checkout, restore, or reset. Edit files;
the reviewer owns git.

Nor substitute typography for structure: deleting blank lines, comments, or error
messages, one-lining statements, merging declarations onto a line, and abbreviating
names are golf, not reduction.

Shape of the round: the change set's net lines must end strictly lower, with
additions well under half your deletions — line-neutral cleanup does not count, and
a round that writes as much as it removes is a refactor. Make small, individually
justified edits, anywhere in the change set, and stop before your budget runs out so
you can report. Run {{VERIFY}} before you report; if it fails and you cannot fix it,
revert that edit and say so.

End your reply with exactly this and nothing after it:

```reduce-report
RESULT: reduced | none
REMOVED: <slop you removed, one line each, with file:line>
LEFT: <area you did not reach, if any>
NOTES: <judgement calls, and anything you kept but suspect>
```
````
