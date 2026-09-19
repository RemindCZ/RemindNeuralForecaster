# Remind Neural Forecaster 0.8.2

## Release overview

Version 0.8.2 makes larger snapshot and experiment catalogs easier to navigate
and adds recoverable, dependency-aware deletion. Training numerics,
FeatureSchema, model hashes and the inference protocol are unchanged.

## Human-readable names

- Snapshots and experiments now have an independent `displayName`.
- Snapshot defaults use symbol, timeframe and UTC creation time.
- Experiment defaults add the LSTM, GRU or RNN architecture.
- Names accept 1–96 ASCII letters, digits, spaces, underscores, hyphens and periods.
- Deterministic `_2`, `_3` and later suffixes resolve collisions.
- A custom name can be entered before creation through the UI or API.
- Internal IDs, fingerprints, hashes and binary filenames remain unchanged.

## Catalogs and compatibility

- Data, Training, Research, Models and Live Forecast present names first and a
  shortened technical ID second.
- Older snapshots or experiments without a name derive one during loading.
- An immutable snapshot payload is not rewritten for a name; metadata is held
  in an atomic checksummed sidecar.
- Legacy experiment metadata and snapshot v1 remain readable within their
  documented eligibility limits.

## Dependency-aware Trash

- A preview reports type, name, size, dependencies, blockers and exact scope.
- Deletion does not cascade by default.
- Explicit cascade can include inactive dependent artifacts.
- Active training/evaluation/cancelling jobs and active or validating models
  always block removal.
- Files first move transactionally into app-local trash.
- Restore reloads and validates catalog relationships.
- Permanent Purge and Empty trash require separate double confirmation in UI.
- `catalog.changed` WebSocket events refresh all open workspaces.

## Recovery and integrity

- The `RNFTRS01` manifest uses an explicit version, strict bounds and SHA-256.
- Startup reconciles an interrupted remove or restore.
- Interrupted purge staging rolls back into trash and does not unexpectedly
  reactivate data.
- Invalid paths, IDs, checksums, bounds or unexpected files stop safe loading
  rather than continuing with ambiguous state.
- Catalog references prevent concurrent removal during snapshot creation, model
  registration and dependent operations.

## UI and API

- New app-local Trash panel with Restore and Delete permanently actions.
- Delete dialog shows dependency preview and an explicit cascade option.
- DELETE/restore/purge mutations retain browser-session and Origin protection.
- Dependency conflicts return HTTP 409 with a structured list.
- New `catalog.changed` WebSocket event keeps open pages synchronized.

## Verification

- CUDA Release: 49/49 tests.
- no-CUDA Release: 31/31 tests.
- Additional focused tests covered strict confirmation JSON, collision recovery,
  concurrent references, restore rollback and interrupted purge staging.
- `git diff --check`, JavaScript syntax and runtime smoke passed.

## Release boundary

0.8.2 does not add trading, automatic model activation, CSV import, a new
FeatureSchema or new training numerics. Installer, signing and distribution
hardening remain milestone 9 work.

