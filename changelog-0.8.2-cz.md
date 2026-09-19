# Remind Neural Forecaster 0.8.2

## Přehled vydání

Verze 0.8.2 zpřehledňuje práci s větším počtem dataset snapshotů a experimentů
a přidává obnovitelné mazání s kontrolou závislostí. Numerika trénování,
FeatureSchema, modelové hashe a inference protokol se nemění.

## Lidsky čitelné názvy

- Snapshoty a experimenty mají samostatné `displayName`.
- Výchozí jméno snapshotu používá symbol, timeframe a UTC čas.
- Výchozí jméno experimentu přidává architekturu LSTM, GRU nebo RNN.
- Povoleno je 1–96 ASCII písmen, číslic, mezer, podtržítek, pomlček a teček.
- Kolize jsou deterministicky řešeny suffixy `_2`, `_3` a dalšími.
- Vlastní název je možné zadat před vytvořením v UI i API.
- Interní ID, fingerprinty, hashe a názvy binárních souborů zůstávají beze změny.

## Katalogy a zpětná kompatibilita

- Data, Training, Research, Models a Live Forecast zobrazují primárně název a
  sekundárně zkrácené technické ID.
- Starší snapshot nebo experiment bez jména získá odvozené jméno při načtení.
- Immutable snapshot payload se kvůli názvu nepřepisuje; metadata jsou v
  checksummovaném atomickém sidecaru.
- Legacy experiment metadata a snapshot v1 zůstávají čitelná v hranicích
  dokumentované způsobilosti.

## Dependency-aware Trash

- Nové preview před smazáním ukáže typ, jméno, velikost, závislosti, blokátory a
  přesný rozsah operace.
- Výchozí mazání není kaskádové.
- Explicitní cascade může zahrnout neaktivní závislé artefakty.
- Aktivní training/evaluation/cancelling job a aktivní nebo validating model
  operaci vždy blokují.
- Smazané soubory se nejprve transakčně přesunou do app-local koše.
- Restore znovu načte a ověří katalogové vazby.
- Permanent Purge a Empty trash vyžadují samostatné dvojí potvrzení v UI.
- Změny katalogu se přes WebSocket promítnou do všech otevřených stránek.

## Recovery a integrita

- `RNFTRS01` manifest používá explicitní verzi, limity a SHA-256.
- Start aplikace rekonciluje rozpracovaný remove nebo restore.
- Přerušený purge se vrací do koše a nezpůsobí nečekanou aktivaci dat.
- Poškozené cesty, ID, checksum, rozsahy nebo neočekávané soubory zastaví
  bezpečné načtení místo pokračování s nejasným stavem.
- Katalogové reference brání souběžnému smazání během snapshotu, registrace
  modelu nebo navazující operace.

## UI a API

- Nový app-local Trash panel s akcemi Restore a Delete permanently.
- Delete dialog zobrazuje dependency preview a explicitní volbu cascade.
- Browserové DELETE/restore/purge mutace používají stávající session a Origin
  ochranu.
- Konflikty závislostí vracejí HTTP 409 se strukturovaným seznamem.
- Nová WebSocket událost `catalog.changed` aktualizuje otevřené pracovní plochy.

## Ověření

- CUDA Release: 49/49 testů.
- no-CUDA Release: 31/31 testů.
- Dodatečné cílené testy ověřily striktní potvrzovací JSON, collision recovery,
  souběžné reference, restore rollback a přerušený purge.
- `git diff --check`, JavaScript syntax a runtime smoke prošly.

## Hranice verze

0.8.2 nepřidává obchodování, automatickou aktivaci modelu, CSV import, nový
FeatureSchema ani novou training numeriku. Instalátor, podpis a distribuční
hardening zůstávají úkolem milníku 9.

