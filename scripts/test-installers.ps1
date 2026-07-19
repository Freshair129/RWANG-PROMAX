[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$bundleRoot = Split-Path -Parent $PSScriptRoot
$tempBase = [IO.Path]::GetTempPath()
$fixture = Join-Path $tempBase ('rwang-installer-' + [Guid]::NewGuid().ToString('N'))
$project = Join-Path $fixture 'project'

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

function Quote-ProcessArgument([string]$value) {
    return '"' + $value.Replace('"','\"') + '"'
}

function Invoke-Isolated([string]$script, [string[]]$arguments = @(), [int]$expectedExit = 0) {
    $info = New-Object Diagnostics.ProcessStartInfo
    $info.FileName = $engine
    $allArguments = @('-NoProfile','-File',$script) + $arguments
    $info.Arguments = ($allArguments | ForEach-Object { Quote-ProcessArgument $_ }) -join ' '
    $info.UseShellExecute = $false
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.EnvironmentVariables['USERPROFILE'] = $fixture
    $info.EnvironmentVariables['HOME'] = $fixture
    $process = [Diagnostics.Process]::Start($info)
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    if ($process.ExitCode -ne $expectedExit) { throw "Expected exit $expectedExit, got $($process.ExitCode): $stdout $stderr" }
    return [pscustomobject]@{ ExitCode=$process.ExitCode; Stdout=$stdout; Stderr=$stderr }
}

try {
    New-Item -ItemType Directory -Path (Join-Path $fixture '.agents/skills/rwang-core'),(Join-Path $fixture '.agents/skills/rwang') -Force | Out-Null
    'legacy' | Set-Content -LiteralPath (Join-Path $fixture '.agents/skills/rwang-core/marker.txt')
    'stale' | Set-Content -LiteralPath (Join-Path $fixture '.agents/skills/rwang/stale.txt')

    [void](Invoke-Isolated (Join-Path $bundleRoot 'install.ps1'))
    $installedRoot = Join-Path $fixture '.agents/skills'
    $installed = @(Get-ChildItem -LiteralPath $installedRoot -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') })
    if (@($installed).Count -ne 3) { throw "Expected exactly three installed skills; found $(@($installed).Count)." }
    foreach ($name in @('rwang','rwang-review','rwang-optimize')) {
        if (-not (Test-Path -LiteralPath (Join-Path $installedRoot "$name/SKILL.md"))) { throw "Missing installed skill: $name" }
    }
    if (Test-Path -LiteralPath (Join-Path $installedRoot 'rwang/stale.txt')) { throw 'Upgrade left a stale file in the umbrella skill.' }
    if (Test-Path -LiteralPath (Join-Path $installedRoot 'rwang-core')) { throw 'Retired skill remains installed.' }

    'stale toolkit' | Set-Content -LiteralPath (Join-Path $fixture '.rwang/skills/rwang/SKILL.md')
    'stale installed' | Set-Content -LiteralPath (Join-Path $installedRoot 'rwang/second-stale.txt')
    [void](Invoke-Isolated (Join-Path $bundleRoot 'install.ps1'))
    $sourceSkill = Get-Content -LiteralPath (Join-Path $bundleRoot 'skills/rwang/SKILL.md') -Raw
    $refreshedToolkit = Get-Content -LiteralPath (Join-Path $fixture '.rwang/skills/rwang/SKILL.md') -Raw
    if ($refreshedToolkit -ne $sourceSkill) { throw 'Local-clone rerun did not refresh the toolkit SSOT.' }
    if (Test-Path -LiteralPath (Join-Path $installedRoot 'rwang/second-stale.txt')) { throw 'Local-clone rerun left stale installed skill content.' }
    $backedUpLegacy = @(Get-ChildItem -LiteralPath (Join-Path $fixture '.rwang/legacy-backups') -Recurse -File -Filter marker.txt)
    $backedUpStale = @(Get-ChildItem -LiteralPath (Join-Path $fixture '.rwang/legacy-backups') -Recurse -File -Filter stale.txt)
    $backedUpSecond = @(Get-ChildItem -LiteralPath (Join-Path $fixture '.rwang/legacy-backups') -Recurse -File -Filter second-stale.txt)
    if ($backedUpLegacy.Count -ne 1 -or $backedUpStale.Count -ne 1 -or $backedUpSecond.Count -ne 1) {
        throw 'Installer did not recoverably back up replaced or retired skill payloads.'
    }

    [void](Invoke-Isolated (Join-Path $bundleRoot 'rwang-init.ps1') @($project))
    [void](Invoke-Isolated (Join-Path $bundleRoot 'rwang-init.ps1') @($project))
    foreach ($name in @('rwang','rwang-review','rwang-optimize')) {
        $item = Get-Item -LiteralPath (Join-Path $project ".agents/skills/$name") -Force
        if (-not $item.LinkType) { throw "Project skill is not linked to global SSOT: $name" }
        $actualTarget = [IO.Path]::GetFullPath([string]@($item.Target)[0])
        $expectedTarget = [IO.Path]::GetFullPath((Join-Path $installedRoot $name))
        if ($actualTarget -ne $expectedTarget) { throw "Wrong project link target for ${name}: $actualTarget" }
    }

    $refusalProject = Join-Path $fixture 'refusal-project'
    $realLocalSkill = Join-Path $refusalProject '.agents/skills/rwang'
    New-Item -ItemType Directory -Path $realLocalSkill -Force | Out-Null
    'keep me' | Set-Content -LiteralPath (Join-Path $realLocalSkill 'marker.txt')
    [void](Invoke-Isolated (Join-Path $bundleRoot 'rwang-init.ps1') @($refusalProject) 1)
    if ((Get-Content -LiteralPath (Join-Path $realLocalSkill 'marker.txt') -Raw).Trim() -ne 'keep me') {
        throw 'Project init changed a real project-local skill copy after refusing it.'
    }

    Write-Output "PASS: installer tests use current PowerShell engine ($engine)"
    Write-Output 'PASS: isolated Windows install keeps exactly three clean public skills'
    Write-Output 'PASS: local-clone rerun refreshes toolkit and installed SSOT'
    Write-Output 'PASS: replaced and retired payloads are recoverably backed up'
    Write-Output 'PASS: project init link targets and idempotency'
    Write-Output 'PASS: project init refuses and preserves a real local skill copy'
}
finally {
    if (Test-Path -LiteralPath $fixture) {
        $resolved = (Resolve-Path -LiteralPath $fixture).Path
        $safePrefix = [IO.Path]::GetFullPath($tempBase).TrimEnd('\') + '\'
        if (-not $resolved.StartsWith($safePrefix, [StringComparison]::OrdinalIgnoreCase) -or (Split-Path -Leaf $resolved) -notlike 'rwang-installer-*') {
            throw "Refusing unsafe fixture cleanup: $resolved"
        }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
