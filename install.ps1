# RWANG one-command installer (Windows)
# Usage (one line, no clone needed):
#   iwr -useb https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.ps1 | iex
# Or from a local clone:  powershell -ExecutionPolicy Bypass -File install.ps1
#
# What it does:
#   1. Puts the toolkit at ~\.rwang (RWANG's global home — like ~\.claude)
#   2. Registers the skill family for every harness on this machine:
#      Claude Code (~\.claude\skills), Codex CLI (~\.agents\skills),
#      Antigravity CLI (~\.gemini\antigravity-cli\skills, if ~\.gemini exists)
# That's it — no per-project step: the skill sets a project up by itself on first use.

$rwangHome = Join-Path $HOME ".rwang"

if (-not (Test-Path (Join-Path $rwangHome "skills"))) {
    if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "skills"))) {
        # running from a local clone -> copy it to ~\.rwang
        New-Item -ItemType Directory -Force -Path $rwangHome | Out-Null
        Get-ChildItem $PSScriptRoot -Force | Where-Object { $_.Name -ne ".git" } |
            Copy-Item -Destination $rwangHome -Recurse -Force
    } else {
        # running via iwr|iex -> fetch the toolkit
        git clone --depth 1 https://github.com/Freshair129/RWANG-PROMAX.git $rwangHome
        if (-not (Test-Path (Join-Path $rwangHome "skills"))) { Write-Host "clone failed - install git or clone manually"; exit 1 }
    }
} else {
    try { git -C $rwangHome pull -q 2>$null } catch {}   # refresh silently if it's a git clone
}
Write-Host "toolkit home -> $rwangHome"

$src = Join-Path $rwangHome "skills"
function Install-To([string]$dest, [string]$label) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Get-ChildItem -Path $src -Directory | ForEach-Object {
        $t = Join-Path $dest $_.Name
        New-Item -ItemType Directory -Force -Path $t | Out-Null
        Copy-Item -Path (Join-Path $_.FullName "*") -Destination $t -Force
    }
    Write-Host "installed -> $label  ($dest)"
}

Install-To (Join-Path $HOME ".claude\skills") "Claude Code"
Install-To (Join-Path $HOME ".agents\skills") "Codex CLI (agents standard)"
if (Test-Path (Join-Path $HOME ".gemini")) {
    Install-To (Join-Path $HOME ".gemini\antigravity-cli\skills") "Antigravity CLI"
} else {
    Write-Host "skip      Antigravity CLI (no ~\.gemini on this machine)"
}

Write-Host ""
Write-Host "Done. Open any project and type:  RWANG:MasterPlan   (Codex: `$rwang-masterplan, Antigravity: /skills)"
Write-Host "The skill installs RWANG into that project by itself on first run."
