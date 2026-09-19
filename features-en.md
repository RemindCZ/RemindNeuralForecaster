# Verified Remind Neural Forecaster 0.8.2 features

This reference describes features present in commit `1b6cbbb`. It is not a
promise that roadmap items are already available.

## Application and runtime

| Area | Implemented state |
|---|---|
| Platform | Windows, C++20, CMake, one product EXE |
| Server | HTTP bound only to `127.0.0.1:7470` |
| Client | HTML/CSS/JavaScript embedded in the EXE |
| Realtime | Secured same-origin WebSocket with bounded events |
| CUDA | Asynchronous device, driver, runtime, compute capability and VRAM detection |
| No CUDA | Supported build reporting the training backend unavailable |
| Logging | `error`, `warn`, `info`, `debug`, `trace`; no tokens, cookies or weights |

## MT5 data transport

- `EA_Forecaster` performs backfill and sends closed bars from `OnTimer` only.
- Its state machine covers connect, backfill, live operation and exponential
  reconnect backoff.
- RNFBAR01 is a fixed little-endian protocol with SHA-256 and explicit widths.
- Stream identity includes broker server, original symbol, timeframe and schema;
  `digits` and `point` are retained.
- Bit-identical duplicates are idempotent. Changed content at an existing
  timestamp becomes an audited correction and increments the revision.
- Gaps are neither filled nor interpolated. Time remains broker-server time.
- A journal followed by compaction protects acknowledged backfill from crashes.
- A separate installation token protects `/api/v1/mt5/*`.

## Dataset snapshots

- Immutable, checksummed `RNFSNP01` v1/v2 format.
- FeatureSchema v1 with a fixed set of 12 causal OHLCV features.
- Multi-horizon T+1 through T+N High/Low targets expressed as log changes from
  the base close.
- Chronological Train/Validation/Test splits with no shuffle.
- Target-overlap protection at split boundaries.
- Feature and target scalers fitted only on Train.
- Sequence boundaries at unexpected or non-positive time deltas.
- Deterministic fingerprint covering stream, revision, schema, configuration,
  splits and normalization.
- Asynchronous snapshot creation; list/detail remain metadata-only.

## Experiments and CUDA training

- LSTM, GRU and RNN with FP32 computation.
- CUDA BPTT, loss, gradients, clipping, dropout and AdamW.
- Persistent parameters, gradients and optimizer state in VRAM.
- One dataset upload and no full weight copy in the minibatch loop.
- One active GPU job and a FIFO queue.
- Cancellation at a safe minibatch or GPU-pass boundary.
- Conservative VRAM estimate with a reserve before start.
- CUDA validation, early stopping and an atomically saved best checkpoint.
- Nonterminal states `queued`, `preparing`, `training`, `evaluating`,
  `cancelling`; terminal states `cancelled`, `early_stopped`, `completed`,
  `failed`, `interrupted`.
- An unfinished job becomes `interrupted` after restart instead of being
  guessed or silently resumed.

## Out-of-sample Evaluation and Research

- The untouched Test split is evaluated once, after best-checkpoint selection.
- CUDA reductions produce aggregate and per-horizon MAE, RMSE, Directional
  Accuracy, Range Overlap and Skill vs. Persistence.
- Persistence baseline: midpoint equals the last Close and the interval carries
  forward the last closed bar's High/Low range.
- Crossed predicted High/Low values are ordered and counted separately.
- FP64 metric accumulation and a bounded CPU preview.
- Checksummed `RNFOOS01` reports and metadata-only experiment comparison.

## Model Registry and live inference

- Explicit registration of an eligible best checkpoint as an immutable candidate.
- No automatic activation.
- Asynchronous transactional activation verifies hashes, references, stream,
  schemas, scalers, architecture and horizons.
- Deterministic smoke inference before an atomic active-model swap.
- At most one active model per complete StreamIdentity.
- Persistent CUDA inference weights and a preallocated workspace.
- A bounded queue coalesces obsolete requests for each stream.
- Latest forecast and a 64-entry history are crash-safe and may be marked stale
  after restart.
- Per-horizon output includes High, Low, midpoint, base close, revision, model
  hash, generation time, latency and crossing-correction status.
- The EA draws only its own High/Low/Midpoint objects and never trades.

## 0.8.2 catalog additions

- User-editable `displayName` for snapshots and experiments.
- UTC defaults, safe ASCII validation, a 96-byte limit and deterministic
  collision suffixes.
- Legacy records without names derive one without changing artifact identity.
- Snapshot names live in an atomic checksummed `RNFNAM01` sidecar.
- Data, Training, Research, Models and Live Forecast use names as primary labels
  and retain shortened technical IDs.

## Trash and recovery

- Dependency preview reports blockers, exact scope and byte size.
- Delete does not cascade by default; explicit cascade still respects active
  work and active/validating models.
- Removal first moves owned files beneath app-local `trash/files`.
- The bounded `RNFTRS01` v3 manifest uses SHA-256 and typed transaction states.
- Restore validates files and reconstructs catalog relationships.
- Pending remove/restore transactions are reconciled after restart.
- Pending purge rolls back into trash, not into the live catalog.
- Permanent purge and Empty trash require explicit confirmation.
- Mutations require the browser session and exact Origin; conflicts return HTTP
  409 with structured dependencies.

## Test coverage verified for this package

- CUDA Release: 49/49 CTest tests.
- no-CUDA Release: 31/31 CTest tests.
- Numerical parity and finite-difference gradient checks.
- Corrupt/truncated formats, allocation bounds and SHA-256 failures.
- Restart/persistence, cancellation and concurrency.
- API session/Origin, WebSocket, JavaScript syntax and runtime smoke.
- Display-name collisions, legacy metadata, dependency blocking, cascade,
  restore, purge and simulated interrupted trash transactions.

Counts refer to the local validation matrix run immediately before the 0.8.2
commit.

