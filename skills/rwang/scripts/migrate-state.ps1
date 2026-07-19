[CmdletBinding(SupportsShouldProcess = $true)]
param([Parameter(Mandatory = $true)][string]$Root)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath $Root).Path
$statePath = Join-Path $repo 'state/PROJECT_STATE.json'
if (-not (Test-Path -LiteralPath $statePath)) { throw "Missing $statePath" }
$state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
if ($null -ne $state.current_design_gate -or $null -ne $state.gate_status) { throw 'State already uses the 2.x schema or mixes old and new fields.' }
if ($null -eq $state.current_phase -or $null -eq $state.phase_status) { throw 'State does not contain the complete 1.x field set.' }
$phase = [int]$state.current_phase
if ($phase -lt 0 -or $phase -gt 7) { throw "Unsupported current_phase: $phase" }

$migrationDir = Join-Path $repo 'state/migrations'
$backupPath = Join-Path $migrationDir 'PROJECT_STATE.v1.json'
if (Test-Path -LiteralPath $backupPath) { throw "Backup already exists: $backupPath" }
$sourceHash = (Get-FileHash -LiteralPath $statePath -Algorithm SHA256).Hash.ToLowerInvariant()
$gate = if ($phase -eq 7) { 'Execution' } else { "DG$phase" }
$approved = @($state.approved_phases | ForEach-Object { if ([int]$_ -le 6) { "DG$([int]$_)" } })
$newState = [ordered]@{
    project = $state.project
    repository_kind = if ($state.repository_kind) { $state.repository_kind } else { 'unknown' }
    current_design_gate = $gate
    gate_status = [string]$state.phase_status
    master_plan_status = if ($state.master_plan_status) { [string]$state.master_plan_status } else { 'not_started' }
    approved_design_gates = $approved
    scan_evidence = if ($state.scan_evidence) { $state.scan_evidence } else { $null }
    schema_version = '2.0.0'
    migrated_from_sha256 = $sourceHash
    updated_at = [DateTimeOffset]::Now.ToString('o')
}

if ($PSCmdlet.ShouldProcess($statePath, 'Migrate RWANG 1.x state to 2.0.0')) {
    New-Item -ItemType Directory -Force -Path $migrationDir | Out-Null
    Copy-Item -LiteralPath $statePath -Destination $backupPath
    $newState | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $statePath -Encoding utf8
    $event = [ordered]@{
        type = 'StateMigrated'; from_schema = '1.x'; to_schema = '2.0.0'; source_sha256 = $sourceHash
        mapping = [ordered]@{ current_phase = 'current_design_gate'; phase_status = 'gate_status'; master_plan_status = 'master_plan_status'; approved_phases = 'approved_design_gates' }
        preserved_review_pattern = 'docs/PHASE_<N>_REVIEW.md'; at = [DateTimeOffset]::Now.ToString('o')
    } | ConvertTo-Json -Compress -Depth 6
    Add-Content -LiteralPath (Join-Path $repo 'state/events.jsonl') -Value $event -Encoding utf8
}

$newState | ConvertTo-Json -Depth 10
