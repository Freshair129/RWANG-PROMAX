# Link a project to globally installed RWANG skills without copying module payloads.
# Usage: .\rwang-init.ps1 C:\path\to\project
param([string]$Target = ".")
$here = $PSScriptRoot
$targetPath = [IO.Path]::GetFullPath($Target)
New-Item -ItemType Directory -Force -Path $targetPath | Out-Null

foreach ($pointer in @("AGENTS.md","CLAUDE.md")) {
    $destination = Join-Path $targetPath $pointer
    if (Test-Path -LiteralPath $destination) { Write-Host "keep   $pointer (already present)" }
    else { Copy-Item -LiteralPath (Join-Path $here "templates\$pointer") -Destination $destination; Write-Host "add    $pointer" }
}

$workspaceSkills = Join-Path $targetPath ".agents\skills"
$globalSkills = Join-Path $HOME ".agents\skills"
New-Item -ItemType Directory -Force -Path $workspaceSkills | Out-Null
foreach ($name in @("rwang", "rwang-review", "rwang-optimize")) {
    $sourceSkill = Join-Path $globalSkills $name
    if (-not (Test-Path -LiteralPath (Join-Path $sourceSkill "SKILL.md"))) {
        throw "Missing globally installed skill: $sourceSkill. Run install.ps1 first."
    }
    $link = Join-Path $workspaceSkills $name
    if (Test-Path -LiteralPath $link) {
        $item = Get-Item -LiteralPath $link -Force
        if (-not $item.LinkType) { throw "Refusing to overwrite project-local skill copy: $link" }
        $currentTarget = [IO.Path]::GetFullPath([string]@($item.Target)[0])
        if ($currentTarget -eq [IO.Path]::GetFullPath($sourceSkill)) {
            Write-Host "keep   .agents/skills/$name (correct link already present)"
            continue
        }
        cmd /c rmdir "$link" | Out-Null
        Write-Host "replace .agents/skills/$name (stale link target: $currentTarget)"
    }
    New-Item -ItemType Junction -Path $link -Target $sourceSkill | Out-Null
    Write-Host "link   .agents/skills/$name -> $sourceSkill"
}

$gitDir = Join-Path $targetPath ".git"
if (Test-Path -LiteralPath $gitDir) {
    $hook = Join-Path $gitDir "hooks\pre-commit"
    if (Test-Path -LiteralPath $hook) { Write-Host "keep   .git/hooks/pre-commit (merge the RWANG gate manually if needed)" }
    else {
        $hookSource = Join-Path $globalSkills "rwang\scripts\pre-commit"
        if (-not (Test-Path -LiteralPath $hookSource -PathType Leaf)) { throw "Missing pre-commit source: $hookSource" }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $hook) | Out-Null
        Copy-Item -LiteralPath $hookSource -Destination $hook
        Write-Host "add    .git/hooks/pre-commit (governed-artifact gate)"
    }
} else {
    Write-Host "note   not a git repo; write gate not installed"
}

Write-Host "RWANG linked into: $targetPath"
Write-Host "Put project materials at the root or in project/, then invoke RWANG:init"
