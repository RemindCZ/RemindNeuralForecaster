# Ověřené funkce Remind Neural Forecaster 0.8.2

Tento přehled popisuje pouze funkce přítomné ve zdrojovém kódu commitu
`1b6cbbb`. Nejde o příslib budoucích částí roadmapy.

## Aplikace a provoz

| Oblast | Implementovaný stav |
|---|---|
| Platforma | Windows, C++20, CMake, jeden produktový EXE |
| Server | HTTP pouze na `127.0.0.1:7470` |
| Klient | HTML/CSS/JavaScript vložené v EXE |
| Realtime | Zabezpečený same-origin WebSocket s omezenými událostmi |
| CUDA | Asynchronní detekce zařízení, driveru, runtime, compute capability a VRAM |
| No-CUDA | Plnohodnotný build se stavem training backend unavailable |
| Logování | `error`, `warn`, `info`, `debug`, `trace`; bez tokenů, cookies a vah |

## Data z MT5

- `EA_Forecaster` provádí backfill a odesílá pouze uzavřené bary z `OnTimer`.
- Stavový automat řeší connect, backfill, live režim a exponenciální backoff.
- RNFBAR01 je pevný little-endian formát s SHA-256 a explicitními šířkami.
- Stream identity zahrnuje broker server, původní symbol, timeframe a verzi
  schématu; `digits` a `point` jsou uloženy v identitě.
- Idempotentní duplicity nemění revizi. Změněný obsah stejného timestampu je
  auditovaná korekce a revizi zvyšuje.
- Gapy se nedoplňují ani neinterpolují. Čas zůstává v broker-server časové ose.
- Journal a následná kompakce chrání potvrzený backfill proti pádu procesu.
- Oddělený instalační token chrání `/api/v1/mt5/*`.

## Dataset snapshoty

- Immutable, checksummovaný `RNFSNP01` v1/v2 formát.
- FeatureSchema v1: pevná sada 12 kauzálních OHLCV features.
- Multi-horizon High/Low cíle T+1 až T+N jako logaritmické změny od base close.
- Chronologické Train/Validation/Test rozdělení bez shuffle.
- Ochrana proti target overlap na hranicích splitů.
- Feature a target scalery fitované pouze na Train části.
- Přerušení sekvence při neočekávaném nebo nekladném časovém rozdílu.
- Deterministický fingerprint obsahuje stream, revizi, schéma, konfiguraci,
  splity a normalizaci.
- Asynchronní tvorba snapshotu; seznam/detail čte metadata bez tensor payloadu.

## Experimenty a CUDA trénování

- LSTM, GRU a RNN s FP32 výpočty.
- CUDA BPTT, loss, gradienty, clipping, dropout a AdamW.
- Persistentní parametry, gradienty a optimizer state ve VRAM.
- Dataset upload jednou; bez plného kopírování vah v minibatch smyčce.
- Jedna aktivní GPU úloha a FIFO fronta.
- Cancellation na bezpečné hranici minibatch/GPU průchodu.
- Konzervativní VRAM estimator s rezervou před spuštěním.
- Validation na CUDA, early stopping a atomicky uložený best checkpoint.
- Stavy `queued`, `preparing`, `training`, `evaluating`, `cancelling` a
  terminální `cancelled`, `early_stopped`, `completed`, `failed`, `interrupted`.
- Po restartu se nedokončený job označí `interrupted`; trénink se nehádá ani
  skrytě neobnovuje.

## OOS Evaluation a Research

- Nedotčený Test split se vyhodnotí jednou až po výběru nejlepšího validačního
  checkpointu.
- CUDA redukce MAE, RMSE, Directional Accuracy, Range Overlap a Skill vs.
  Persistence, agregovaně i pro každý horizon.
- Persistence baseline: midpoint je poslední Close a interval přenáší poslední
  uzavřený High/Low rozsah.
- Zkřížené predikované High/Low se seřadí a crossing se samostatně započítá.
- FP64 akumulace metrik a omezený preview přenos do CPU.
- Checksummovaný `RNFOOS01` report a metadata-only porovnání experimentů.

## Model Registry a live inference

- Explicitní registrace způsobilého best checkpointu jako immutable kandidáta.
- Žádná automatická aktivace.
- Asynchronní transakční aktivace ověřuje hashe, reference, stream, schémata,
  scalery, architekturu a horizonty.
- Deterministický smoke inference před atomickým přepnutím.
- Nejvýše jeden aktivní model pro úplnou StreamIdentity.
- Persistentní CUDA inference váhy a předalokovaný workspace.
- Bounded fronta slučuje starší požadavky pro stejný stream.
- Latest forecast a historie 64 položek jsou crash-safe a po restartu mohou být
  označeny stale.
- Výstup pro každý horizon: High, Low, midpoint, base close, revize, model hash,
  čas generování, latence a příznak opraveného crossingu.
- EA kreslí pouze vlastní High/Low/Midpoint objekty a nikdy neobchoduje.

## Novinky katalogu v 0.8.2

- Uživatelské `displayName` pro snapshot a experiment.
- UTC výchozí názvy, bezpečné ASCII znaky, limit 96 bajtů a deterministické
  suffixy při kolizi.
- Legacy záznam bez jména získá odvozený název bez změny identity artefaktu.
- Snapshot jméno je v atomickém checksummovaném `RNFNAM01` sidecaru.
- Seznamy Data, Training, Research, Models a Live Forecast zobrazují jméno jako
  primární údaj a zkrácené ID jako technický údaj.

## Trash a recovery

- Dependency preview vrací blokátory, rozsah a velikost.
- Výchozí delete nekaskáduje; explicitní cascade respektuje aktivní práci a
  aktivní/validované modely.
- Odstranění nejprve přesune vlastněné soubory pod app-local `trash/files`.
- Bounded manifest `RNFTRS01` v3 používá SHA-256 a transakční stavy.
- Restore validuje soubory a znovu skládá katalogové vazby.
- Pending remove/restore se po restartu bezpečně rekonciluje.
- Pending purge se vrací do koše; nezačne sám obnovovat živá data.
- Permanent purge a Empty trash vyžadují explicitní potvrzení.
- Mutace chrání browser session a přesný Origin; konflikty vracejí HTTP 409 se
  strukturovanými závislostmi.

## Testovací pokrytí ověřené pro balík

- CUDA Release: 49/49 CTest testů.
- no-CUDA Release: 31/31 CTest testů.
- Numerické parity a finite-difference gradient checks.
- Poškozené/truncated formáty, bounds a SHA-256.
- Restart/persistence, cancellation a souběhy.
- API session/Origin, WebSocket, JavaScript syntax a runtime smoke.
- Display-name kolize, legacy metadata, dependency blocking, cascade, restore,
  purge a simulované přerušené trash transakce.

Počty odpovídají lokální validační matici bezprostředně před commitem 0.8.2.
