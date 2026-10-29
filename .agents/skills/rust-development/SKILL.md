---
name: rust-development
description: Build production Rust with explicit invariants, narrow APIs, disciplined error handling, and rigorous validation.
---

# Rust Development

Write Rust that makes correctness legible to both the compiler and the next maintainer. Favor precise domain modeling and straightforward control flow over cleverness, generic machinery, or superficial brevity.

## Understand before changing

- Read the relevant modules, callers, tests, manifests, feature flags, and lint configuration before editing.
- Preserve established semantics unless the task explicitly changes them. Inspect every caller before changing a public API, persisted format, command output, or error contract.
- Reuse project helpers and established crate types where their semantics match. Do not wrap or duplicate an ecosystem type merely to rename it.
- Introduce a local domain type when the state belongs to the application rather than the dependency. Name request, plan, builder, parsed, and materialized values so their lifecycle is unmistakable.
- Keep changes focused. Separate independent refactors into small, behavior-preserving steps.

## Model the domain

- Make invalid states unrepresentable when the resulting API remains simpler than runtime validation.
- Replace booleans that select states with enums. Eliminate booleans that duplicate facts already represented elsewhere.
- Use enums for mutually exclusive outcomes and transitions; require exhaustive handling when new states are added.
- Parse and validate at boundaries, then pass validated types inward. Keep representations private so callers cannot bypass construction invariants.
- Use newtypes when primitive values share a representation but differ semantically, carry units, or are easy to exchange accidentally.
- Prefer one collection of records over parallel collections whose lengths or ordering must agree.
- Push optionality to the boundary where absence originates. Internal functions should accept required values directly when construction can guarantee them.
- Use typestate only when call ordering is important and the added generic complexity materially prevents misuse.

## Use Rust and dependency types deliberately

- Prefer borrowed data and dependency-provided semantic types over converting identifiers, paths, byte strings, references, and object IDs into `String`.
- Preserve byte-oriented data as bytes when the underlying format does not guarantee UTF-8. Perform lossy conversion only at a human-facing display boundary.
- Prefer slices, iterators, and references when ownership is unnecessary. Clone only to cross an ownership boundary or preserve a required snapshot.
- Group a long list of related parameters into a purpose-named request or options type. Do not call it a builder unless it supports incremental construction.
- Avoid generic abstractions until multiple concrete uses demonstrate the shared contract. A small concrete function is usually easier to review and evolve.
- Use RAII for cleanup and ownership. Make intentional best-effort cleanup explicit rather than silently dropping `must_use` results through lint-evading patterns.

## Control flow and parsing

- Prefer exhaustive `match`, `let ... else`, and early returns over deeply nested conditionals.
- Treat external bytes, subprocess output, repository contents, and persisted data as untrusted input.
- Avoid unchecked indexing and slicing in production parsing. Use `split_first`, `strip_prefix`, `get`, pattern matching, or an iterator that proves the expected shape.
- Return a specific error for malformed or truncated input rather than continuing with partial state.
- Do not use `unwrap`, `expect`, `panic!`, `todo!`, or `unimplemented!` on recoverable production paths. A constant believed infallible is still clearer when construction errors are propagated from a `Result`-returning function.
- Keep comments for non-obvious reasons, safety arguments, external constraints, and deliberate tradeoffs—not for narrating control flow.

## Errors

- Use `Option` only for expected absence and `Result` for failures.
- Define errors at the abstraction boundary where callers can make a decision. Preserve useful sources without exposing irrelevant implementation detail.
- Add context that identifies the failed operation and relevant subject. Error messages should be actionable and stable enough for humans, not stringly APIs for machines.
- Do not erase an error with `map_err(|_| ...)` accidentally. If the source is intentionally irrelevant, bind it with a named ignored variable or document the boundary through the error design.
- Avoid `Box<dyn Error>` in library APIs when callers need to distinguish failures. It is acceptable at executable boundaries that only report and exit.

## Subprocesses and side effects

- Check subprocess exit status and validate stdout before using it. Include stderr or status in failures where it helps diagnosis.
- Pass arguments with `Command::arg`/`args`; do not build shell command strings unless shell evaluation is the required feature.
- Keep side effects ordered so a later failure cannot expose a dangerous intermediate state. Use atomic replacement and compare-and-swap facilities when concurrent writers are possible.
- Resolve expensive or fallible write-only prerequisites only after determining that a write is necessary.

## Public APIs and documentation

- Keep public surfaces small. Prefer private fields plus constructors and accessors when callers must not construct inconsistent values.
- Derive traits deliberately according to semantics, not mechanically.
- Treat public documentation as part of the API. State purpose, guarantees, important failure behavior, and non-obvious constraints concisely.
- Do not expose incidental implementation types or dependency errors unless they are part of the intended contract.
- Consider compatibility before changing public struct fields or enum variants, even in a pre-1.0 crate.

## Lints and unsafe code

- Honor repository lint policy and ensure workspace lints are actually inherited by member crates.
- Fix the cause of a lint rather than weakening the policy.
- Use `#[expect(lint, reason = "...")]` for a narrow, intentional exception. Do not use broad `allow` attributes or suppress lints preemptively.
- Avoid `unsafe` unless required. Keep each unsafe block minimal and state the complete safety argument adjacent to it.

## Tests and validation

- Test public behavior, boundary conditions, errors, state transitions, and invariants. Avoid tests coupled only to private implementation structure.
- Use `cargo nextest run` for all Rust test execution. Never run `cargo test`.
- Apply the repository's required feature and target combinations, for example `cargo nextest run --workspace --all-targets --all-features` when supported by the project.
- Run `cargo fmt --all --check` and the repository's Clippy command, preferably with warnings denied.
- Use `cargo doc --workspace --no-deps` when public API or documentation changes warrant it. Do not substitute documentation builds for tests.
- Review the final diff for accidental API changes, unnecessary churn, duplicated logic, unchecked assumptions, stale comments, and generated-looking repetition.
