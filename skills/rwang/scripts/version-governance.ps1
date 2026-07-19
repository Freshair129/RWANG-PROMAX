[CmdletBinding()]
param(
    [ValidateSet('audit','register','bump','fix')][string]$Action = 'audit',
    [string]$Root = '.',
    [string]$Path,
    [ValidateSet('major','minor','patch')][string]$Kind = 'patch',
    [string]$Reason,
    [string]$Ref
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath $Root).Path
$registryPath = Join-Path $repo '.rwang/registry.json'

function Relative([string]$value) {
    $full = if ([IO.Path]::IsPathRooted($value)) { [IO.Path]::GetFullPath($value) } else { [IO.Path]::GetFullPath((Join-Path $repo $value)) }
    $baseUri = New-Object Uri(([IO.Path]::GetFullPath($repo).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar))
    $pathUri = New-Object Uri($full)
    return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace('\','/')
}
function GlobRegex([string]$glob) {
    $escaped = [Regex]::Escape($glob.Replace('\','/'))
    $escaped = $escaped.Replace('\*\*','.*').Replace('\*','[^/]*').Replace('\?','.')
    return '^' + $escaped + '$'
}
function InScope([string]$relative, $registry) {
    $included = @($registry.governed_scope.include | Where-Object { $relative -match (GlobRegex $_) }).Count -gt 0
    $excluded = @($registry.governed_scope.exclude | Where-Object { $relative -match (GlobRegex $_) }).Count -gt 0
    return $included -and -not $excluded
}
function SaveJson([string]$target, $value) {
    $parent = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    $value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $target -Encoding utf8
}
function AppendEvent([string]$type, $details) {
    if (-not (Test-Path -LiteralPath (Join-Path $repo 'state/PROJECT_STATE.json'))) { return }
    $event = [ordered]@{ type=$type; at=[DateTimeOffset]::Now.ToString('o'); details=$details } | ConvertTo-Json -Compress -Depth 10
    Add-Content -LiteralPath (Join-Path $repo 'state/events.jsonl') -Value $event -Encoding utf8
}
function LoadRegistry([bool]$create) {
    if (-not (Test-Path -LiteralPath $registryPath)) {
        if (-not $create) { throw "Missing registry: $registryPath" }
        $template = Join-Path $PSScriptRoot '../templates/registry.json'
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $registryPath) | Out-Null
        Copy-Item -LiteralPath $template -Destination $registryPath
    }
    $r = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
    if ($null -eq $r.governed_scope -or @($r.governed_scope.include).Count -eq 0) { throw 'registry.json must declare a non-empty governed_scope.include.' }
    return $r
}
function MetaPath([string]$relative) { return Join-Path $repo ('.rwang/meta/' + $relative + '.json') }
function NextVersion([string]$version, [string]$kind) {
    if ($version -notmatch '^(\d+)\.(\d+)\.(\d+)(?:-[0-9A-Za-z.-]+)?$') { throw "Invalid SemVer: $version" }
    $major=[int]$Matches[1]; $minor=[int]$Matches[2]; $patch=[int]$Matches[3]
    switch ($kind) {
        major { return "$($major+1).0.0" }
        minor { return "$major.$($minor+1).0" }
        patch { return "$major.$minor.$($patch+1)" }
    }
}
function Audit($registry) {
    $findings = [Collections.Generic.List[object]]::new()
    $indexed = @{}
    foreach ($item in @($registry.items)) { $indexed[[string]$item.path] = $item }

    $allFiles = Get-ChildItem -LiteralPath $repo -Recurse -File -Force | Where-Object {
        $rel = Relative $_.FullName
        $rel -notmatch '(^|/)(\.git|\.rwang)(/|$)'
    }
    foreach ($file in $allFiles) {
        $rel = Relative $file.FullName
        if ((InScope $rel $registry) -and -not $indexed.ContainsKey($rel)) {
            $findings.Add([pscustomobject]@{ severity='drift'; kind='unregistered'; path=$rel; fix="RWANG:version register $rel" })
        }
    }
    foreach ($item in @($registry.items)) {
        $rel = [string]$item.path
        $original = Join-Path $repo $rel
        $metaPath = MetaPath $rel
        if (-not (InScope $rel $registry)) { $findings.Add([pscustomobject]@{severity='violation';kind='out_of_scope';path=$rel;fix='change scope explicitly or remove registration'}) }
        if (-not (Test-Path -LiteralPath $original)) { $findings.Add([pscustomobject]@{severity='violation';kind='orphan_original';path=$rel;fix='restore artifact or deprecate registration'}); continue }
        if (-not (Test-Path -LiteralPath $metaPath)) { $findings.Add([pscustomobject]@{severity='violation';kind='missing_sidecar';path=$rel;fix='restore sidecar from history'}); continue }
        $meta = Get-Content -LiteralPath $metaPath -Raw | ConvertFrom-Json
        $actual = (Get-FileHash -LiteralPath $original -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actual -ne $meta.sha256) { $findings.Add([pscustomobject]@{severity='violation';kind='unbumped_edit';path=$rel;fix="RWANG:version bump $rel <kind> <reason>"}) }
        if ($item.version -ne $meta.version -or $item.status -ne $meta.status -or $item.id -ne $meta.id) { $findings.Add([pscustomobject]@{severity='drift';kind='index_drift';path=$rel;fix='RWANG:version fix'}) }
        if ([string]$meta.version -notmatch '^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$') { $findings.Add([pscustomobject]@{severity='violation';kind='invalid_semver';path=$rel;fix='owner-directed metadata correction'}) }
    }
    [pscustomobject]@{
        action = 'audit'; governed_scope = $registry.governed_scope; registered = @($registry.items).Count
        clean = ($findings.Count -eq 0); findings = $findings
    }
}

$registry = LoadRegistry ($Action -eq 'register')
switch ($Action) {
    audit {
        $result = Audit $registry
        $result | ConvertTo-Json -Depth 10
        if (-not $result.clean) { exit 2 }
    }
    register {
        if (-not $Path) { throw 'register requires -Path.' }
        $rel = Relative $Path
        $original = Join-Path $repo $rel
        if (-not (Test-Path -LiteralPath $original -PathType Leaf)) { throw "Artifact not found: $rel" }
        if (-not (InScope $rel $registry)) { throw "Artifact is outside governed_scope: $rel" }
        if (@($registry.items | Where-Object path -eq $rel).Count -gt 0) { throw "Already registered: $rel" }
        $ids = @($registry.items | ForEach-Object { if ($_.id -match '^DOC-(\d+)$') { [int]$Matches[1] } })
        $next = if ($ids.Count) { ($ids | Measure-Object -Maximum).Maximum + 1 } else { 1 }
        $id = 'DOC-{0:D4}' -f $next
        $now = [DateTimeOffset]::Now.ToString('o')
        $hash = (Get-FileHash -LiteralPath $original -Algorithm SHA256).Hash.ToLowerInvariant()
        $meta = [ordered]@{
            id=$id; points_to=$rel; type='doc'; version='0.1.0'; status='draft'; superseded_by=$null; sha256=$hash
            relations=[ordered]@{depends_on=@();referenced_by=@()}; attributes=[ordered]@{}; created_at=$now; updated_at=$now
            changelog=@([ordered]@{version='0.1.0';date=$now;kind='register';change='initial registration';ref=$Ref;agent='rwang';commit=$null})
        }
        SaveJson (MetaPath $rel) $meta
        $registry.items = @($registry.items) + @([pscustomobject]@{id=$id;path=$rel;version='0.1.0';status='draft'})
        SaveJson $registryPath $registry
        AppendEvent 'VersionRegister' ([ordered]@{path=$rel;id=$id;version='0.1.0';ref=$Ref})
        [pscustomobject]@{action='register';path=$rel;id=$id;version='0.1.0';sha256=$hash} | ConvertTo-Json
    }
    bump {
        if (-not $Path -or -not $Reason) { throw 'bump requires -Path and -Reason.' }
        $rel = Relative $Path
        $item = @($registry.items | Where-Object path -eq $rel)
        if ($item.Count -ne 1) { throw "Expected one registration for: $rel" }
        $metaPath = MetaPath $rel
        $meta = Get-Content -LiteralPath $metaPath -Raw | ConvertFrom-Json
        if ($Kind -eq 'major' -and $meta.status -in @('beta','stable')) {
            if (-not $Ref) { throw 'Frozen major bump requires -Ref to an approved architecture change request.' }
            $refPath = Join-Path $repo $Ref
            if (-not (Test-Path -LiteralPath $refPath) -or -not (Select-String -LiteralPath $refPath -Pattern 'Approval status:\s*approved' -Quiet)) { throw 'Change request is missing or not marked approved.' }
        }
        $newVersion = NextVersion ([string]$meta.version) $Kind
        $now = [DateTimeOffset]::Now.ToString('o')
        $meta.version = $newVersion; $meta.updated_at = $now
        $meta.sha256 = (Get-FileHash -LiteralPath (Join-Path $repo $rel) -Algorithm SHA256).Hash.ToLowerInvariant()
        $entry = [pscustomobject]@{version=$newVersion;date=$now;kind=$Kind;change=$Reason;ref=$Ref;agent='rwang';commit=$null}
        $meta.changelog = @($entry) + @($meta.changelog)
        SaveJson $metaPath $meta
        $item[0].version = $newVersion; $item[0].status = $meta.status
        SaveJson $registryPath $registry
        AppendEvent 'VersionBump' ([ordered]@{path=$rel;version=$newVersion;kind=$Kind;reason=$Reason;ref=$Ref})
        [pscustomobject]@{action='bump';path=$rel;version=$newVersion;sha256=$meta.sha256} | ConvertTo-Json
    }
    fix {
        $changes = @()
        foreach ($item in @($registry.items)) {
            $metaPath = MetaPath ([string]$item.path)
            if (-not (Test-Path -LiteralPath $metaPath)) { continue }
            $meta = Get-Content -LiteralPath $metaPath -Raw | ConvertFrom-Json
            if ($item.id -ne $meta.id -or $item.version -ne $meta.version -or $item.status -ne $meta.status) {
                $changes += [pscustomobject]@{path=$item.path;from="$($item.id)/$($item.version)/$($item.status)";to="$($meta.id)/$($meta.version)/$($meta.status)"}
                $item.id=$meta.id; $item.version=$meta.version; $item.status=$meta.status
            }
        }
        if ($changes.Count -gt 0) {
            SaveJson $registryPath $registry
            AppendEvent 'VersionFix' ([ordered]@{index_corrections=$changes})
        }
        $post = Audit $registry
        [pscustomobject]@{action='fix';index_corrections=$changes;unresolved=@($post.findings | Where-Object kind -ne 'index_drift')} | ConvertTo-Json -Depth 10
    }
}
