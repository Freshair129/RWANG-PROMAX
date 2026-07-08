# RWANG one-command installer (Windows)
# Usage:  iwr -useb https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.ps1 | iex
#         (or from a local clone:  powershell -ExecutionPolicy Bypass -File install.ps1)
#
# Design: SINGLE SOURCE OF TRUTH.
#   1. Toolkit lands at ~\.rwang
#   2. Skills are copied ONCE into ~\.agents\skills  (the cross-tool standard = SSOT)
#   3. Claude Code and Antigravity get junctions pointing at the SSOT — one copy, every harness.
#      Codex reads ~\.agents\skills natively, no link needed.

$rwangHome = Join-Path $HOME ".rwang"

if (-not (Test-Path (Join-Path $rwangHome "skills"))) {
    if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "skills"))) {
        New-Item -ItemType Directory -Force -Path $rwangHome | Out-Null
        Get-ChildItem $PSScriptRoot -Force | Where-Object { $_.Name -ne ".git" } |
            Copy-Item -Destination $rwangHome -Recurse -Force
    } else {
        git clone --depth 1 https://github.com/Freshair129/RWANG-PROMAX.git $rwangHome
        if (-not (Test-Path (Join-Path $rwangHome "skills"))) { Write-Host "clone failed - install git or clone manually"; exit 1 }
    }
} else {
    try { git -C $rwangHome pull -q 2>$null } catch {}
}
Write-Host "toolkit home -> $rwangHome"

# 1) SSOT: copy skills into ~\.agents\skills
$src  = Join-Path $rwangHome "skills"
$ssot = Join-Path $HOME ".agents\skills"
New-Item -ItemType Directory -Force -Path $ssot | Out-Null
Get-ChildItem -Path $src -Directory | ForEach-Object {
    $t = Join-Path $ssot $_.Name
    New-Item -ItemType Directory -Force -Path $t | Out-Null
    Copy-Item -Path (Join-Path $_.FullName "*") -Destination $t -Recurse -Force
}
Write-Host "SSOT      -> $ssot  (Codex reads this natively)"

# 2) Junctions for the other harnesses -> SSOT
function Link-Harness([string]$harnessSkills, [string]$label) {
    New-Item -ItemType Directory -Force -Path $harnessSkills | Out-Null
    Get-ChildItem -Path $src -Directory | ForEach-Object {
        $link   = Join-Path $harnessSkills $_.Name
        $target = Join-Path $ssot $_.Name
        if (Test-Path $link) {
            $item = Get-Item $link -Force
            if ($item.LinkType) { cmd /c rmdir "$link" | Out-Null }          # remove old link only
            else { Remove-Item $link -Recurse -Force }                        # replace old real copy
        }
        try { New-Item -ItemType Junction -Path $link -Target $target | Out-Null }
        catch { Copy-Item $target $harnessSkills -Recurse -Force }            # fallback: plain copy
    }
    Write-Host "linked    -> $label  ($harnessSkills -> SSOT)"
}

Link-Harness (Join-Path $HOME ".claude\skills") "Claude Code"
if (Test-Path (Join-Path $HOME ".gemini")) {
    Link-Harness (Join-Path $HOME ".gemini\antigravity-cli\skills") "Antigravity CLI"
} else {
    Write-Host "skip      Antigravity CLI (no ~\.gemini on this machine)"
}

Write-Host ""
Write-Host "Done. Open any project and type:  RWANG:QuickStart"
Write-Host "(Claude: /rwang-quickstart, Codex: `$rwang-quickstart, Antigravity: /skills)"
