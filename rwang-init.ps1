# Install RWANG into a project so ANY agent (Codex, Cursor, Claude, local LLM) can use it.
# Usage: .\rwang-init.ps1 C:\path\to\your\project   (defaults to current directory)
param([string]$Target = ".")
$here = $PSScriptRoot
New-Item -ItemType Directory -Force -Path $Target | Out-Null

foreach ($f in @("RWANG-MASTERPLAN.md","RWANG-REVIEW.md","RWANG-OPTIMIZE.md")) {
    $dst = Join-Path $Target $f
    if (Test-Path $dst) { Write-Host "keep   $f (already present)" }
    else { Copy-Item (Join-Path $here $f) $dst; Write-Host "add    $f" }
}
foreach ($p in @("AGENTS.md","CLAUDE.md")) {
    $dst = Join-Path $Target $p
    if (Test-Path $dst) { Write-Host "keep   $p (already present)" }
    else { Copy-Item (Join-Path $here "templates\$p") $dst; Write-Host "add    $p" }
}

Write-Host ""
Write-Host "RWANG installed into: $Target"
Write-Host "Put your project spec/notes in $Target\project\ then tell your agent: RWANG:MasterPlan"
