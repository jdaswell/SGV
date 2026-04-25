#Requires -Version 5.1
<#
.SYNOPSIS
    BDM Machine Export — Step 2 of 3-step laptop migration workflow.
.DESCRIPTION
    Packages everything outside OneDrive into a single zip file tagged with
    the machine type (Desktop or Laptop) and a timestamp.
    Run on each source machine AFTER reviewing the inventory reports.
.PARAMETER MachineTag
    'Desktop', 'Laptop', or 'Auto' (default). Auto detects via battery presence.
.PARAMETER OutputPath
    Where to write the zip and log. Defaults to the Desktop.
.NOTES
    Run as the user whose data you want to migrate (not as Administrator).
#>

[CmdletBinding()]
param(
    [ValidateSet('Desktop', 'Laptop', 'Auto')]
    [string]$MachineTag = 'Auto',
    [string]$OutputPath = "$env:USERPROFILE\Desktop"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# ─── CONFIGURATION — edit these if your repo paths differ ────────────────────
$repoSearchPaths = @(
    $env:USERPROFILE,
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Projects",
    "$env:USERPROFILE\source\repos",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\dev",
    "C:\dev",
    "C:\repos",
    "C:\Projects",
    "C:\source\repos"
)
$repoSearchDepth = 3

$oneDrivePaths = @(
    "$env:USERPROFILE\OneDrive",
    "$env:USERPROFILE\OneDrive - *"
)
# ─────────────────────────────────────────────────────────────────────────────

# ── Auto-detect machine tag ───────────────────────────────────────────────────
if ($MachineTag -eq 'Auto') {
    $battery    = Get-WmiObject Win32_Battery -ErrorAction SilentlyContinue
    $MachineTag = if ($battery) { 'Laptop' } else { 'Desktop' }
    Write-Host "Auto-detected machine type: $MachineTag" -ForegroundColor Cyan
}

$timestamp   = Get-Date -Format 'yyyyMMdd_HHmmss'
$machineName = $env:COMPUTERNAME
$zipName     = "BDM_Export_${MachineTag}_${timestamp}.zip"
$zipPath     = Join-Path $OutputPath $zipName
$stagingDir  = Join-Path $env:TEMP "BDM_Export_Staging_$timestamp"
$logPath     = Join-Path $OutputPath "BDM_Export_${MachineTag}_${timestamp}_log.txt"

$log = [System.Collections.Generic.List[string]]::new()

function Log([string]$msg, [string]$color = 'White') {
    $ts   = Get-Date -Format 'HH:mm:ss'
    $line = "[$ts] $msg"
    $log.Add($line)
    Write-Host $line -ForegroundColor $color
}

function Get-OneDriveRoots {
    $roots = @()
    foreach ($p in $oneDrivePaths) {
        $roots += (Resolve-Path $p -ErrorAction SilentlyContinue |
                   Select-Object -ExpandProperty Path)
    }
    return $roots
}

function Is-InOneDrive([string]$path, [string[]]$roots) {
    foreach ($r in $roots) { if ($path -like "$r*") { return $true } }
    return $false
}

function Find-GitRepos([string]$basePath, [int]$maxDepth) {
    if (-not (Test-Path $basePath)) { return }
    Get-ChildItem $basePath -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'node_modules' } |
        ForEach-Object {
            $gitDir = Join-Path $_.FullName '.git'
            if (Test-Path $gitDir) { $_.FullName }
            elseif ($maxDepth -gt 1) { Find-GitRepos $_.FullName ($maxDepth - 1) }
        }
}

function Stage([string]$category, [string]$src, [string]$relDest) {
    if (-not (Test-Path $src)) { return }
    $dest    = Join-Path $stagingDir $relDest
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    $isDir = (Get-Item $src).PSIsContainer
    if ($isDir) {
        Copy-Item $src $dest -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Copy-Item $src $dest -Force -ErrorAction SilentlyContinue
    }
    $manifest.Items.Add([ordered]@{
        Category=$category; Source=$src; RelDest=$relDest
    })
    Log "  [$category] $src"
}

# ── Pre-flight: warn about running apps ───────────────────────────────────────
Log "=== BDM EXPORT PRE-FLIGHT CHECK ===" 'Yellow'
$appsToCheck = [ordered]@{
    'Claude'  = 'Claude'
    'Cowork'  = 'Cowork'
    'Outlook' = 'OUTLOOK'
    'Chrome'  = 'chrome'
    'Edge'    = 'msedge'
    'Brave'   = 'brave'
    'Firefox' = 'firefox'
}
$runningApps = @()
foreach ($app in $appsToCheck.GetEnumerator()) {
    if (Get-Process $app.Value -ErrorAction SilentlyContinue) {
        $runningApps += $app.Key
    }
}
if ($runningApps.Count -gt 0) {
    Log "WARNING: These apps are running and may have locked files:" 'Yellow'
    foreach ($a in $runningApps) { Log "  - $a" 'Yellow' }
    $response = Read-Host "Continue anyway? (Y/N)"
    if ($response -notmatch '^[Yy]') {
        Log "Export cancelled. Close the listed apps and retry." 'Red'
        exit 1
    }
} else {
    Log "All clear — no conflicting apps running." 'Green'
}

# ── Auto-detect inventory JSON ────────────────────────────────────────────────
Log ""
Log "=== LOCATING INVENTORY FILE ===" 'Cyan'
$inventoryFile = Get-ChildItem "$env:USERPROFILE\Desktop" `
                 -Filter "BDM_Inventory_${machineName}_*.json" `
                 -ErrorAction SilentlyContinue |
                 Sort-Object LastWriteTime -Descending |
                 Select-Object -First 1
if ($inventoryFile) {
    Log "Using inventory: $($inventoryFile.FullName)"
} else {
    Log "No inventory JSON found for $machineName. Proceeding with fresh scan." 'Yellow'
    Log "Tip: run BDM-Inventory.ps1 first for best results." 'Yellow'
}

# ── Setup staging ─────────────────────────────────────────────────────────────
Log ""
Log "=== STAGING EXPORT ===" 'Cyan'
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null
Log "Staging: $stagingDir"

$manifest = [ordered]@{
    ExportedAt  = (Get-Date -Format 'o')
    MachineName = $machineName
    MachineTag  = $MachineTag
    UserName    = $env:USERNAME
    Items       = [System.Collections.Generic.List[object]]::new()
}

$odRoots = Get-OneDriveRoots

# 1. Claude AppData
Log ""
Log "Collecting Claude AppData..." 'Cyan'
$claudePaths = @(
    @{ Src="$env:APPDATA\Claude";           Dest="appdata\Claude_Roaming" },
    @{ Src="$env:LOCALAPPDATA\Claude";      Dest="appdata\Claude_Local" },
    @{ Src="$env:APPDATA\claude-code";      Dest="appdata\claude-code_Roaming" },
    @{ Src="$env:LOCALAPPDATA\claude-code"; Dest="appdata\claude-code_Local" },
    @{ Src="$env:APPDATA\anthropic";        Dest="appdata\anthropic_Roaming" },
    @{ Src="$env:LOCALAPPDATA\anthropic";   Dest="appdata\anthropic_Local" },
    @{ Src="$env:USERPROFILE\.claude";      Dest="dotfiles\claude" }
)
foreach ($cp in $claudePaths) { Stage 'Claude' $cp.Src $cp.Dest }

# 2. Cowork
Log "Collecting Cowork data..." 'Cyan'
$coworkPaths = @(
    @{ Src="$env:APPDATA\Cowork";               Dest="appdata\Cowork_Roaming" },
    @{ Src="$env:LOCALAPPDATA\Cowork";          Dest="appdata\Cowork_Local" },
    @{ Src="$env:USERPROFILE\Cowork";           Dest="cowork\UserRoot" },
    @{ Src="$env:USERPROFILE\Documents\Cowork"; Dest="cowork\Documents" }
)
foreach ($cp in $coworkPaths) { Stage 'Cowork' $cp.Src $cp.Dest }

# 3. Local git repos
Log "Collecting local git repos..." 'Cyan'
$seenRepos = [System.Collections.Generic.HashSet[string]]::new(
                 [StringComparer]::OrdinalIgnoreCase)
foreach ($searchPath in $repoSearchPaths) {
    $found = Find-GitRepos $searchPath $repoSearchDepth
    foreach ($repoPath in $found) {
        if (-not $seenRepos.Contains($repoPath) -and
            -not (Is-InOneDrive $repoPath $odRoots)) {
            $null = $seenRepos.Add($repoPath)
            $safeRel = $repoPath -replace '^[A-Za-z]:\\', '' -replace '\\', '__'
            Stage 'GitRepo' $repoPath "repos\$safeRel"
        }
    }
}

# 4. PowerShell scripts & modules
Log "Collecting PowerShell scripts..." 'Cyan'
$psPaths = @(
    @{ Src="$env:USERPROFILE\Documents\PowerShell";        Dest="powershell\Documents_PowerShell" },
    @{ Src="$env:USERPROFILE\Documents\WindowsPowerShell"; Dest="powershell\Documents_WindowsPowerShell" },
    @{ Src="$env:USERPROFILE\Documents\Scripts";           Dest="powershell\Documents_Scripts" },
    @{ Src="$env:USERPROFILE\Scripts";                     Dest="powershell\UserRoot_Scripts" }
)
foreach ($pp in $psPaths) { Stage 'PowerShell' $pp.Src $pp.Dest }

# 5. SA case zips (outside OneDrive)
Log "Collecting SA case zips..." 'Cyan'
$zipSearchPaths = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Cases",
    "$env:USERPROFILE\SA Cases",
    "C:\Cases",
    "C:\SA"
)
foreach ($zp in $zipSearchPaths) {
    if (Test-Path $zp) {
        Get-ChildItem $zp -Filter "*.zip" -ErrorAction SilentlyContinue |
            Where-Object { -not (Is-InOneDrive $_.FullName $odRoots) } |
            ForEach-Object {
                $safeRel = $_.FullName -replace '^[A-Za-z]:\\', '' -replace '\\', '__'
                Stage 'SAZip' $_.FullName "cazips\$safeRel"
            }
    }
}

# 6. Browser bookmarks
Log "Collecting browser bookmarks..." 'Cyan'
$browserSources = @(
    @{ Browser='Chrome';  Path="$env:LOCALAPPDATA\Google\Chrome\User Data" },
    @{ Browser='Edge';    Path="$env:LOCALAPPDATA\Microsoft\Edge\User Data" },
    @{ Browser='Brave';   Path="$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data" },
    @{ Browser='Firefox'; Path="$env:APPDATA\Mozilla\Firefox\Profiles" },
    @{ Browser='Opera';   Path="$env:APPDATA\Opera Software\Opera Stable" }
)
foreach ($bs in $browserSources) {
    if (-not (Test-Path $bs.Path)) { continue }
    if ($bs.Browser -eq 'Firefox') {
        Get-ChildItem $bs.Path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $places = Join-Path $_.FullName "places.sqlite"
            if (Test-Path $places) {
                Stage 'Bookmarks' $places "bookmarks\Firefox\$($_.Name)\places.sqlite"
            }
        }
    } else {
        $profileDirs = @("Default") +
            (Get-ChildItem $bs.Path -Directory -Filter "Profile *" -ErrorAction SilentlyContinue |
             Select-Object -ExpandProperty Name)
        foreach ($pd in $profileDirs) {
            $bmFile = Join-Path $bs.Path "$pd\Bookmarks"
            if (Test-Path $bmFile) {
                Stage 'Bookmarks' $bmFile "bookmarks\$($bs.Browser)\$pd\Bookmarks"
            }
        }
    }
}

# 7. Word / Office templates
Log "Collecting Office templates..." 'Cyan'
$templatePaths = @(
    @{ Src="$env:APPDATA\Microsoft\Templates";                   Dest="office\Templates" },
    @{ Src="$env:APPDATA\Microsoft\Word\STARTUP";                Dest="office\Word_STARTUP" },
    @{ Src="$env:USERPROFILE\Documents\Custom Office Templates"; Dest="office\Custom_Office_Templates" }
)
foreach ($tp in $templatePaths) { Stage 'WordTemplates' $tp.Src $tp.Dest }

# 8. Outlook signatures
Log "Collecting Outlook signatures..." 'Cyan'
Stage 'OutlookSignatures' "$env:APPDATA\Microsoft\Signatures" "outlook\Signatures"

# 9. Adobe preferences
Log "Collecting Adobe preferences..." 'Cyan'
$adobePaths = @(
    @{ Src="$env:APPDATA\Adobe";      Dest="adobe\Roaming" },
    @{ Src="$env:LOCALAPPDATA\Adobe"; Dest="adobe\Local" }
)
foreach ($ap in $adobePaths) { Stage 'Adobe' $ap.Src $ap.Dest }

# 10. Node / MCP global config
Log "Collecting Node / MCP config..." 'Cyan'
$nodePaths = @(
    @{ Src="$env:APPDATA\npm";       Dest="node\npm_Roaming" },
    @{ Src="$env:LOCALAPPDATA\pnpm"; Dest="node\pnpm_Local" }
)
foreach ($np in $nodePaths) { Stage 'Node/MCP' $np.Src $np.Dest }

# 11. User environment variables
Log "Collecting user environment variables..." 'Cyan'
$envData    = [ordered]@{}
$userEnvKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment')
if ($userEnvKey) {
    foreach ($name in $userEnvKey.GetValueNames()) {
        $envData[$name] = $userEnvKey.GetValue($name)
    }
    $userEnvKey.Close()
}
$envDest = Join-Path $stagingDir "env\user_env_vars.json"
New-Item -ItemType Directory -Path (Split-Path $envDest -Parent) -Force | Out-Null
$envData | ConvertTo-Json | Set-Content $envDest -Encoding UTF8
$manifest.Items.Add([ordered]@{
    Category='EnvVars'; Source='HKCU:\Environment'; RelDest='env\user_env_vars.json'
})
Log "  [EnvVars] HKCU:\Environment exported"

# Write manifest into staging
$manifestPath = Join-Path $stagingDir "BDM_manifest.json"
$manifest | ConvertTo-Json -Depth 10 | Set-Content $manifestPath -Encoding UTF8
Log ""
Log "Manifest written: $manifestPath"

# ── Compress ──────────────────────────────────────────────────────────────────
Log ""
Log "=== CREATING ZIP ===" 'Cyan'
Log "Compressing to: $zipPath"
Add-Type -Assembly System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $stagingDir, $zipPath,
    [System.IO.Compression.CompressionLevel]::Optimal, $false
)
$zipSizeMB = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
Log "Zip created: $zipPath  (${zipSizeMB} MB)" 'Green'

# ── Cleanup & log ─────────────────────────────────────────────────────────────
Remove-Item $stagingDir -Recurse -Force -ErrorAction SilentlyContinue
Log "Staging directory cleaned up."
$log | Set-Content $logPath -Encoding UTF8

Log ""
Log "=== EXPORT COMPLETE ===" 'Green'
Log "Zip : $zipPath  ($zipSizeMB MB)" 'Cyan'
Log "Log : $logPath" 'Cyan'
Log ""
Log "NEXT STEPS:" 'Yellow'
Log "  1. Transfer $zipName to the new laptop" 'Yellow'
Log "  2. Run BDM-Export.ps1 on the OTHER source machine" 'Yellow'
Log "  3. Once you have both zips on the new laptop, run BDM-Import.ps1" 'Yellow'
