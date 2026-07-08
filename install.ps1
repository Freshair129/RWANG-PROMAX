# Install the RWANG: skill family into every agent harness on this machine.
# Targets: Claude Code (~\.claude\skills), Codex CLI (~\.agents\skills),
#          Antigravity CLI (~\.gemini\antigravity-cli\skills - only if ~\.gemini exists)
$src = Join-Path $PSScriptRoot "skills"

function Install-To([string]$dest, [string]$label) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Get-ChildItem -Path $src -Directory | ForEach-Object {
        $target = Join-Path $dest $_.Name
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Copy-Item -Path (Join-Path $_.FullName "*") -Destination $target -Force
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
Write-Host "Invoke:  Claude Code: RWANG:MasterPlan   Codex: `$rwang-masterplan   Antigravity: /skills"
Write-Host "Restart the CLI if a skill does not appear."
