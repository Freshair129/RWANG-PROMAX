[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$bundleRoot = Split-Path -Parent $PSScriptRoot
$scanScript = Join-Path $bundleRoot 'skills/rwang/scripts/scan-codebase.ps1'
$migrationScript = Join-Path $bundleRoot 'skills/rwang/scripts/migrate-state.ps1'
$versionScript = Join-Path $bundleRoot 'skills/rwang/scripts/version-governance.ps1'
$validatorScript = Join-Path $bundleRoot 'scripts/validate-bundle.ps1'
$tempBase = [IO.Path]::GetTempPath()
$fixture = Join-Path $tempBase ('rwang-functional-' + [Guid]::NewGuid().ToString('N'))

function Resolve-PowerShellEngine {
    $current = (Get-Process -Id $PID).Path
    if ($current -and (Test-Path -LiteralPath $current)) { return $current }
    foreach ($name in @('pwsh','powershell')) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }
    throw 'No PowerShell engine found.'
}

$engine = Resolve-PowerShellEngine

function Invoke-JsonScript([string]$script, [string[]]$arguments, [int]$expectedExit = 0) {
    $output = & $engine -NoProfile -File $script @arguments
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne $expectedExit) {
        throw "Expected exit $expectedExit from $script, got $exitCode. Output: $output"
    }
    return ($output | Out-String | ConvertFrom-Json)
}

try {
    $validatorOutput = & $engine -NoProfile -File $validatorScript
    if ($LASTEXITCODE -ne 0 -or -not (($validatorOutput | Out-String).Contains('PASS: exactly 3 public skills'))) {
        throw 'Direct validator invocation without -Root failed.'
    }
    New-Item -ItemType Directory -Path $fixture -Force | Out-Null
    foreach ($relative in @('src','tests','state','docs/specs','node_modules/noise')) {
        New-Item -ItemType Directory -Path (Join-Path $fixture $relative) -Force | Out-Null
    }
    '{"name":"fixture","scripts":{"test":"echo ok"}}' | Set-Content -LiteralPath (Join-Path $fixture 'package.json') -Encoding utf8
    'export const main = () => 1;' | Set-Content -LiteralPath (Join-Path $fixture 'src/main.ts') -Encoding utf8
    'test("main", () => {});' | Set-Content -LiteralPath (Join-Path $fixture 'tests/main.test.ts') -Encoding utf8
    'export const noise = true;' | Set-Content -LiteralPath (Join-Path $fixture 'node_modules/noise/ignored.ts') -Encoding utf8
    '# Fixture Spec' | Set-Content -LiteralPath (Join-Path $fixture 'docs/specs/SPEC.md') -Encoding utf8
    '{"project":"fixture","current_phase":0,"phase_status":"in_progress","master_plan_status":"awaiting_approval","approved_phases":[],"updated_at":"2026-07-19T00:00:00+07:00"}' |
        Set-Content -LiteralPath (Join-Path $fixture 'state/PROJECT_STATE.json') -Encoding utf8

    & git -C $fixture init -q
    & git -C $fixture config user.email 'rwang-test@example.invalid'
    & git -C $fixture config user.name 'RWANG Test'
    $unbornScan = Invoke-JsonScript $scanScript @('-Root',$fixture,'-Profile','L1')
    $unbornSnapshot = Get-Content -LiteralPath $unbornScan.snapshot -Raw | ConvertFrom-Json
    if ($null -ne $unbornSnapshot.git.head) { throw 'Unborn Git repository must record a null HEAD without surfacing native stderr.' }
    & git -C $fixture add -- package.json src tests docs state
    & git -C $fixture commit -q -m fixture
    $expectedHead = (& git -C $fixture rev-parse HEAD).Trim()

    $scan = Invoke-JsonScript $scanScript @('-Root',$fixture,'-Profile','L1')
    if ($scan.repository_kind -ne 'brownfield' -or $scan.planning_gate_satisfied -ne $false) {
        throw 'Brownfield scan must remain blocked pending agent validation.'
    }
    $snapshot = Get-Content -LiteralPath $scan.snapshot -Raw | ConvertFrom-Json
    $reality = Get-Content -LiteralPath $scan.reality_document -Raw
    $expectedHashLine = '- **Snapshot SHA-256:** `' + $scan.snapshot_sha256 + '`'
    $expectedHeadLine = '- **Git HEAD:** `' + $expectedHead + '`'
    if (-not $reality.Contains($expectedHashLine) -or -not $reality.Contains($expectedHeadLine) -or $reality.Contains('$hash') -or $reality.Contains('$gitHead')) {
        throw 'Reality Markdown did not interpolate the snapshot hash and Git HEAD exactly.'
    }
    if ($snapshot.counts.source_files -ne 2 -or ($snapshot.representative_source -join ',') -match 'node_modules') {
        throw 'Ignored node_modules content leaked into the scan inventory.'
    }

    $migrated = Invoke-JsonScript $migrationScript @('-Root',$fixture)
    if ($migrated.current_design_gate -ne 'DG0' -or $migrated.master_plan_status -ne 'awaiting_approval') {
        throw 'State migration did not preserve the Master Plan sub-gate.'
    }
    if (-not (Test-Path -LiteralPath (Join-Path $fixture 'state/migrations/PROJECT_STATE.v1.json'))) {
        throw 'State migration backup is missing.'
    }

    $registered = Invoke-JsonScript $versionScript @('-Action','register','-Root',$fixture,'-Path','docs/specs/SPEC.md')
    if ($registered.version -ne '0.1.0') { throw 'Initial governed-artifact version must be 0.1.0.' }
    $auditClean = Invoke-JsonScript $versionScript @('-Action','audit','-Root',$fixture)
    if (-not $auditClean.clean) { throw 'Initial version audit should be clean.' }

    Add-Content -LiteralPath (Join-Path $fixture 'docs/specs/SPEC.md') -Value 'change'
    $auditDrift = Invoke-JsonScript $versionScript @('-Action','audit','-Root',$fixture) 2
    if ($auditDrift.clean -or @($auditDrift.findings | Where-Object kind -eq 'unbumped_edit').Count -ne 1) {
        throw 'Version audit did not detect the unbumped edit.'
    }

    $bumped = Invoke-JsonScript $versionScript @('-Action','bump','-Root',$fixture,'-Path','docs/specs/SPEC.md','-Kind','patch','-Reason','fixture change')
    if ($bumped.version -ne '0.1.1') { throw 'Patch bump should produce 0.1.1.' }
    $metaPath = Join-Path $fixture '.rwang/meta/docs/specs/SPEC.md.json'
    $registryPath = Join-Path $fixture '.rwang/registry.json'
    $meta = Get-Content -LiteralPath $metaPath -Raw | ConvertFrom-Json
    $registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
    $meta.version = '0.1.1-beta'
    $registry.items[0].version = '0.1.1-beta'
    $meta | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $metaPath -Encoding utf8
    $registry | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $registryPath -Encoding utf8
    $prereleaseBump = Invoke-JsonScript $versionScript @('-Action','bump','-Root',$fixture,'-Path','docs/specs/SPEC.md','-Kind','patch','-Reason','promote prerelease')
    if ($prereleaseBump.version -ne '0.1.2') { throw 'Patch bump must increment the numeric core and remove a prerelease suffix.' }
    $auditAfter = Invoke-JsonScript $versionScript @('-Action','audit','-Root',$fixture)
    if (-not $auditAfter.clean) { throw 'Post-bump version audit should be clean.' }

    Write-Output "PASS: functional tests use current PowerShell engine ($engine)"
    Write-Output 'PASS: validator direct invocation resolves its default root'
    Write-Output 'PASS: unborn Git repository scan suppresses native stderr safely'
    Write-Output 'PASS: brownfield scan is evidence-gated and interpolates hash/Git HEAD'
    Write-Output 'PASS: ignored node_modules subtree is pruned'
    Write-Output 'PASS: state migration preserves the Master Plan sub-gate and backup'
    Write-Output 'PASS: governed-artifact audit, drift, normal bump, and prerelease bump'
}
finally {
    if (Test-Path -LiteralPath $fixture) {
        $resolved = (Resolve-Path -LiteralPath $fixture).Path
        $safePrefix = [IO.Path]::GetFullPath($tempBase).TrimEnd('\') + '\'
        if (-not $resolved.StartsWith($safePrefix, [StringComparison]::OrdinalIgnoreCase) -or (Split-Path -Leaf $resolved) -notlike 'rwang-functional-*') {
            throw "Refusing unsafe fixture cleanup: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
