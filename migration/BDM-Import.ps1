#Requires -Version 5.1
<#
.SYNOPSIS
    BDM Migration Import — Step 3 of 3-step laptop migration workflow.
.DESCRIPTION
    Merges both export zips (Desktop + Laptop) onto the new machine.

    Conflict resolution rules by data type:
      Claude / Cowork / AppData  — newer file wins
      Git repos                  — side-by-side (kept as RepoName_Desktop / _Laptop)
      Browser bookmarks          — side-by-side folder on Desktop for manual import
      Word templates / Sigs      — newer file wins
      SA case zips               — newer wins; exact duplicates (name+size) skipped
      Env vars                   — merged; conflicts keep the new-machine value

    Backs up existing AppData before touching anything.
    Produces three reports on the Desktop when done.
.PARAMETER ZipPaths
    Optional. Explicit paths to one or both export zips. If omitted, the script
    auto-searches the Desktop for BDM_Export_*.zip files.
.PARAMETER SearchPath
    Where to auto-search for zips. Defaults to the Desktop.
.PARAMETER ReportPath
    Where to write the three report files. Defaults to the Desktop.
.PARAMETER DryRun
    Print every action without writing or copying anything.
.NOTES
    Run as the migration target user on the NEW laptop.
    Copy both export zips to the Desktop before running.
#>

[CmdletBinding()]
param(
    [string[]]$ZipPaths,
    [string]$SearchPath  = "$env:USERPROFILE\Desktop",
    [string]$ReportPath  = "$env:USERPROFILE\Desktop",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

$timestamp  = Get-Date -Format 'yyyyMMdd_HHmmss'
$expandBase = Join-Path $env:TEMP "BDM_Import_$timestamp"
$backupDir  = "$env:APPDATA\BDM_PreImport_Backup_$timestamp"

$fullLog       = [System.Collections.Generic.List[string]]::new()
$conflictLog   = [System.Collections.Generic.List[string]]::new()
$softwareDelta = [System.Collections.Generic.List[string]]::new()

$conflictLog.Add("BDM CONFLICT RESOLUTION REPORT")
$conflictLog.Add("Generated : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$conflictLog.Add("New machine: $env:COMPUTERNAME  |  User: $env:USERNAME")
$conflictLog.Add("=" * 72)

function Log([string]$msg, [string]$color = 'White') {
    $ts   = Get-Date -Format 'HH:mm:ss'
    $line = "[$ts] $msg"
    $fullLog.Add($line)
    Write-Host $line -ForegroundColor $color
}

function LogConflict([string]$msg) {
    $conflictLog.Add("  $msg")
    Log "  CONFLICT: $msg" 'Yellow'
}

# Copies a single file with the chosen conflict strategy.
function Copy-WithStrategy([string]$src, [string]$dest, [string]$strategy) {
    if (-not (Test-Path $src)) { return }
    $destDir = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    }
    if (Test-Path $dest) {
        if ($strategy -eq 'newer-wins') {
            $srcMod  = (Get-Item $src).LastWriteTime
            $destMod = (Get-Item $dest).LastWriteTime
            if ($srcMod -gt $destMod) {
                LogConflict "newer-wins REPLACED  $dest`n             src=$($srcMod.ToString('s'))  dest=$($destMod.ToString('s'))"
                if (-not $DryRun) { Copy-Item $src $dest -Force }
            } else {
                LogConflict "newer-wins KEPT      $dest`n             existing is newer or same"
            }
        }
        # 'skip' — do nothing
    } else {
        if (-not $DryRun) { Copy-Item $src $dest -Force }
    }
}

# Recursively merges a source directory into a destination directory.
function Merge-Dir([string]$src, [string]$dest, [string]$strategy = 'newer-wins') {
    if (-not (Test-Path $src)) { return }
    if (-not $DryRun -and -not (Test-Path $dest)) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }
    Get-ChildItem $src -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $rel      = $_.FullName.Substring($src.Length).TrimStart('\')
        $destFile = Join-Path $dest $rel
        Copy-WithStrategy $_.FullName $destFile $strategy
    }
}

# ── Locate zips ───────────────────────────────────────────────────────────────
Log "=== BDM IMPORT ===" 'Cyan'
Log "New machine: $env:COMPUTERNAME  |  User: $env:USERNAME"
if ($DryRun) { Log "DRY RUN MODE — no files will be written." 'Yellow' }
Log ""

if (-not $ZipPaths -or $ZipPaths.Count -eq 0) {
    Log "Searching for export zips in: $SearchPath"
    $ZipPaths = Get-ChildItem $SearchPath -Filter "BDM_Export_*.zip" `
                    -ErrorAction SilentlyContinue |
                Sort-Object Name |
                Select-Object -ExpandProperty FullName
}
if (-not $ZipPaths -or $ZipPaths.Count -eq 0) {
    Log "ERROR: No BDM_Export_*.zip files found in $SearchPath." 'Red'
    Log "Copy both export zips here and retry." 'Red'
    exit 1
}
Log "Found $($ZipPaths.Count) export zip(s):"
foreach ($z in $ZipPaths) { Log "  $z" 'Cyan' }

# ── Backup existing AppData ───────────────────────────────────────────────────
Log ""
Log "=== BACKING UP EXISTING APPDATA ===" 'Cyan'
$backupSources = @(
    "$env:APPDATA\Claude",
    "$env:LOCALAPPDATA\Claude",
    "$env:APPDATA\claude-code",
    "$env:APPDATA\anthropic",
    "$env:APPDATA\Microsoft\Signatures",
    "$env:APPDATA\Microsoft\Templates"
)
foreach ($bs in $backupSources) {
    if (Test-Path $bs) {
        $rel         = $bs -replace [regex]::Escape($env:USERPROFILE), ''
        $backupDest  = Join-Path $backupDir $rel.TrimStart('\')
        Log "  Backing up: $bs"
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path (Split-Path $backupDest -Parent) -Force | Out-Null
            Copy-Item $bs $backupDest -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
Log "Backup location: $backupDir" 'Cyan'

# ── Expand zips ───────────────────────────────────────────────────────────────
Log ""
Log "=== EXPANDING ZIPS ===" 'Cyan'
Add-Type -Assembly System.IO.Compression.FileSystem
$expandedSources = [System.Collections.Generic.List[object]]::new()

foreach ($zipPath in $ZipPaths) {
    $zipName    = [System.IO.Path]::GetFileNameWithoutExtension($zipPath)
    $extractDir = Join-Path $expandBase $zipName
    Log "  Expanding: $(Split-Path $zipPath -Leaf)"
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractDir)
    }
    $manifestPath = Join-Path $extractDir "BDM_manifest.json"
    $manifest     = $null
    if (Test-Path $manifestPath) {
        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
        Log "    Machine: $($manifest.MachineName)  Tag: $($manifest.MachineTag)  Exported: $($manifest.ExportedAt)"
    } else {
        Log "    WARNING: no manifest found — tag inferred from zip name." 'Yellow'
    }
    # Infer tag from zip filename if manifest is missing
    $tag = if ($manifest) { $manifest.MachineTag }
           elseif ($zipName -match 'Desktop') { 'Desktop' }
           elseif ($zipName -match 'Laptop')  { 'Laptop'  }
           else { $zipName }

    $expandedSources.Add([ordered]@{
        ZipPath    = $zipPath
        ExtractDir = $extractDir
        Manifest   = $manifest
        Tag        = $tag
    })
}

# Process Desktop first so Laptop wins any tie-break (Laptop usually newer).
$orderedSources = @(
    ($expandedSources | Where-Object { $_.Tag -eq 'Desktop' } | Select-Object -First 1),
    ($expandedSources | Where-Object { $_.Tag -eq 'Laptop'  } | Select-Object -First 1)
) | Where-Object { $_ -ne $null }

# ── 1. Claude AppData ─────────────────────────────────────────────────────────
Log ""
Log "=== RESTORING CLAUDE APPDATA ===" 'Cyan'
$claudeMap = @(
    @{ Src="appdata\Claude_Roaming";      Dest="$env:APPDATA\Claude" },
    @{ Src="appdata\Claude_Local";        Dest="$env:LOCALAPPDATA\Claude" },
    @{ Src="appdata\claude-code_Roaming"; Dest="$env:APPDATA\claude-code" },
    @{ Src="appdata\claude-code_Local";   Dest="$env:LOCALAPPDATA\claude-code" },
    @{ Src="appdata\anthropic_Roaming";   Dest="$env:APPDATA\anthropic" },
    @{ Src="appdata\anthropic_Local";     Dest="$env:LOCALAPPDATA\anthropic" },
    @{ Src="dotfiles\claude";             Dest="$env:USERPROFILE\.claude" }
)
foreach ($m in $claudeMap) {
    foreach ($src in $orderedSources) {
        $srcDir = Join-Path $src.ExtractDir $m.Src
        if (Test-Path $srcDir) {
            Log "  [$($src.Tag)] $($m.Src)"
            Merge-Dir $srcDir $m.Dest 'newer-wins'
        }
    }
}

# ── 2. Cowork ─────────────────────────────────────────────────────────────────
Log ""
Log "=== RESTORING COWORK ===" 'Cyan'
$coworkMap = @(
    @{ Src="appdata\Cowork_Roaming"; Dest="$env:APPDATA\Cowork" },
    @{ Src="appdata\Cowork_Local";   Dest="$env:LOCALAPPDATA\Cowork" },
    @{ Src="cowork\UserRoot";        Dest="$env:USERPROFILE\Cowork" },
    @{ Src="cowork\Documents";       Dest="$env:USERPROFILE\Documents\Cowork" }
)
foreach ($m in $coworkMap) {
    foreach ($src in $orderedSources) {
        $srcDir = Join-Path $src.ExtractDir $m.Src
        if (Test-Path $srcDir) {
            Log "  [$($src.Tag)] $($m.Src)"
            Merge-Dir $srcDir $m.Dest 'newer-wins'
        }
    }
}

# ── 3. Git repos — side-by-side ───────────────────────────────────────────────
Log ""
Log "=== RESTORING GIT REPOS (side-by-side) ===" 'Cyan'
$reposBase = "$env:USERPROFILE\Projects\BDM_Migrated"
if (-not $DryRun) { New-Item -ItemType Directory -Path $reposBase -Force | Out-Null }

foreach ($src in $orderedSources) {
    $reposDir = Join-Path $src.ExtractDir "repos"
    if (-not (Test-Path $reposDir)) { continue }
    Get-ChildItem $reposDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $destRepo = Join-Path $reposBase "$($_.Name)_$($src.Tag)"
        if (Test-Path $destRepo) {
            LogConflict "repo $($_.Name) [$($src.Tag)]: destination exists, skipped — $destRepo"
        } else {
            Log "  [$($src.Tag)] $($_.Name) -> $destRepo"
            if (-not $DryRun) {
                Copy-Item $_.FullName $destRepo -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
Log "  Repos placed in: $reposBase" 'Cyan'
Log "  Review, consolidate, then move each to your preferred working path." 'Yellow'

# ── 4. PowerShell scripts ─────────────────────────────────────────────────────
Log ""
Log "=== RESTORING POWERSHELL SCRIPTS ===" 'Cyan'
$psMap = @(
    @{ Src="powershell\Documents_PowerShell";        Dest="$env:USERPROFILE\Documents\PowerShell" },
    @{ Src="powershell\Documents_WindowsPowerShell"; Dest="$env:USERPROFILE\Documents\WindowsPowerShell" },
    @{ Src="powershell\Documents_Scripts";           Dest="$env:USERPROFILE\Documents\Scripts" },
    @{ Src="powershell\UserRoot_Scripts";            Dest="$env:USERPROFILE\Scripts" }
)
foreach ($m in $psMap) {
    foreach ($src in $orderedSources) {
        $srcDir = Join-Path $src.ExtractDir $m.Src
        if (Test-Path $srcDir) {
            Log "  [$($src.Tag)] $($m.Src)"
            Merge-Dir $srcDir $m.Dest 'newer-wins'
        }
    }
}

# ── 5. SA case zips ───────────────────────────────────────────────────────────
Log ""
Log "=== RESTORING SA CASE ZIPS ===" 'Cyan'
$zipDest = "$env:USERPROFILE\Documents\SA_Cases_Migrated"
if (-not $DryRun) { New-Item -ItemType Directory -Path $zipDest -Force | Out-Null }
$seenZipKeys = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

foreach ($src in $orderedSources) {
    $cazipsDir = Join-Path $src.ExtractDir "cazips"
    if (-not (Test-Path $cazipsDir)) { continue }
    Get-ChildItem $cazipsDir -Filter "*.zip" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        $key      = "$($_.Name)|$($_.Length)"
        $destFile = Join-Path $zipDest $_.Name
        if ($seenZipKeys.Add($key)) {
            if (Test-Path $destFile) {
                $srcMod  = $_.LastWriteTime
                $destMod = (Get-Item $destFile).LastWriteTime
                if ($srcMod -gt $destMod) {
                    LogConflict "SA zip newer-wins REPLACED: $($_.Name)"
                    if (-not $DryRun) { Copy-Item $_.FullName $destFile -Force }
                } else {
                    LogConflict "SA zip newer-wins KEPT existing: $($_.Name)"
                }
            } else {
                Log "  $($_.Name)"
                if (-not $DryRun) { Copy-Item $_.FullName $destFile -Force }
            }
        } else {
            Log "  DEDUP skipped (identical file from other machine): $($_.Name)" 'DarkGray'
        }
    }
}

# ── 6. Browser bookmarks — side-by-side ──────────────────────────────────────
Log ""
Log "=== RESTORING BROWSER BOOKMARKS (side-by-side) ===" 'Cyan'
$bmReviewDir = "$env:USERPROFILE\Desktop\BDM_Bookmarks_Review"
if (-not $DryRun) { New-Item -ItemType Directory -Path $bmReviewDir -Force | Out-Null }

foreach ($src in $orderedSources) {
    $bmDir      = Join-Path $src.ExtractDir "bookmarks"
    $bmTagDir   = Join-Path $bmReviewDir $src.Tag
    if (Test-Path $bmDir) {
        Log "  [$($src.Tag)] -> $bmTagDir"
        if (-not $DryRun) {
            if (-not (Test-Path $bmTagDir)) {
                New-Item -ItemType Directory -Path $bmTagDir -Force | Out-Null
            }
            Copy-Item "$bmDir\*" $bmTagDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
Log "  Bookmarks: $bmReviewDir" 'Cyan'
Log "  Import each browser's folder manually via browser settings." 'Yellow'

# ── 7. Word / Office templates ────────────────────────────────────────────────
Log ""
Log "=== RESTORING OFFICE TEMPLATES ===" 'Cyan'
$templateMap = @(
    @{ Src="office\Templates";               Dest="$env:APPDATA\Microsoft\Templates" },
    @{ Src="office\Word_STARTUP";            Dest="$env:APPDATA\Microsoft\Word\STARTUP" },
    @{ Src="office\Custom_Office_Templates"; Dest="$env:USERPROFILE\Documents\Custom Office Templates" }
)
foreach ($m in $templateMap) {
    foreach ($src in $orderedSources) {
        $srcDir = Join-Path $src.ExtractDir $m.Src
        if (Test-Path $srcDir) {
            Log "  [$($src.Tag)] $($m.Src)"
            Merge-Dir $srcDir $m.Dest 'newer-wins'
        }
    }
}

# ── 8. Outlook signatures ─────────────────────────────────────────────────────
Log ""
Log "=== RESTORING OUTLOOK SIGNATURES ===" 'Cyan'
$sigDest = "$env:APPDATA\Microsoft\Signatures"
foreach ($src in $orderedSources) {
    $srcDir = Join-Path $src.ExtractDir "outlook\Signatures"
    if (Test-Path $srcDir) {
        Log "  [$($src.Tag)] Signatures -> $sigDest"
        Merge-Dir $srcDir $sigDest 'newer-wins'
    }
}

# ── 9. Adobe preferences ──────────────────────────────────────────────────────
Log ""
Log "=== RESTORING ADOBE PREFERENCES ===" 'Cyan'
$adobeMap = @(
    @{ Src="adobe\Roaming"; Dest="$env:APPDATA\Adobe" },
    @{ Src="adobe\Local";   Dest="$env:LOCALAPPDATA\Adobe" }
)
foreach ($m in $adobeMap) {
    foreach ($src in $orderedSources) {
        $srcDir = Join-Path $src.ExtractDir $m.Src
        if (Test-Path $srcDir) {
            Log "  [$($src.Tag)] $($m.Src)"
            Merge-Dir $srcDir $m.Dest 'newer-wins'
        }
    }
}

# ── 10. Node / MCP config ─────────────────────────────────────────────────────
Log ""
Log "=== RESTORING NODE / MCP CONFIG ===" 'Cyan'
$nodeMap = @(
    @{ Src="node\npm_Roaming"; Dest="$env:APPDATA\npm" },
    @{ Src="node\pnpm_Local";  Dest="$env:LOCALAPPDATA\pnpm" }
)
foreach ($m in $nodeMap) {
    foreach ($src in $orderedSources) {
        $srcDir = Join-Path $src.ExtractDir $m.Src
        if (Test-Path $srcDir) {
            Log "  [$($src.Tag)] $($m.Src)"
            Merge-Dir $srcDir $m.Dest 'newer-wins'
        }
    }
}

# ── 11. Environment variables ─────────────────────────────────────────────────
Log ""
Log "=== MERGING ENVIRONMENT VARIABLES ===" 'Cyan'
$currentEnvKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
$currentVars   = [ordered]@{}
if ($currentEnvKey) {
    foreach ($name in $currentEnvKey.GetValueNames()) {
        $currentVars[$name] = $currentEnvKey.GetValue($name)
    }
}
$conflictLog.Add("")
$conflictLog.Add("ENVIRONMENT VARIABLE CONFLICTS:")
$conflictLog.Add("-" * 50)

foreach ($src in $orderedSources) {
    $envFile = Join-Path $src.ExtractDir "env\user_env_vars.json"
    if (-not (Test-Path $envFile)) { continue }
    $srcVars = Get-Content $envFile -Raw | ConvertFrom-Json
    foreach ($prop in $srcVars.PSObject.Properties) {
        $name  = $prop.Name
        $value = $prop.Value
        if ($currentVars.Contains($name)) {
            if ($currentVars[$name] -ne $value) {
                LogConflict "EnvVar '$name': kept new-machine value '$($currentVars[$name])' (source [$($src.Tag)] had '$value')"
            }
        } else {
            Log "  Setting: $name = $value"
            if (-not $DryRun -and $currentEnvKey) {
                $currentEnvKey.SetValue($name, $value,
                    [Microsoft.Win32.RegistryValueKind]::ExpandString)
            }
            $currentVars[$name] = $value
        }
    }
}
if ($currentEnvKey) { $currentEnvKey.Close() }

# ── Software delta report ─────────────────────────────────────────────────────
Log ""
Log "=== GENERATING SOFTWARE DELTA REPORT ===" 'Cyan'
$regPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$installedHere = [System.Collections.Generic.HashSet[string]]::new(
                     [StringComparer]::OrdinalIgnoreCase)
foreach ($rp in $regPaths) {
    Get-ItemProperty $rp -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        ForEach-Object { $null = $installedHere.Add($_.DisplayName) }
}

$softwareDelta.Add("BDM SOFTWARE DELTA REPORT")
$softwareDelta.Add("Generated  : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$softwareDelta.Add("New machine: $env:COMPUTERNAME")
$softwareDelta.Add("=" * 72)
$softwareDelta.Add("")
$softwareDelta.Add("Apps on source machines NOT found on this new machine.")
$softwareDelta.Add("Install these manually if needed.")
$softwareDelta.Add("-" * 50)

foreach ($src in $orderedSources) {
    # Look for the matching inventory JSON beside the zip file
    $zipDir  = Split-Path $src.ZipPath -Parent
    $invFile = Get-ChildItem $zipDir -Filter "BDM_Inventory_*.json" `
               -ErrorAction SilentlyContinue |
               Sort-Object LastWriteTime -Descending |
               Select-Object -First 1
    if (-not $invFile) { continue }
    $inv = Get-Content $invFile.FullName -Raw | ConvertFrom-Json
    if (-not $inv.Sections.InstalledSoftware) { continue }

    $softwareDelta.Add("")
    $softwareDelta.Add("FROM: $($inv.MachineName) [$($src.Tag)]")
    foreach ($app in $inv.Sections.InstalledSoftware) {
        if (-not $installedHere.Contains($app.Name)) {
            $softwareDelta.Add("  MISSING  $($app.Name)  $($app.Version)  [$($app.Publisher)]")
        }
    }
}

# ── Write reports ─────────────────────────────────────────────────────────────
Log ""
Log "=== WRITING REPORTS ===" 'Cyan'
$fullLogPath     = Join-Path $ReportPath "BDM_Import_FullLog_${timestamp}.txt"
$conflictLogPath = Join-Path $ReportPath "BDM_Import_ConflictReport_${timestamp}.txt"
$deltaPath       = Join-Path $ReportPath "BDM_Import_SoftwareDelta_${timestamp}.txt"

if (-not $DryRun) {
    $fullLog       | Set-Content $fullLogPath     -Encoding UTF8
    $conflictLog   | Set-Content $conflictLogPath -Encoding UTF8
    $softwareDelta | Set-Content $deltaPath       -Encoding UTF8
}

# ── Cleanup temp ──────────────────────────────────────────────────────────────
Remove-Item $expandBase -Recurse -Force -ErrorAction SilentlyContinue

Log ""
Log "=== IMPORT COMPLETE ===" 'Green'
Log "Backup (pre-import) : $backupDir" 'Cyan'
Log "Full log            : $fullLogPath" 'Cyan'
Log "Conflict report     : $conflictLogPath" 'Cyan'
Log "Software delta      : $deltaPath" 'Cyan'
Log ""
Log "VERIFICATION CHECKLIST:" 'Yellow'
Log "  [ ] Claude Desktop — verify MCP servers appear in settings" 'Yellow'
Log "  [ ] Cowork — sign in and verify data sync" 'Yellow'
Log "  [ ] Outlook — check signatures appear under File > Options > Mail > Signatures" 'Yellow'
Log "  [ ] Chrome / Edge / Brave — import bookmarks from Desktop\BDM_Bookmarks_Review" 'Yellow'
Log "  [ ] Word — confirm custom templates appear in File > New" 'Yellow'
Log "  [ ] Open Software Delta report and install missing apps" 'Yellow'
Log "  [ ] Review migrated repos in $env:USERPROFILE\Projects\BDM_Migrated" 'Yellow'
Log "  [ ] Verify SA case zips in $env:USERPROFILE\Documents\SA_Cases_Migrated" 'Yellow'
Log "  [ ] OneDrive — sign in, pin JDA BDM CLAUDE FILES as 'always on this device'" 'Yellow'
Log "  [ ] Restart PowerShell and test: ``. `$PROFILE``" 'Yellow'
