[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Root,
    [ValidateSet('L0','L1','L2')][string]$Profile = 'L1'
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath $Root).Path
$ignored = '(^|/)(\.git|\.rwang|node_modules|vendor|dist|build|coverage|\.next|\.cache|__pycache__)(/|$)'
$sourceExtensions = @('.c','.cc','.cpp','.cs','.go','.java','.js','.jsx','.kt','.kts','.php','.py','.rb','.rs','.swift','.ts','.tsx','.vue','.svelte','.cob','.cbl')
$manifestNames = @('package.json','pnpm-workspace.yaml','yarn.lock','package-lock.json','pyproject.toml','requirements.txt','Cargo.toml','go.mod','pom.xml','build.gradle','build.gradle.kts','*.sln','*.csproj','Dockerfile','docker-compose.yml','docker-compose.yaml')

function Relative([string]$path) {
    $baseUri = New-Object Uri(([IO.Path]::GetFullPath($repo).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar))
    $pathUri = New-Object Uri([IO.Path]::GetFullPath($path))
    return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString()).Replace('\','/')
}

function Get-ScannableFiles([string]$root) {
    $pending = [Collections.Generic.Queue[string]]::new()
    $result = [Collections.Generic.List[IO.FileInfo]]::new()
    $pending.Enqueue($root)
    while ($pending.Count -gt 0) {
        $directory = $pending.Dequeue()
        foreach ($item in Get-ChildItem -LiteralPath $directory -Force -ErrorAction SilentlyContinue) {
            $relative = Relative $item.FullName
            if ($relative -match $ignored) { continue }
            if ($item.PSIsContainer) { $pending.Enqueue($item.FullName) }
            else { $result.Add($item) }
        }
    }
    return $result
}

function Invoke-Git([string[]]$Arguments) {
    $startInfo = New-Object Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'git'
    $startInfo.WorkingDirectory = $repo
    $startInfo.Arguments = ($Arguments | ForEach-Object {
        if ($_ -match '[\s"]') { '"' + $_.Replace('"','\"') + '"' } else { $_ }
    }) -join ' '
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    try {
        $process = New-Object Diagnostics.Process
        $process.StartInfo = $startInfo
        [void]$process.Start()
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        return [pscustomobject]@{ ExitCode=$process.ExitCode; Stdout=$stdout.TrimEnd(); Stderr=$stderr.TrimEnd() }
    } catch {
        return [pscustomobject]@{ ExitCode=127; Stdout=''; Stderr=$_.Exception.Message }
    }
}

$files = @(Get-ScannableFiles $repo)
$manifests = $files | Where-Object {
    $name = $_.Name
    @($manifestNames | Where-Object { $name -like $_ }).Count -gt 0
}
$sources = $files | Where-Object { $sourceExtensions -contains $_.Extension.ToLowerInvariant() }
$tests = $files | Where-Object { (Relative $_.FullName) -match '(^|/)(test|tests|spec|specs)(/|$)|\.(test|spec)\.' }
$automation = $files | Where-Object { (Relative $_.FullName) -match '(^|/)(\.github/workflows|\.gitlab-ci|azure-pipelines|scripts)(/|$)' }
$ownerMaterials = $files | Where-Object {
    $rel = Relative $_.FullName
    $rel -notmatch '/' -and $_.Extension -in @('.md','.txt','.pdf','.doc','.docx')
}
$kind = if ($sources.Count -gt 0 -or $manifests.Count -gt 0) { 'brownfield' } else { 'greenfield' }

$gitHead = $null
$gitStatus = @()
if (Test-Path -LiteralPath (Join-Path $repo '.git')) {
    $headResult = Invoke-Git @('rev-parse','HEAD')
    if ($headResult.ExitCode -eq 0) { $gitHead = $headResult.Stdout }
    $statusResult = Invoke-Git @('status','--short')
    if ($statusResult.ExitCode -eq 0 -and $statusResult.Stdout) { $gitStatus = @($statusResult.Stdout -split "`r?`n") }
}

$stageNames = @(
    'Scan','Structure','Specialized Parse: Markdown','Specialized Parse: COBOL',
    'Symbolic Parse (Tree-sitter)','Framework: Routes','Framework: Tools','Framework: ORM',
    'Cross-File Resolution','MRO','Communities (Leiden)','Processes'
)
$stages = @()
if ($Profile -eq 'L2') {
    for ($i = 0; $i -lt $stageNames.Count; $i++) {
        $stages += [ordered]@{
            stage = $i + 1
            name = $stageNames[$i]
            status = if ($i -lt 2) { 'evidence_prepared' } else { 'pending_agent_validation' }
            method = if ($i -eq 0) { 'filesystem inventory' } elseif ($i -eq 1) { 'relative-path hierarchy' } else { $null }
            exclusions = @()
            confidence = if ($i -lt 2) { 'high' } else { 'unknown' }
        }
    }
}

$snapshot = [ordered]@{
    schema_version = '2.0.0'
    generated_at = [DateTimeOffset]::Now.ToString('o')
    root = $repo
    repository_kind = $kind
    profile = $Profile
    l1_status = if ($kind -eq 'brownfield' -and $Profile -in @('L1','L2')) { 'evidence_packet_pending_agent_validation' } elseif ($kind -eq 'greenfield') { 'not_applicable' } else { 'not_requested' }
    l2_status = if ($Profile -eq 'L2') { 'evidence_packet_not_complete_decomposition' } else { 'not_requested' }
    git = [ordered]@{ head = $gitHead; status = $gitStatus }
    exclusions = @('.git','.rwang','node_modules','vendor','dist','build','coverage','.next','.cache','__pycache__')
    counts = [ordered]@{ files = $files.Count; source_files = $sources.Count; manifests = $manifests.Count; tests = $tests.Count; automation = $automation.Count }
    top_level = @(Get-ChildItem -LiteralPath $repo -Force | ForEach-Object { $_.Name } | Sort-Object)
    owner_materials = @($ownerMaterials | ForEach-Object { Relative $_.FullName } | Sort-Object)
    manifests = @($manifests | ForEach-Object { Relative $_.FullName } | Sort-Object)
    source_roots = @($sources | ForEach-Object { (Relative $_.FullName).Split('/')[0] } | Sort-Object -Unique)
    representative_source = @($sources | Select-Object -First 40 | ForEach-Object { Relative $_.FullName })
    tests = @($tests | Select-Object -First 100 | ForEach-Object { Relative $_.FullName })
    automation = @($automation | Select-Object -First 100 | ForEach-Object { Relative $_.FullName })
    l2_stages = $stages
}

$evidenceDir = Join-Path $repo '.rwang/evidence'
$docsDir = Join-Path $repo 'docs/discovery'
New-Item -ItemType Directory -Force -Path $evidenceDir,$docsDir | Out-Null
$snapshotPath = Join-Path $evidenceDir 'codebase-snapshot.json'
$snapshot | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $snapshotPath -Encoding utf8
$hash = (Get-FileHash -LiteralPath $snapshotPath -Algorithm SHA256).Hash.ToLowerInvariant()

$realityPath = Join-Path $docsDir 'CODEBASE_REALITY.md'
$l2Note = if ($Profile -eq 'L2') { 'L2 is not complete until all 12 canonical stages are validated and pending statuses are resolved.' } else { 'L2 was not requested.' }
$gitHeadDisplay = if ([string]::IsNullOrWhiteSpace([string]$gitHead)) { '(no commit)' } else { [string]$gitHead }
$markdown = @'
# CODEBASE_REALITY

- **Repository kind:** {0}
- **Scan profile:** {1}
- **Snapshot:** `.rwang/evidence/codebase-snapshot.json`
- **Snapshot SHA-256:** `{2}`
- **Git HEAD:** `{3}`
- **Generated:** {4}

## Deterministic inventory

- Files: {5}
- Source files: {6}
- Manifests: {7}
- Tests: {8}
- Automation files: {9}

## Confirmed code truth

Agent must inspect representative implementations and record evidence here.

## Documentation drift

Agent must compare documented intent with code truth here.

## Unknowns and confidence limits

{10}
'@ -f $kind,$Profile,$hash,$gitHeadDisplay,$snapshot.generated_at,$files.Count,$sources.Count,$manifests.Count,$tests.Count,$automation.Count,$l2Note
$markdown | Set-Content -LiteralPath $realityPath -Encoding utf8

[pscustomobject]@{
    repository_kind = $kind
    profile = $Profile
    snapshot = $snapshotPath
    snapshot_sha256 = $hash
    reality_document = $realityPath
    planning_gate_satisfied = ($kind -eq 'greenfield')
    planning_gate_blocker = if ($kind -eq 'brownfield') { 'Complete and validate Confirmed code truth, Documentation drift, unknowns, and L2 stages when requested before planning.' } else { $null }
} | ConvertTo-Json -Depth 4
