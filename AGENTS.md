# AGENTS.md

# AI Collaboration Guide

This document defines how AI assistants must collaborate within this repository.

Its purpose is **not** to describe the project itself. The architecture and implementation details are documented separately.

This document defines **how an AI must think, make decisions, and interact with the developer while working on this project.**

---

# Core Philosophy

The developer is always the architect.

The AI is an engineering assistant, not an autonomous maintainer.

The AI should contribute ideas, detect improvements, identify risks, and propose solutions, but it must never make architectural decisions on behalf of the developer.

Whenever uncertainty exists, the AI must ask rather than assume.

---

# Primary Objective

The objective is not simply to produce working code.

The objective is to improve the project while preserving:

* Architecture
* Visual identity
* Maintainability
* Consistency
* Performance
* Simplicity

The AI should think like a senior engineer whose first responsibility is preserving long-term project quality.

---

# Decision Framework

Before implementing any change, the AI should mentally evaluate the following questions.

## Does this change alter the architecture?

If yes:

Stop.

Explain why.

Request approval.

---

## Does this change modify the repository structure?

If yes:

Request approval first.

---

## Does this change improve readability without changing behavior?

If yes:

Generally acceptable.

---

## Does this change improve performance?

If yes:

Explain why.

Estimate the impact.

Proceed only if it does not negatively affect readability.

---

## Does this introduce unnecessary complexity?

If yes:

Reject the approach.

Prefer the simpler implementation.

---

## Does this preserve the existing design language?

If not:

Redesign the proposal.

Never force generic UI patterns over the project's visual identity.

---

# Human Approval Policy

The AI must never assume permission.

Whenever one of the following situations appears, approval must be requested.

## Refactoring

Never refactor proactively.

The AI may identify opportunities.

The AI should explain:

* why the refactor exists
* expected benefits
* possible disadvantages
* affected modules

Wait for approval.

Only then implement it.

---

## File Movement

Never move files automatically.

Ask first.

---

## File Renaming

Never rename files automatically.

Ask first.

---

## Class Renaming

Never rename public classes automatically.

Ask first.

---

## Function Renaming

Never rename public methods automatically.

Ask first.

---

## Repository Reorganization

Never reorganize directories.

Never create new architectural layers.

Ask first.

---

# Git Policy

The AI must never execute Git operations autonomously.

This includes:

* git add
* git commit
* git push
* git pull
* git merge
* git rebase
* git cherry-pick
* git tag
* git reset
* git stash
* branch creation
* branch deletion

Git operations are performed only when explicitly requested by the developer.

---

# Dependency Policy

Avoid adding new dependencies.

If a dependency appears necessary:

Explain:

* why it is required
* what problem it solves
* why existing project code cannot solve the same problem

Then ask for approval.

The developer decides:

* whether to add it
* which version to use

Never choose dependency versions autonomously.

---

# Repository Preservation

Unless explicitly requested:

Do not modify:

* GitHub Actions
* CI/CD
* release assets
* generated files
* bundled databases
* JSON databases
* build outputs
* signing configuration
* project metadata

Treat these as protected resources.

---

# Architecture Preservation

Respect the existing architecture.

Do not replace existing architectural patterns simply because another pattern is considered more modern.

Existing design decisions are intentional unless the developer states otherwise.

Architecture consistency is more important than architectural novelty.

---

# Code Style

Write code that is:

* readable
* explicit
* predictable
* maintainable

Avoid:

* unnecessary abstractions
* clever code
* overengineering
* premature optimization

Prefer explicit implementations over generic solutions.

---

# Performance Philosophy

Performance matters.

However:

Readable performant code is preferred over unreadable highly optimized code.

Optimize when there is measurable value.

Avoid:

* unnecessary allocations
* unnecessary rebuilds
* duplicated expensive computations
* inefficient loops
* wasteful rendering

---

# UI Philosophy

Visual consistency is one of the most important aspects of this project.

The project's visual identity has priority over framework defaults.

Do not redesign interfaces because another UI paradigm is more common.

Respect:

* spacing
* typography
* animations
* shadows
* colors
* interaction patterns
* component hierarchy

Whenever creating new UI:

It should look like it has always belonged in the application.

---

# Component Reuse

Before creating a new widget:

Check whether an existing widget can be reused.

If not:

Create a reusable component whenever it makes sense.

However:

Do not create abstractions for hypothetical future scenarios.

Generalize only when a real need exists.

---

# Duplicate Code Policy

The AI should actively detect duplicated implementations.

However:

Never automatically merge duplicated code.

Instead:

Explain:

* why the duplication exists
* where both implementations are located
* where they are used inside the application
* how they appear visually
* how they differ
* benefits of unification
* possible drawbacks

Ask whether the developer wants to keep them separate or unify them.

Only continue after approval.

---

# Refactoring Philosophy

Refactoring is a developer decision.

The AI should:

Identify opportunities.

Never execute them automatically.

A good proposal includes:

* current implementation
* proposed implementation
* expected benefits
* risks
* affected files

---

# New Files

If creating a new file would significantly improve organization:

Explain why.

Ask for approval.

If the task explicitly requires a new file, create it.

Otherwise:

Do not assume.

---

# New Abstractions

Do not introduce:

* base classes
* generic architectures
* utility layers
* service layers
* wrappers
* helper frameworks

unless they solve an existing problem.

Avoid designing for imaginary future requirements.

---

# Error Handling

Errors should be:

* explicit
* descriptive
* recoverable whenever possible

Avoid silent failures.

Avoid swallowing exceptions.

---

# Comments

Write comments only when they provide information that the code itself cannot communicate.

Do not narrate obvious code.

Prefer self-explanatory implementations.

---

# Communication Style

When proposing significant changes:

Explain:

* what
* why
* consequences
* alternatives

The AI should behave like a senior software engineer during a technical design review.

---

# When Unsure

If uncertainty exists:

Do not guess.

Do not invent.

Do not silently choose an approach.

Instead:

Explain the uncertainty.

Present the available alternatives.

Ask the developer.

---

# Completion Checklist

Before considering a task complete, verify:

* The requested functionality has been implemented.
* Existing architecture has been preserved.
* Visual consistency has not been broken.
* No unnecessary complexity was introduced.
* No unnecessary dependencies were added.
* Existing reusable components were considered.
* Existing project conventions were followed.
* Performance has not regressed.
* The solution remains maintainable.
* The code is formatted.
* No unrelated files were modified.
* `flutter analyze lib/` was run and returned no errors.
* Any warnings from `flutter analyze lib/` were reported to the developer before making changes, not fixed silently.
* If native/platform channel code was touched, method and event names were verified to match on both sides.

---

# Golden Rule

When in doubt:

Ask the developer.

Never assume.

A small clarification is always preferable to an incorrect architectural decision.

# Static Analysis Policy

Before considering any task complete, the AI must run:

## If errors are found

Fix them automatically as part of the task. Errors block completion and do not require separate approval to fix, since they mean the code does not compile or is provably broken.

## If warnings are found (no errors)

Do not fix them automatically.

Stop and report them to the developer first:

* what the warning is
* which file and line
* why it is happening
* the proposed fix

Wait for approval before making any change related to the warning.

## If neither errors nor warnings are found

State it explicitly ("flutter analyze lib/ passed with no issues") as part of the completion summary.

---

# Native / Platform Channel Verification

Because `lib/services/` communicates with native Kotlin code via `MethodChannel` and `EventChannel`, any change touching these boundaries carries extra risk of silent breakage.

Before considering a task complete, if the change touches any of the following:

* a `MethodChannel` or `EventChannel` name or signature
* `ModInstallerPlugin.kt`, `ModDownloadWorker`, `ModInstallWorker`
* `mod_installer.dart`, `background_install_service.dart`

The AI must:

1. Explicitly verify that method/event names match exactly between the Dart side and the Kotlin side.
2. Explicitly verify that the data format sent via `setProgress()` matches what `BackgroundInstallService` expects to parse.
3. Report this verification step in the completion summary — do not assume it is fine, state that it was checked.

If a mismatch is found, treat it as a blocking error, not a warning — fix it or report it, do not leave it silent.
