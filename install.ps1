# Install the RWANG:MasterPlan skill for Claude Code (all projects on this machine).
$src = Join-Path $PSScriptRoot "skills\rwang-masterplan"
$dest = Join-Path $HOME ".claude\skills\rwang-masterplan"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Path (Join-Path $src "*") -Destination $dest -Force
Write-Host "Installed RWANG:MasterPlan skill to $dest"
Write-Host "Open any project in Claude Code and type: RWANG:MasterPlan"
