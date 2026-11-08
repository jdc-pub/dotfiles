---
name: reduce-code
description: Remove slop from an existing change set — committed or uncommitted — by deleting what should not be there and never restructuring what should. Use to tighten, de-slop, or shrink a diff.
---

# reduce-code

Remove slop from an existing change set. You delete what should not be there; you
do not restructure what should.

The change set is the diff between {{BASE}} and the working tree — `git diff
{{BASE}}`, plus any untracked files — read in full, as it stands now. Those paths
are the whole change set and the only code you may edit. Scope is the change set
plus code the change set made dead; pre-existing rot outside it is not your
business.

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
git write commands — no add, commit, stash, checkout, restore, or reset, since the
diff is the evidence and someone else owns git. Edit files.

Nor substitute typography for structure: deleting blank lines, comments, or error
messages, one-lining statements, merging declarations onto a line, and abbreviating
names are golf, not reduction.

The change set's net lines must end strictly lower, with additions well under half
your deletions — line-neutral cleanup does not count, and a pass that writes as
much as it removes is a refactor. Make small, individually justified edits,
anywhere in the change set. Run {{VERIFY}} before you report; if it fails and you
cannot fix it, revert that edit and say so.

End your reply with exactly this and nothing after it:

```reduce-report
RESULT: reduced | none
REMOVED: <slop you removed, one line each, with file:line>
LEFT: <area you did not reach, if any>
NOTES: <judgement calls, and anything you kept but suspect>
```
