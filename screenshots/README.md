# Screenshots — Remind Neural Forecaster 0.8.2

All images in this directory are unedited 1920×1080 PNG captures from the real
Release application. They were produced with `tools/capture-marketing.ps1` and
Microsoft Edge in headless CDP mode. No UI mockups or generated product images
were used.

The isolated demonstration contained 1,601 deterministic synthetic BTCUSD H1
bars, two dataset snapshots, two completed experiments, one explicitly
activated model and one forecast. `Validation Snapshot` was moved to app-local
trash and restored during capture. The CUDA status shown belongs to the capture
host (NVIDIA GeForce RTX 3060) and is not a minimum hardware requirement.

| File | What it shows | Marketing use | Recommended Czech caption | Recommended English caption |
|---|---|---|---|---|
| `01-dashboard.png` | Connected 0.8.2 Overview with actual GPU/runtime state | Website hero, GitHub README | Lokální CUDA prostředí s živým stavem enginu. | Local CUDA environment with live engine status. |
| `02-experiment-catalog.png` | Two named completed experiments and terminal metrics | Feature page, release announcement | Přehledné experimenty s validačními a OOS výsledky. | Readable experiments with validation and OOS results. |
| `03-experiment-detail.png` | Training configuration and completed job telemetry | Product documentation | Konfigurace a skutečná telemetrie dokončeného CUDA experimentu. | Configuration and real telemetry from a completed CUDA experiment. |
| `04-display-names.png` | MT5 stream, editable snapshot name and selected snapshot | 0.8.2 release notes | Lidsky čitelné názvy bez změny technické identity. | Human-readable names without changing technical identity. |
| `05-snapshots.png` | Snapshot split preview and exact FeatureSchema v1 list | Data workflow documentation | Neměnný snapshot s chronologickými splity a kauzálními features. | Immutable snapshot with chronological splits and causal features. |
| `06-model-catalog.png` | Active immutable candidate, hashes, stream and OOS KPI | Models page, technical article | Explicitně aktivovaný model svázaný s checkpointem a OOS reportem. | Explicitly activated model linked to its checkpoint and OOS report. |
| `07-trash.png` | Recoverable trash entry with Restore and Delete permanently | Main 0.8.2 campaign | Odstraněný snapshot zůstává obnovitelný v lokálním koši. | A removed snapshot remains recoverable in app-local trash. |
| `08-trash-restore.png` | Restored snapshot back in the catalog and empty trash | Recovery documentation | Restore bezpečně vrací ověřený snapshot do katalogu. | Restore safely returns a validated snapshot to the catalog. |
| `09-system-health.png` | Detailed RTX 3060, CUDA, layers and capability status | Technical specifications | Detekované zařízení, CUDA runtime a capability bez blokování serveru. | Detected device, CUDA runtime and capabilities without blocking the server. |
| `10-research-evaluation.png` | OOS KPI, per-horizon metrics and loss curve | Research feature presentation | Out-of-sample metriky nejlepšího validačního checkpointu. | Out-of-sample metrics for the best validation checkpoint. |
| `11-live-forecast.png` | Fresh multi-horizon High/Low/Midpoint forecast | Live inference presentation | Čerstvý multi-horizon forecast po potvrzeném uzavřeném baru. | Fresh multi-horizon forecast after confirmed closed-bar ingestion. |

## Usage notes

- Prefer `01`, `02`, `06`, `07` and `10` for a concise 0.8.2 launch story.
- Keep the full 16:9 image where possible. Cropping should not remove the active
  navigation state or labels that establish context.
- Do not present the synthetic KPI values as a benchmark, trading result or
  forecast-quality claim.
- Do not imply that the RTX 3060 is required or that the shown latency is
  guaranteed on other systems.

