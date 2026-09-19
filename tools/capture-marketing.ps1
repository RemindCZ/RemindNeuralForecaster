param(
    [string]$Executable = (Join-Path $PSScriptRoot '..\..\build\Release\RemindNeuralForecaster.exe'),
    [string]$Edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
)

$ErrorActionPreference = 'Stop'
$baseUri = [Uri]'http://127.0.0.1:7470/'
$origin = 'http://127.0.0.1:7470'
$token = 'marketing-demo-token-not-for-production'
$instance = 'marketing-demo-instance'
$dataRoot = Join-Path ([IO.Path]::GetTempPath()) "RemindMarketing082-$PID"
$output = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\screenshots'))
$process = $null

function Test-LoopbackPort {
    $client = [Net.Sockets.TcpClient]::new()
    try {
        $task = $client.ConnectAsync('127.0.0.1', 7470)
        return $task.Wait(300) -and $client.Connected
    }
    catch { return $false }
    finally { $client.Dispose() }
}

function New-BarBatch([int64]$Start, [int]$Count) {
    $memory = [IO.MemoryStream]::new()
    $writer = [IO.BinaryWriter]::new($memory)
    try {
        $writer.Write([Text.Encoding]::ASCII.GetBytes('RNFBAR01'))
        $writer.Write([uint16]1); $writer.Write([uint16]32)
        $writer.Write([uint16]60); $writer.Write([uint16]0)
        $writer.Write([uint32]1); $writer.Write([uint32]$Count)
        $writer.Write([uint64](60 * $Count))
        $previous = 62000.0
        for ($index = 0; $index -lt $Count; $index++) {
            $center = 62000.0 + (4.5 * $index) + (600.0 * [Math]::Sin($index / 17.0)) + (80.0 * [Math]::Sin($index / 5.0))
            $open = $previous
            $close = $center + (45.0 * [Math]::Sin($index / 3.0))
            $high = [Math]::Max($open, $close) + 110.0 + (15.0 * [Math]::Abs([Math]::Sin($index)))
            $low = [Math]::Min($open, $close) - 105.0 - (12.0 * [Math]::Abs([Math]::Cos($index)))
            $writer.Write([int64]($Start + (3600 * $index)))
            $writer.Write([double]$open); $writer.Write([double]$high)
            $writer.Write([double]$low); $writer.Write([double]$close)
            $writer.Write([int64](1200 + ($index % 700)))
            $writer.Write([int32](18 + ($index % 7)))
            $writer.Write([int64](600 + ($index % 300)))
            $previous = $close
        }
        $writer.Flush()
        $signed = $memory.ToArray()
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $digest = $sha.ComputeHash($signed) } finally { $sha.Dispose() }
        $result = [byte[]]::new($signed.Length + $digest.Length)
        [Array]::Copy($signed, $result, $signed.Length)
        [Array]::Copy($digest, 0, $result, $signed.Length, $digest.Length)
        return ,$result
    }
    finally { $writer.Dispose(); $memory.Dispose() }
}

function Invoke-BrowserMutation([string]$Method, [string]$Path, $Body) {
    return Invoke-RestMethod -Method $Method -Uri ([Uri]::new($baseUri, $Path)) `
        -WebSession $script:session -Headers @{ Origin = $origin } `
        -ContentType 'application/json' -Body ($Body | ConvertTo-Json -Compress -Depth 8) -TimeoutSec 20
}

function New-Snapshot([string]$Name, [int]$Window, [int]$Horizon, [string]$StreamId) {
    $null = Invoke-BrowserMutation Post 'api/v1/data/snapshots' @{
        displayName = $Name; streamId = $StreamId; inputWindow = $Window
        horizon = $Horizon; trainBasisPoints = 7000
        validationBasisPoints = 1500; testBasisPoints = 1500
    }
    $deadline = [DateTime]::UtcNow.AddSeconds(60)
    do {
        Start-Sleep -Milliseconds 100
        $job = Invoke-RestMethod -Uri ([Uri]::new($baseUri, 'api/v1/data/snapshots/job')) -WebSession $script:session -TimeoutSec 5
        if ($job.state -eq 'failed') { throw "Snapshot failed: $($job.error.message)" }
    } while ($job.state -ne 'completed' -and [DateTime]::UtcNow -lt $deadline)
    if ($job.state -ne 'completed') { throw 'Snapshot creation timed out.' }
    return $job.snapshot
}

function New-Experiment([string]$Name, [string]$Fingerprint, [string]$Layer, [int]$Epochs, [int]$Seed) {
    $created = Invoke-BrowserMutation Post 'api/v1/training/jobs' @{
        displayName = $Name; snapshotFingerprint = $Fingerprint; layerType = $Layer
        layers = 1; hiddenSize = 16; batchSize = 64; epochs = $Epochs
        learningRate = 0.002; beta1 = 0.9; beta2 = 0.999
        epsilon = 0.00000001; weightDecay = 0.0001; dropout = 0.0
        gradientClipping = 1.0; seed = $Seed; earlyStoppingPatience = 8
        earlyStoppingMinDelta = 0.0
    }
    $deadline = [DateTime]::UtcNow.AddMinutes(3)
    do {
        Start-Sleep -Milliseconds 200
        $detail = Invoke-RestMethod -Uri ([Uri]::new($baseUri, "api/v1/training/experiments/$($created.id)")) -WebSession $script:session -TimeoutSec 5
        if ($detail.state -eq 'failed') { throw "Training failed: $($detail.error.message)" }
    } while ($detail.state -notin @('completed', 'early_stopped') -and [DateTime]::UtcNow -lt $deadline)
    if ($detail.state -notin @('completed', 'early_stopped')) { throw 'Training timed out.' }
    return $detail
}

try {
    if (Test-LoopbackPort) { throw 'Port 7470 is already occupied.' }
    if (-not (Test-Path -LiteralPath $Executable -PathType Leaf)) { throw "Executable not found: $Executable" }
    if (-not (Test-Path -LiteralPath $Edge -PathType Leaf)) { throw "Microsoft Edge not found: $Edge" }
    New-Item -ItemType Directory -Path $dataRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $output -Force | Out-Null
    $process = Start-Process -FilePath $Executable `
        -ArgumentList @('--no-browser', '--data-dir', $dataRoot, '--mt5-token', $token, '--log-level', 'warn') `
        -PassThru -WindowStyle Hidden

    $script:session = $null
    $deadline = [DateTime]::UtcNow.AddSeconds(30)
    do {
        Start-Sleep -Milliseconds 100
        try {
            $null = Invoke-WebRequest -Uri $baseUri -SessionVariable browserSession -UseBasicParsing -TimeoutSec 2
            $script:session = $browserSession
            $health = Invoke-RestMethod -Uri ([Uri]::new($baseUri, 'api/v1/health')) -WebSession $script:session -TimeoutSec 2
        }
        catch { $health = $null }
    } while (($null -eq $health -or $health.version -ne '0.8.2' -or $health.engine.generation -lt 1) -and [DateTime]::UtcNow -lt $deadline)
    if ($null -eq $health -or $health.version -ne '0.8.2') { throw 'Application 0.8.2 did not become ready.' }

    $mt5Headers = @{
        'X-Remind-Installation-Token' = $token
        'X-Remind-Instance-Id' = $instance
    }
    $connect = @{
        brokerServer = 'Remind Demo Feed'; brokerSymbol = 'BTCUSD'; timeframe = 'H1'
        timeframeSeconds = 3600; schemaVersion = 1; digits = 2; point = 0.01
        serverTimeOffsetSeconds = 0; instanceId = $instance
    } | ConvertTo-Json -Compress
    $stream = Invoke-RestMethod -Method Post -Uri ([Uri]::new($baseUri, 'api/v1/mt5/connect')) `
        -Headers $mt5Headers -ContentType 'application/json' -Body $connect -TimeoutSec 10
    $backfill = @{ instanceId = $instance; state = 'BACKFILL'; serverTimeOffsetSeconds = 0; lastClosedTimestamp = 0; lastForecastId = '' } | ConvertTo-Json -Compress
    $null = Invoke-RestMethod -Method Post -Uri ([Uri]::new($baseUri, "api/v1/mt5/streams/$($stream.streamId)/heartbeat")) `
        -Headers $mt5Headers -ContentType 'application/json' -Body $backfill -TimeoutSec 10

    $count = 1600
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $start = [int64]([Math]::Floor($now / 3600) * 3600 - (1700 * 3600))
    $accepted = 0
    for ($offset = 0; $offset -lt $count; $offset += 400) {
        $batchCount = [Math]::Min(400, $count - $offset)
        $batch = New-BarBatch ([int64]($start + (3600 * $offset))) $batchCount
        $ingest = Invoke-RestMethod -Method Post -Uri ([Uri]::new($baseUri, "api/v1/mt5/streams/$($stream.streamId)/bars")) `
            -Headers $mt5Headers -ContentType 'application/vnd.remind.mt5-bars-v1' -Body $batch -TimeoutSec 30
        if ($ingest.rejected -ne 0) { throw 'Demo bar ingest was incomplete.' }
        $accepted += $ingest.accepted
    }
    if ($accepted -ne $count) { throw 'Demo bar ingest was incomplete.' }
    $live = @{ instanceId = $instance; state = 'LIVE'; serverTimeOffsetSeconds = 0; lastClosedTimestamp = [int64]$ingest.lastTimestamp; lastForecastId = '' } | ConvertTo-Json -Compress
    $null = Invoke-RestMethod -Method Post -Uri ([Uri]::new($baseUri, "api/v1/mt5/streams/$($stream.streamId)/heartbeat")) `
        -Headers $mt5Headers -ContentType 'application/json' -Body $live -TimeoutSec 10

    $trainingSnapshot = New-Snapshot 'BTCUSD H1 Training Snapshot' 32 4 $stream.streamId
    $validationSnapshot = New-Snapshot 'Validation Snapshot' 24 3 $stream.streamId
    $primary = New-Experiment 'BTCUSD H1 Forecast' $trainingSnapshot.fingerprint 'LSTM' 24 20260914
    $secondary = New-Experiment 'Market Regime Experiment' $trainingSnapshot.fingerprint 'GRU' 12 20260915

    $model = Invoke-BrowserMutation Post 'api/v1/models/register' @{ experimentId = $primary.id }
    $null = Invoke-BrowserMutation Post "api/v1/models/$($model.id)/activate" @{}
    $deadline = [DateTime]::UtcNow.AddSeconds(30)
    do {
        Start-Sleep -Milliseconds 200
        $model = Invoke-RestMethod -Uri ([Uri]::new($baseUri, "api/v1/models/$($model.id)")) -WebSession $script:session -TimeoutSec 5
        if ($model.state -eq 'failed') { throw "Model activation failed: $($model.error.message)" }
    } while ($model.state -ne 'active' -and [DateTime]::UtcNow -lt $deadline)
    if ($model.state -ne 'active') { throw 'Model activation timed out.' }

    $nextBatch = New-BarBatch ([int64]($start + (3600 * $count))) 1
    $latestIngest = Invoke-RestMethod -Method Post -Uri ([Uri]::new($baseUri, "api/v1/mt5/streams/$($stream.streamId)/bars")) `
        -Headers $mt5Headers -ContentType 'application/vnd.remind.mt5-bars-v1' -Body $nextBatch -TimeoutSec 10
    $deadline = [DateTime]::UtcNow.AddSeconds(30)
    do {
        Start-Sleep -Milliseconds 200
        try { $forecast = Invoke-RestMethod -Uri ([Uri]::new($baseUri, "api/v1/forecasts/$($stream.streamId)/latest")) -WebSession $script:session -TimeoutSec 5 }
        catch { $forecast = $null }
    } while ($null -eq $forecast -and [DateTime]::UtcNow -lt $deadline)
    if ($null -eq $forecast) { throw 'Live forecast was not generated.' }

    $trash = Invoke-BrowserMutation Delete "api/v1/catalog/snapshots/$($validationSnapshot.fingerprint)" @{ cascade = $false }
    if (-not $trash.trashId) { throw 'Demo trash entry was not created.' }

    & node (Join-Path $PSScriptRoot 'capture-ui.mjs') $Edge $output
    if ($LASTEXITCODE -ne 0) { throw "Screenshot capture failed with exit code $LASTEXITCODE." }
    Get-ChildItem -LiteralPath $output -Filter '*.png' | Sort-Object Name | Select-Object Name,Length
}
finally {
    if ($null -ne $process -and -not $process.HasExited) {
        Stop-Process -Id $process.Id -Force
        $null = $process.WaitForExit(5000)
    }
    Start-Sleep -Milliseconds 250
    if (Test-Path -LiteralPath $dataRoot) { Remove-Item -LiteralPath $dataRoot -Recurse -Force }
    if (Test-LoopbackPort) { throw 'Port 7470 remained occupied after capture cleanup.' }
}
