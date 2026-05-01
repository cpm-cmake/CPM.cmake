# RFC: CPM Configuration Precedence for Environment vs Explicit Variables

## Context
CPM currently uses environment variables in several places (for example option defaults and source cache behavior), while other flows rely on explicit CMake variables.

Recent discussions (for example PR #406) show two valid camps:
- Prefer cascading behavior for convenience (`explicit -> env -> default`)
- Prefer explicit-only behavior for predictability/debuggability

Some IDE and indirect build flows make passing explicit `-D...` arguments difficult, which increases demand for environment-based control.

## Proposal (policy discussion only)
Define and document one consistent precedence model across CPM.

### Option A: Standardize cascading
Adopt a uniform precedence for all configurable CPM knobs:
1. Explicit CMake variable/argument
2. Environment variable
3. Internal default

### Option B: Explicit opt-in for environment control
Keep explicit variables as default behavior and require an opt-in switch (for example `CPM_ENABLE_ENV`) before environment variables influence behavior.

## Goal of this PR
This PR intentionally does not change runtime behavior.
It exists to gather maintainer feedback on policy direction before additional implementation PRs are prepared.

## Related discussion
- #406
- #669
- #82
