# Remind Neural Forecaster 0.8.2 — marketing package

This directory contains the audited Czech and English marketing material for
Remind Neural Forecaster 0.8.2. Product claims were checked against commit
`1b6cbbb`, the embedded web client, REST/WebSocket implementation and the CUDA
and no-CUDA test matrix.

## Local preview

Open the self-contained bilingual presentation directly from this directory:

```powershell
Start-Process .\index.html
```

From the repository root, use `Start-Process .\Marketing\index.html` instead.
The page has no external runtime dependencies and uses the real screenshots in
`screenshots/`.

## Canonical 0.8.2 material

| File | Purpose |
|---|---|
| `index.html` | Self-contained Czech/English local marketing presentation |
| `website-cz.md`, `website-en.md` | Main product presentation for remind.cz or a product landing page |
| `features-cz.md`, `features-en.md` | Verified feature and architecture reference |
| `changelog-0.8.2-cz.md`, `changelog-0.8.2-en.md` | Release notes focused on 0.8.2 |
| `github-description.md` | GitHub About text, repository introduction and suggested topics |
| `social-cz.md`, `social-en.md` | Ready-to-edit posts for LinkedIn, X and MQL5 |
| `screenshots/` | Real 1920×1080 captures from the Release application |
| `tools/` | Reproducible, isolated screenshot capture scripts |

The older standalone HTML brochures and `assets/manual/` images predate this
package. They are preserved as prior user material, but are not the canonical
0.8.2 copy and were not used as evidence for current claims.

## Verified positioning

Remind Neural Forecaster is a local Windows research application for receiving
closed-bar MT5 data, creating causal dataset snapshots, training recurrent
models on CUDA, evaluating their best checkpoints out of sample and publishing
informational forecasts. It binds only to `127.0.0.1:7470`, serves its web UI
from the executable and does not place trades.

Version 0.8.2 adds human-readable snapshot and experiment names plus
dependency-aware, recoverable catalog deletion. Deletion is non-cascading by
default, active work and active models remain protected, and permanent purge
requires a separate confirmation.

## Responsible use

- Forecasts are research outputs, not investment advice or a trading system.
- The application does not guarantee forecast accuracy, profit or operational
  suitability for unattended production use.
- CUDA training and live inference require compatible NVIDIA hardware and
  runtime libraries. The no-CUDA build remains usable for the local service,
  dataset and metadata workflows but reports GPU training unavailable.
- Installation, signed packaging and broader release hardening remain milestone
  9 work.

## Screenshot provenance

The screenshots were captured from the actual 0.8.2 Release executable with a
temporary synthetic BTCUSD H1 feed. Two small deterministic experiments were
trained on the installed NVIDIA GeForce RTX 3060, one candidate was explicitly
activated, and one disposable snapshot was moved to and restored from trash.
No production, account or personal data were used. See
`screenshots/README.md` for captions and usage guidance.
