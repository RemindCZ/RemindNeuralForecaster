# Social copy — English

## LinkedIn / longer announcement

Remind Neural Forecaster 0.8.2 makes research artifacts easier to understand and
safer to manage.

Snapshots and experiments now have human-readable display names while internal
IDs, fingerprints and hashes remain unchanged. Before deletion, the catalog
shows dependencies and exact scope. Delete does not cascade by default, active
work and models remain protected, and removed artifacts first enter app-local
trash with Restore. Permanent Purge is a separately confirmed operation.

The application remains local: one Windows executable, a server bound only to
`127.0.0.1:7470`, an embedded web UI, MT5 Dataset Store, causal snapshots,
CUDA LSTM/GRU/RNN training, out-of-sample evaluation, Model Registry and
informational live forecasts without trading orders.

0.8.2 was verified in CUDA and no-CUDA Release configurations. It is a research
tool; outputs are not investment advice and do not guarantee accuracy or profit.

## X / short version

Remind Neural Forecaster 0.8.2: readable snapshot and experiment names,
dependency preview, app-local Trash, Restore, confirmed Permanent Purge and
restart recovery. One loopback-only Windows EXE; CUDA and no-CUDA builds. No
automated trading.

## MQL5 community

Version 0.8.2 improves the local research workflow connected to EA_Forecaster.
The EA continues to send closed bars from `OnTimer`, handle backfill/reconnect
and optionally draw a validated High/Low/Midpoint forecast. It performs neither
neural computation nor trading operations.

The release adds editable names for dataset snapshots and experiments together
with a safe catalog Trash. Deletion starts with a dependency preview; a snapshot
used by an experiment, or an experiment with a registered model, cannot be
removed accidentally. Restore revalidates metadata, and permanent purge needs a
separate confirmation.

Forecaster remains bound to `127.0.0.1:7470`. MT5 WebRequest is synchronous,
the URL must be allowed by the user, and WebRequest is unavailable in Strategy
Tester.

## Suggested captions

- “Local CUDA device, capability and runtime status in one view.”
- “Readable experiment names with technical IDs still available.”
- “Dependencies first, recoverable trash second, permanent deletion only after confirmation.”
- “Out-of-sample metrics from the best validation checkpoint.”
- “Live forecasts are informational and never trade automatically.”

## Hashtags

`#CUDA #CPlusPlus #MQL5 #MetaTrader5 #TimeSeries #MachineLearning #LocalFirst`

