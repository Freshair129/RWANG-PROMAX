# Install RWANG into a project so ANY agent (Codex, Cursor, Claude, local LLM) can use it.
# Usage: .\rwang-init.ps1 C:\path\to\your\project   (defaults to current directory)
param([string]$Target = ".")
$here = $PSScriptRoot
New-Item -ItemType Directory -Force -Path $Target | Out-Null

foreach ($f in @("RWANG-MASTERPLAN.md","RWANG-CORE.md","RWANG-REVIEW.md","RWANG-OPTIMIZE.md","RWANG-VERSION.md")) {
    $dst = Join-Path $Target $f
    if (Test-Path $dst) { Write-Host "keep   $f (already present)" }
    else { Copy-Item (Join-Path $here $f) $dst; Write-Host "add    $f" }
}
foreach ($p in @("AGENTS.md","CLAUDE.md")) {
    $dst = Join-Path $Target $p
    if (Test-Path $dst) { Write-Host "keep   $p (already present)" }
    else { Copy-Item (Join-Path $here "templates\$p") $dst; Write-Host "add    $p" }
}

# install the RWANG write gate (pre-commit hook) if the target is a git repo
$gitDir = Join-Path $Target ".git"
if (Test-Path $gitDir) {
    $hook = Join-Path $gitDir "hooks\pre-commit"
    if (Test-Path $hook) { Write-Host "keep   .git/hooks/pre-commit (already exists - merge gate/pre-commit manually)" }
    else {
        New-Item -ItemType Directory -Force -Path (Join-Path $gitDir "hooks") | Out-Null
        Copy-Item (Join-Path $here "gate\pre-commit") $hook
        Write-Host "add    .git/hooks/pre-commit (RWANG write gate)"
    }
} else {
    Write-Host "note   not a git repo - write gate not installed (run 'git init' then re-run to enable it)"
}

Write-Host ""
Write-Host "RWANG installed into: $Target"
Write-Host "Put your project spec/notes in $Target\project\ then tell your agent: RWANG:MasterPlan"
