[CmdletBinding()]
param([string]$Root)

$ErrorActionPreference = 'Stop'
$scriptPath = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $PSCommandPath }
$scriptDirectory = Split-Path -Parent $scriptPath
if (-not $Root) { $Root = Split-Path -Parent $scriptDirectory }
$repo = (Resolve-Path -LiteralPath $Root).Path
$errors = [Collections.Generic.List[string]]::new()
$allowed = @('rwang','rwang-review','rwang-optimize')
$skillRoot = Join-Path $repo 'skills'
$actual = @(Get-ChildItem -LiteralPath $skillRoot -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') } | ForEach-Object Name | Sort-Object)

function RepoRelative([string]$path) {
    $baseUri = New-Object Uri(([IO.Path]::GetFullPath($repo).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar))
    $pathUri = New-Object Uri([IO.Path]::GetFullPath($path))
    return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace('/','\')
}

if ($actual.Count -ne 3 -or (Compare-Object $allowed $actual)) {
    $errors.Add("Public skill set must be exactly: $($allowed -join ', '). Found: $($actual -join ', ')")
}

$required = @(
    'docs/ARCHITECTURE--RWANG-SKILL-CONSOLIDATION.md',
    'skills/rwang/SKILL.md','skills/rwang/references/CORE.md','skills/rwang/references/LIFECYCLE.md',
    'skills/rwang/references/GENESIS-BLOCK-CYCLE.md','skills/rwang/references/CODEBASE-SCAN.md','skills/rwang/references/VERSION-GOVERNANCE.md',
    'skills/rwang/references/LEGACY-ALIASES.md','skills/rwang/scripts/scan-codebase.ps1',
    'skills/rwang/scripts/migrate-state.ps1','skills/rwang/scripts/version-governance.ps1',
    'skills/rwang/scripts/pre-commit','scripts/test-functional.ps1','scripts/test-installers.ps1','scripts/test-installers.sh','scripts/test-pre-commit.sh',
    'skills/rwang-review/SKILL.md','skills/rwang-review/RWANG-REVIEW.md',
    'skills/rwang-review/templates/REVIEW.md','skills/rwang-optimize/SKILL.md','skills/rwang-optimize/RWANG-OPTIMIZE.md'
)
foreach ($rel in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $repo $rel))) { $errors.Add("Missing required reference: $rel") }
}

$markdownFiles = Get-ChildItem -LiteralPath $skillRoot -Recurse -File -Filter '*.md'
foreach ($file in $markdownFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $matches = [Regex]::Matches($content, '`((?:references|templates|scripts)/[^`<>*]+)`')
    foreach ($match in $matches) {
        $ref = $match.Groups[1].Value.Replace('/', [IO.Path]::DirectorySeparatorChar)
        $withinSkills = $file.FullName.Substring($skillRoot.Length).TrimStart('\','/')
        $skillName = $withinSkills.Split(@('\','/'))[0]
        $candidate = Join-Path (Join-Path $skillRoot $skillName) $ref
        if (-not (Test-Path -LiteralPath $candidate)) {
            $relativeFile = RepoRelative $file.FullName
            $errors.Add("Missing inline reference from $relativeFile -> $($match.Groups[1].Value)")
        }
    }
}

$hashes = @{}
foreach ($file in $markdownFiles) {
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    if (-not $hashes.ContainsKey($hash)) { $hashes[$hash] = @() }
    $hashes[$hash] += RepoRelative $file.FullName
}
foreach ($entry in $hashes.GetEnumerator()) {
    if ($entry.Value.Count -gt 1) { $errors.Add("Duplicate bundled module payload: $($entry.Value -join ', ')") }
}

$cycleSpec = Get-Content -LiteralPath (Join-Path $repo 'skills/rwang/references/GENESIS-BLOCK-CYCLE.md') -Raw
$scanSpec = Get-Content -LiteralPath (Join-Path $repo 'skills/rwang/references/CODEBASE-SCAN.md') -Raw
$lifecycleSpec = Get-Content -LiteralPath (Join-Path $repo 'skills/rwang/references/LIFECYCLE.md') -Raw
$canonicalStages = @('Scan','Structure','Specialized Parse: Markdown','Specialized Parse: COBOL','Symbolic Parse (Tree-sitter)','Framework: Routes','Framework: Tools','Framework: ORM','Cross-File Resolution','MRO','Communities (Leiden)','Processes')
foreach ($stage in $canonicalStages) { if (-not $cycleSpec.Contains($stage)) { $errors.Add("Genesis Block Cycle SSOT is missing canonical L2 stage: $stage") } }
foreach ($phase in 0..6) { if (-not $cycleSpec.Contains("P$phase")) { $errors.Add("Genesis Block Cycle SSOT is missing canonical Assembly phase: P$phase") } }
foreach ($consumer in @(@('CODEBASE-SCAN.md',$scanSpec),@('LIFECYCLE.md',$lifecycleSpec))) {
    if (-not $consumer[1].Contains('references/GENESIS-BLOCK-CYCLE.md')) { $errors.Add("$($consumer[0]) must reference the Genesis Block Cycle SSOT") }
}
if ($scanSpec -match '(?m)^\s*1\.\s+\*\*Scan\*\*') { $errors.Add('CODEBASE-SCAN.md must not duplicate the canonical 12-stage list.') }

$registryTemplate = Get-Content -LiteralPath (Join-Path $repo 'skills/rwang/templates/registry.json') -Raw | ConvertFrom-Json
if (@($registryTemplate.governed_scope.include | Where-Object { $_ -match '^src(/|\\)' }).Count -gt 0) {
    $errors.Add('Registry template must not govern src/** implicitly.')
}

foreach ($installer in @('install.ps1','install.sh','rwang-init.ps1','rwang-init.sh')) {
    $text = Get-Content -LiteralPath (Join-Path $repo $installer) -Raw
    foreach ($name in $allowed) { if (-not $text.Contains($name)) { $errors.Add("$installer does not explicitly install $name") } }
}
$installerPs = Get-Content -LiteralPath (Join-Path $repo 'install.ps1') -Raw
$installerSh = Get-Content -LiteralPath (Join-Path $repo 'install.sh') -Raw
$initPs = Get-Content -LiteralPath (Join-Path $repo 'rwang-init.ps1') -Raw
$initSh = Get-Content -LiteralPath (Join-Path $repo 'rwang-init.sh') -Raw
if (-not $installerPs.Contains('$skillNames = @("rwang", "rwang-review", "rwang-optimize")')) { $errors.Add('install.ps1 public allowlist is not exact.') }
if (-not $installerSh.Contains('skill_names="rwang rwang-review rwang-optimize"')) { $errors.Add('install.sh public allowlist is not exact.') }
if (-not $initPs.Contains('foreach ($name in @("rwang", "rwang-review", "rwang-optimize"))')) { $errors.Add('rwang-init.ps1 public allowlist is not exact.') }
if (-not $initSh.Contains('for name in rwang rwang-review rwang-optimize; do')) { $errors.Add('rwang-init.sh public allowlist is not exact.') }
if ($installerPs -match 'Get-ChildItem[^\r\n]+\$src[^\r\n]+-Directory' -or $installerSh.Contains('"$src"/*/')) {
    $errors.Add('Installer must not discover public skills through a directory wildcard.')
}

$hook = Get-Content -LiteralPath (Join-Path $repo 'skills/rwang/scripts/pre-commit') -Raw
if (-not $hook.StartsWith('#!/usr/bin/env bash') -or -not $hook.Contains('diff --cached --name-only --diff-filter=ACMRD -z') -or -not $hook.Contains("while IFS= read -r -d ''")) {
    $errors.Add('Pre-commit hook must retain Bash/NUL-safe staged-path handling and deletion inspection.')
}

$architecture = Get-Content -LiteralPath (Join-Path $repo 'docs/ARCHITECTURE--RWANG-SKILL-CONSOLIDATION.md') -Raw
$readme = Get-Content -LiteralPath (Join-Path $repo 'README.md') -Raw
foreach ($term in @('rwang','rwang-review','rwang-optimize','Reality-before-planning architecture','Version-governance architecture','Installation and distribution architecture','Rejected alternatives','Acceptance criteria')) {
    if (-not $architecture.Contains($term)) { $errors.Add("Architecture SSOT is missing required section/term: $term") }
}
if (-not $readme.Contains('docs/ARCHITECTURE--RWANG-SKILL-CONSOLIDATION.md')) { $errors.Add('README must link the architecture SSOT.') }

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output 'PASS: exactly 3 public skills'
Write-Output 'PASS: all required and inline references resolve'
Write-Output 'PASS: no duplicate Markdown module payloads'
Write-Output 'PASS: canonical 12-stage vocabulary present'
Write-Output 'PASS: canonical 7-phase Assembly vocabulary present'
Write-Output 'PASS: scan and lifecycle references consume the combined SSOT'
Write-Output 'PASS: governed scope excludes implicit source registration'
Write-Output 'PASS: installers use the 3-skill allowlist'
Write-Output 'PASS: installer allowlists are exact and non-wildcard'
Write-Output 'PASS: pre-commit retains NUL-safe staged-path handling'
Write-Output 'PASS: consolidated architecture SSOT is present and linked'
