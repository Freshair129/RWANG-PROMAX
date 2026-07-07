# Install the RWANG: skill family for Claude Code (all projects on this machine).
$src = Join-Path $PSScriptRoot "skills"
$dest = Join-Path $HOME ".claude\skills"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Get-ChildItem -Path $src -Directory | ForEach-Object {
    $target = Join-Path $dest $_.Name
    New-Item -ItemType Directory -Force -Path $target | Out-Null
    Copy-Item -Path (Join-Path $_.FullName "*") -Destination $target -Force
    Write-Host "Installed $($_.Name)"
}
Write-Host ""
Write-Host "Done. Open any project in Claude Code and type: RWANG:MasterPlan, RWANG:Review, or RWANG:Optimize"
