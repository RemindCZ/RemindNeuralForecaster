# Remind Neural Forecaster 0.8.2

## A local CUDA research environment for MetaTrader 5 data

Remind Neural Forecaster combines closed-bar MT5 ingestion, reproducible data
preparation, CUDA recurrent-network training, out-of-sample evaluation and live
informational forecasting in one local Windows application.

Data, models and forecasts remain on the user's computer. The application binds
only to `127.0.0.1:7470`, embeds its web interface in the executable and never
places trades automatically.

![Remind Neural Forecaster system overview](screenshots/01-dashboard.png)

## The problem it addresses

Time-series research involves more than running a neural network. Feed identity,
chronology, causality, split boundaries, normalization and the relationship
between an experiment, checkpoint and evaluation all need to remain traceable.
Forecaster keeps these steps in one versioned local workflow:

1. EA_Forecaster sends historical and newly closed bars from MT5.
2. Dataset Store isolates feeds by broker, original symbol, timeframe and schema.
3. The user creates an immutable snapshot with causal features, targets and a
   chronological Train/Validation/Test split.
4. A single-GPU queue trains an LSTM, GRU or RNN and saves the best validation
   checkpoint.
5. The best checkpoint is evaluated exactly once on the untouched Test split.
6. An eligible checkpoint can be explicitly registered and activated for live
   CUDA inference. Activation never enables trading.

## Human-readable catalogs

Version 0.8.2 adds an independent `displayName` to snapshots and experiments.
Defaults are derived from the symbol, timeframe, architecture and UTC creation
time, for example `BTCUSD_M5_LSTM_20260914_035000`. Users may edit the name
before creation.

Internal fingerprints, hashes, relationships and binary artifact filenames do
not change. Name collisions receive deterministic `_2`, `_3` suffixes, while a
short technical ID remains visible as secondary diagnostic information.

![Experiment catalog with human-readable names](screenshots/02-experiment-catalog.png)

## Recoverable deletion, Restore and Permanent Purge

Deletion is an explicit workflow rather than an implicit cascade:

- a preview reports size, dependencies, blockers and exact scope;
- datasets are blocked by snapshots, snapshots by experiments, and experiments
  by registered models or active work;
- cascade must be selected explicitly;
- active or validating models always remain blocking;
- artifacts first move into an app-local trash;
- Restore revalidates metadata and catalog relationships;
- Permanent Purge requires a second confirmation.

A checksummed manifest and transactional file moves support process-restart
recovery. Interrupted purge staging returns to trash rather than to the live
catalog.

![Recoverable app-local trash](screenshots/07-trash.png)

## CUDA training with numerical validation

The CUDA build uses an internal C++/CUDA core without TensorFlow, PyTorch, cuDNN
or WebGPU. Implemented recurrent layers are LSTM, GRU and RNN; training includes
AdamW, gradient clipping and dropout. Parameters, gradients and optimizer state
remain in VRAM during training, and the dataset is uploaded once.

An independent CPU reference verifies forward passes, BPTT, gradients and
CPU/CUDA parity. Seeded experiments are reproducible within the defined FP32
tolerances. On a system without a CUDA toolkit, the same local application still
builds, while capabilities and the Training API accurately report the GPU
backend as unavailable.

![A completed CUDA training experiment](screenshots/03-experiment-detail.png)

## Out-of-sample research

The Test split cannot influence early stopping, checkpoint selection or model
configuration. After training, the best validation checkpoint is evaluated once.
The Research workspace presents aggregate and per-horizon MAE, RMSE,
Directional Accuracy, Range Overlap, Skill vs. Persistence and Test Cases.

The checksummed `RNFOOS01` report links the experiment, snapshot, configuration
and model hash. Prediction previews are intentionally bounded.

![Out-of-sample evaluation](screenshots/10-research-evaluation.png)

## Model Registry and live inference

A completed or early-stopped experiment can become an immutable candidate.
Neither registration nor activation is automatic. Activation asynchronously
validates the checkpoint, report, snapshot, schemas, scalers and hashes, loads a
separate CUDA inference model and performs deterministic smoke inference before
the active model is swapped atomically.

Each confirmed new closed bar can generate a multi-horizon High/Low/Midpoint
forecast. Duplicate ingest creates no duplicate forecast, corrections produce a
new revision, and a bounded queue coalesces obsolete requests. Forecasts are
informational: neither the server nor the EA creates trading orders.

![An active candidate in Model Registry](screenshots/06-model-catalog.png)

## Local security and integrity

- The HTTP server binds to the IPv4 loopback interface only.
- Browser mutations require a session cookie and exact Origin.
- MT5 uses a separate installation token that is never placed in a URL or log.
- Dataset, snapshot, model, report, forecast and trash formats use explicit
  versions, bounds and SHA-256 integrity checks.
- Atomic persistence uses same-directory temporary files and replace/write-through
  publication.
- Truncated, corrupt, oversized or inconsistent data are rejected before they
  become live state.

## Technical architecture

- C++20 and CMake 3.28+
- one product `RemindNeuralForecaster.exe`
- embedded HTML/CSS/JavaScript client
- local REST API and secured WebSocket
- asynchronous server, snapshot, training, evaluation, activation and inference
  workers
- optional internal static CUDA target
- statically linked CUDA Runtime; the verified CUDA 13 build retains runtime
  dependencies on `cublas64_13.dll` and `curand64_10.dll`

## Current 0.8.2 status

Milestones 1–8C are implemented, including MT5 backfill, causal snapshots, CUDA
training, out-of-sample reports, Model Registry, live inference, display names
and recoverable deletion. Installer work, signing, packaging and broader release
hardening remain planned for milestone 9.

Forecaster is a research tool. Its outputs are not investment advice, and no
forecast accuracy or profitability is guaranteed.

