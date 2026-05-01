# RFC: CPM Configuration Precedence for Environment vs Explicit Variables

## Context
CPM currently uses environment variables in several places (for example option defaults and source cache behavior), while other flows rely on explicit CMake variables.

Recent discussions (for example PR #406) show two valid camps:
- Prefer cascading behavior for convenience (`explicit -> env -> default`)
- Prefer explicit-only behavior for predictability/debuggability

Some IDE and indirect build flows make passing explicit `-D...` arguments difficult, which increases demand for environment-based control.

## Existing precedence patterns in current codebase

### Pattern group A: option defaults sourced from environment
In `cmake/CPM.cmake`, these options use `$ENV{...}` as their default values:
- `CPM_USE_LOCAL_PACKAGES`
- `CPM_LOCAL_PACKAGES_ONLY`
- `CPM_DOWNLOAD_ALL`
- `CPM_DONT_UPDATE_MODULE_PATH`
- `CPM_DONT_CREATE_PACKAGE_LOCK`
- `CPM_INCLUDE_ALL_IN_PACKAGE_LOCK`
- `CPM_USE_NAMED_CACHE_DIRECTORIES`

This pattern effectively gives users an environment-preseeded default while still allowing explicit cache/configure overrides.

### Pattern group B: explicit variable first, then env fallback, then internal default
Observed examples:
- `cmake/get_cpm.cmake`:
	- `CPM_SOURCE_CACHE` CMake variable
	- then `ENV{CPM_SOURCE_CACHE}`
	- then `${CMAKE_BINARY_DIR}/cmake/...`
- `cmake/CPM.cmake` source cache initialization:
	- derive `CPM_SOURCE_CACHE_DEFAULT` from `ENV{CPM_SOURCE_CACHE}` (or `OFF`)
	- then expose `CPM_SOURCE_CACHE` as a cache path variable

### Pattern group C: per-package override precedence in function logic
In `CPMFindPackage`, package-specific controls follow:
- baseline `CPM_DOWNLOAD_ALL`
- explicit `CPM_DOWNLOAD_<name>` variable
- fallback `ENV{CPM_DOWNLOAD_<name>}`

### Pattern group D: explicit-only local source override today
`CPM_<dependency>_SOURCE` is currently a manual explicit override path in `CPMAddPackage`.
This is the key place under discussion in #406 and in this RFC.

## Existing docs signals in README
- `CPM_SOURCE_CACHE` is documented as configurable by either `-D...` or environment variable.
- README explicitly states the configure option overrides environment for `CPM_SOURCE_CACHE`.
- Local package override is documented via explicit `-DCPM_<dependency>_SOURCE=...`.

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

## Points of interest for discussion (issues and PRs)

### Established environment support and precedent
- [#82](https://github.com/cpm-cmake/CPM.cmake/issues/82): request to configure cache root from environment
- [#83](https://github.com/cpm-cmake/CPM.cmake/pull/83): merged environment support for `CPM_SOURCE_CACHE`
- [#109](https://github.com/cpm-cmake/CPM.cmake/pull/109): Windows-focused support/fixes around env-driven source cache usage

### Existing explicit local override semantics
- [#123](https://github.com/cpm-cmake/CPM.cmake/pull/123): merged local package override via explicit argument
- [#260](https://github.com/cpm-cmake/CPM.cmake/issues/260) and [#261](https://github.com/cpm-cmake/CPM.cmake/pull/261): follow-up behavior/propagation fixes for explicit local override

### Open expansion proposals and policy tension
- [#406](https://github.com/cpm-cmake/CPM.cmake/pull/406): env-based `CPM_<dependency>_SOURCE` and `CPM_PATH` proposal, with discussion around surprise vs convenience
- [#669](https://github.com/cpm-cmake/CPM.cmake/pull/669): desire to shift away from hard env dependence by making defaults explicitly configurable
- [#564](https://github.com/cpm-cmake/CPM.cmake/issues/564) and [#567](https://github.com/cpm-cmake/CPM.cmake/pull/567): enterprise-driven override and redirection requirements

### Decision this RFC asks maintainers to make
Choose one policy direction for future consistency:
1. Standardize cascading precedence (`explicit -> env -> default`) where applicable.
2. Keep environment influence behind explicit opt-in gates for selected features.
