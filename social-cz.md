# Social copy — Czech

## LinkedIn / delší oznámení

Remind Neural Forecaster 0.8.2 přináší čitelnější a bezpečnější práci s
výzkumnými artefakty.

Snapshoty a experimenty mají nově vlastní lidsky čitelné názvy, zatímco jejich
interní ID, fingerprinty a hashe zůstávají beze změny. Katalog před smazáním
ukáže závislosti a přesný rozsah operace. Výchozí delete nekaskáduje, aktivní
práce a modely zůstávají chráněné a odstraněná data nejprve míří do lokálního
koše s možností Restore. Permanent Purge je samostatně potvrzovaná operace.

Aplikace zůstává lokální: jeden Windows EXE, server pouze na
`127.0.0.1:7470`, vložené webové UI, MT5 Dataset Store, kauzální snapshoty,
CUDA LSTM/GRU/RNN trénování, out-of-sample evaluace, Model Registry a
informativní live forecast bez obchodních příkazů.

0.8.2 bylo ověřeno v CUDA i no-CUDA Release variantě. Jde o výzkumný nástroj;
výstupy nejsou investiční doporučení a negarantují přesnost ani ziskovost.

## X / krátká verze

Remind Neural Forecaster 0.8.2: čitelné názvy snapshotů a experimentů,
dependency preview, lokální Trash, Restore, potvrzený Permanent Purge a restart
recovery. Jeden loopback-only Windows EXE, CUDA i no-CUDA build. Bez
automatického obchodování.

## MQL5 komunita

Verze 0.8.2 desktopového Remind Neural Forecasteru zpřehledňuje celý lokální
výzkumný workflow navázaný na EA_Forecaster. EA dál posílá pouze uzavřené bary
z `OnTimer`, provádí backfill/reconnect a může kreslit ověřený High/Low/Midpoint
forecast. Neprovádí neuronové výpočty ani obchodní operace.

Novinkou jsou editovatelné názvy dataset snapshotů a experimentů a bezpečný
katalogový Trash. Smazání nejdřív zobrazí závislosti; snapshot používaný
experimentem nebo experiment s registrovaným modelem nelze omylem odstranit.
Restore znovu ověří metadata a permanentní purge vyžaduje další potvrzení.

Forecaster běží výhradně na `127.0.0.1:7470`. MT5 WebRequest zůstává
synchronní, URL musí uživatel povolit a ve Strategy Testeru není dostupný.

## Doporučené captiony

- „Lokální CUDA stav, capability a runtime v jednom přehledu.“
- „Čitelné názvy experimentů, technické ID stále po ruce.“
- „Nejdřív závislosti, potom koš. Permanentní odstranění až po potvrzení.“
- „Out-of-sample metriky z nejlepšího validačního checkpointu.“
- „Živý forecast je informativní a nikdy automaticky neobchoduje.“

## Hashtagy

`#CUDA #CPlusPlus #MQL5 #MetaTrader5 #TimeSeries #MachineLearning #LocalFirst`

