# Screenshot capture tools

`capture-marketing.ps1` reproduces the 0.8.2 screenshot set without changing
the repository's product sources or the user's live Forecaster data.

It performs the following steps:

1. verifies that port 7470 is free;
2. starts `build\Release\RemindNeuralForecaster.exe` hidden with `--no-browser`;
3. uses a unique directory below `%TEMP%` as `--data-dir`;
4. ingests a deterministic synthetic BTCUSD H1 stream through RNFBAR01;
5. creates two snapshots and two small CUDA experiments through the real API;
6. registers and explicitly activates one model, then triggers one forecast;
7. moves one disposable snapshot to app-local trash;
8. calls `capture-ui.mjs`, which drives the installed Microsoft Edge through
   the local Chrome DevTools Protocol and saves 1920×1080 PNGs;
9. stops only the Forecaster process it created and removes its temporary data.

No external npm package, browser extension or global installation is required.
The Node script uses the WebSocket and `fetch` implementations included in the
installed Node.js runtime.

Run from the repository root after the Release build is available:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Marketing\tools\capture-marketing.ps1
```

Optional paths:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Marketing\tools\capture-marketing.ps1 `
  -Executable .\build\Release\RemindNeuralForecaster.exe `
  -Edge 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
```

The script refuses to start when port 7470 is occupied. Its token and instance
ID are demonstration-only constants and are never used outside the disposable
data directory.

