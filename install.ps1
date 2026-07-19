# RWANG one-command installer (Windows)
# Usage:  iwr -useb https://raw.githubusercontent.com/Freshair129/RWANG-PROMAX/main/install.ps1 | iex
#         (or from a local clone:  powershell -ExecutionPolicy Bypass -File install.ps1)
#
# Design: SINGLE SOURCE OF TRUTH.
#   1. Toolkit lands at ~\.rwang
#   2. Skills are refreshed into ~\.agents\skills on each successful install (the cross-tool SSOT)
#   3. Claude Code and Antigravity get junctions pointing at the SSOT — one copy, every harness.
#      Codex reads ~\.agents\skills natively, no link needed.

$rwangHome = Join-Path $HOME ".rwang"
$localSource = if ($PSScriptRoot -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot "skills"))) { [IO.Path]::GetFullPath($PSScriptRoot) } else { $null }
$toolkitBackupStamp = Get-Date -Format "yyyyMMdd-HHmmssfff"

if ($localSource -and ([IO.Path]::GetFullPath($rwangHome).TrimEnd('\') -ne $localSource.TrimEnd('\'))) {
    New-Item -ItemType Directory -Force -Path $rwangHome | Out-Null
    $toolkitBackup = Join-Path $rwangHome "toolkit-backups\$toolkitBackupStamp"
    foreach ($directoryName in @("skills","templates","scripts","docs")) {
        $sourceDirectory = Join-Path $localSource $directoryName
        if (-not (Test-Path -LiteralPath $sourceDirectory)) { continue }
        $destinationDirectory = Join-Path $rwangHome $directoryName
        if (Test-Path -LiteralPath $destinationDirectory) {
            New-Item -ItemType Directory -Force -Path $toolkitBackup | Out-Null
            Move-Item -LiteralPath $destinationDirectory -Destination (Join-Path $toolkitBackup $directoryName)
        }
        Copy-Item -LiteralPath $sourceDirectory -Destination $destinationDirectory -Recurse
    }
    foreach ($fileName in @("README.md","LICENSE","install.ps1","install.sh","rwang-init.ps1","rwang-init.sh")) {
        $sourceFile = Join-Path $localSource $fileName
        if (Test-Path -LiteralPath $sourceFile) { Copy-Item -LiteralPath $sourceFile -Destination (Join-Path $rwangHome $fileName) -Force }
    }
    Write-Host "refresh   local toolkit -> $rwangHome"
} elseif (-not (Test-Path -LiteralPath (Join-Path $rwangHome "skills"))) {
    git clone --depth 1 https://github.com/Freshair129/RWANG-PROMAX.git $rwangHome
    if (-not (Test-Path -LiteralPath (Join-Path $rwangHome "skills"))) { Write-Host "clone failed - install git or clone manually"; exit 1 }
} elseif (-not $localSource) {
    if (-not (Test-Path -LiteralPath (Join-Path $rwangHome ".git"))) { throw "Cannot refresh stale toolkit without a local source or $rwangHome\.git" }
    & git -C $rwangHome pull --ff-only -q
    if ($LASTEXITCODE -ne 0) { throw "git pull failed for $rwangHome" }
}
Write-Host "toolkit home -> $rwangHome"

# 1) SSOT: install the three public skills only
$src  = Join-Path $rwangHome "skills"
$ssot = Join-Path $HOME ".agents\skills"
$skillNames = @("rwang", "rwang-review", "rwang-optimize")
$retiredSkillNames = @("rwang-core", "rwang-masterplan", "rwang-version", "rwang-quickstart")
$backupStamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $rwangHome "legacy-backups\$backupStamp"
function Retire-SkillPath([string]$path, [string]$label) {
    if (-not (Test-Path -LiteralPath $path)) { return }
    $item = Get-Item -LiteralPath $path -Force
    if ($item.LinkType) {
        if ($item.PSIsContainer) { cmd /c rmdir "$path" | Out-Null } else { Remove-Item -LiteralPath $path -Force }
        return
    }
    $destinationDir = Join-Path $backupRoot $label
    New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
    $destination = Join-Path $destinationDir $item.Name
    if (Test-Path -LiteralPath $destination) { throw "Backup collision: $destination" }
    Move-Item -LiteralPath $path -Destination $destination
    Write-Host "backup    $path -> $destination"
}
New-Item -ItemType Directory -Force -Path $ssot | Out-Null
foreach ($name in $skillNames) {
    $sourceSkill = Join-Path $src $name
    if (-not (Test-Path -LiteralPath (Join-Path $sourceSkill "SKILL.md"))) { throw "Missing required skill: $sourceSkill" }
    $t = Join-Path $ssot $name
    if (Test-Path -LiteralPath $t) { Retire-SkillPath $t "agents-skills" }
    New-Item -ItemType Directory -Force -Path $t | Out-Null
    Copy-Item -Path (Join-Path $sourceSkill "*") -Destination $t -Recurse -Force
}
foreach ($name in $retiredSkillNames) {
    $old = Join-Path $ssot $name
    if (Test-Path -LiteralPath $old) {
        Retire-SkillPath $old "agents-skills"
        Write-Host "retire    $name (use RWANG:<command> through rwang)"
    }
}
Write-Host "SSOT      -> $ssot  (Codex reads this natively)"

# 2) Junctions for the other harnesses -> SSOT
function Link-Harness([string]$harnessSkills, [string]$label, [string]$backupLabel) {
    New-Item -ItemType Directory -Force -Path $harnessSkills | Out-Null
    foreach ($name in $skillNames) {
        $link   = Join-Path $harnessSkills $name
        $target = Join-Path $ssot $name
        if (Test-Path $link) {
            $item = Get-Item $link -Force
            if ($item.LinkType) { cmd /c rmdir "$link" | Out-Null }          # remove old link only
            else { Retire-SkillPath $link $backupLabel }                       # preserve old real copy
        }
        try { New-Item -ItemType Junction -Path $link -Target $target | Out-Null }
        catch {
            Write-Warning "Could not create junction for $label/$name; installing a duplicate fallback copy that will require future refresh. $($_.Exception.Message)"
            Copy-Item $target $harnessSkills -Recurse -Force
        }
    }
    foreach ($name in $retiredSkillNames) {
        $old = Join-Path $harnessSkills $name
        if (Test-Path -LiteralPath $old) { Retire-SkillPath $old $backupLabel }
    }
    Write-Host "linked    -> $label  ($harnessSkills -> SSOT)"
}

Link-Harness (Join-Path $HOME ".claude\skills") "Claude Code" "claude-skills"
if (Test-Path (Join-Path $HOME ".gemini")) {
    Link-Harness (Join-Path $HOME ".gemini\antigravity-cli\skills") "Antigravity CLI" "antigravity-skills"
} else {
    Write-Host "skip      Antigravity CLI (no ~\.gemini on this machine)"
}

Write-Host ""
Write-Host "Done. Open any project and type:  RWANG:init"
Write-Host "(Claude: /rwang, Codex: `$rwang, Antigravity: /skills)"
