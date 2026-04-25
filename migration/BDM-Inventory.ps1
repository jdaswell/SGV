#Requires -Version 5.1
<#
.SYNOPSIS
    BDM Machine Inventory — Step 1 of 3-step laptop migration workflow.
.DESCRIPTION
    Scans common locations on the current machine and produces a human-readable
    report (.txt) and structured data file (.json) on the Desktop.
    Run on BOTH source machines before doing anything else. No data is moved.
.PARAMETER OutputPath
    Where to write the inventory files. Defaults to the Desktop.
.NOTES
    Run as the user whose data you want to migrate (not as Administrator).
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "$env:USERPROFILE\Desktop"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

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
$repoSearchDepth = 3   # levels deep to look for .git folders

$oneDrivePaths = @(
    "$env:USERPROFILE\OneDrive",
    "$env:USERPROFILE\OneDrive - *"
)
# ─────────────────────────────────────────────────────────────────────────────

$timestamp   = Get-Date -Format 'yyyyMMdd_HHmmss'
$machineName = $env:COMPUTERNAME
$txtFile     = Join-Path $OutputPath "BDM_Inventory_${machineName}_${timestamp}.txt"
$jsonFile    = Join-Path $OutputPath "BDM_Inventory_${machineName}_${timestamp}.json"

$report = [ordered]@{
    GeneratedAt = (Get-Date -Format 'o')
    MachineName = $machineName
    UserName    = $env:USERNAME
    UserProfile = $env:USERPROFILE
    Sections    = [ordered]@{}
}

$lines = [System.Collections.Generic.List[string]]::new()

function Write-Section([string]$title) {
    $lines.Add("")
    $lines.Add("=" * 72)
    $lines.Add("  $title")
    $lines.Add("=" * 72)
}

function Write-Item([string]$label, [string]$value) {
    $lines.Add("  $($label.PadRight(28)) $value")
}

function Write-Entry([string]$text) {
    $lines.Add("  $text")
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
    foreach ($r in $roots) {
        if ($path -like "$r*") { return $true }
    }
    return $false
}

function Find-GitRepos([string]$basePath, [int]$maxDepth) {
    if (-not (Test-Path $basePath)) { return }
    Get-ChildItem $basePath -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'node_modules' } |
        ForEach-Object {
            $gitDir = Join-Path $_.FullName '.git'
            if (Test-Path $gitDir) {
                $_.FullName
            } elseif ($maxDepth -gt 1) {
                Find-GitRepos $_.FullName ($maxDepth - 1)
            }
        }
}

# ── Header ───────────────────────────────────────────────────────────────────
$lines.Add("BDM MACHINE INVENTORY")
$lines.Add("Machine : $machineName")
$lines.Add("User    : $env:USERNAME")
$lines.Add("Date    : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$lines.Add("Profile : $env:USERPROFILE")
$lines.Add("")
$lines.Add("READ-ONLY — nothing has been moved or copied.")
$lines.Add("Review both machine inventories before running BDM-Export.ps1.")

# ── 1. Claude AppData ─────────────────────────────────────────────────────────
Write-Section "1. CLAUDE APP DATA"
$claudePaths = @(
    "$env:APPDATA\Claude",
    "$env:LOCALAPPDATA\Claude",
    "$env:APPDATA\claude-code",
    "$env:LOCALAPPDATA\claude-code",
    "$env:APPDATA\anthropic",
    "$env:LOCALAPPDATA\anthropic",
    "$env:USERPROFILE\.claude"
)
$claudeFound = [System.Collections.Generic.List[object]]::new()
foreach ($cp in $claudePaths) {
    if (Test-Path $cp) {
        $size      = (Get-ChildItem $cp -Recurse -File -ErrorAction SilentlyContinue |
                      Measure-Object -Property Length -Sum).Sum
        $sizeMB    = [math]::Round($size / 1MB, 2)
        $fileCount = (Get-ChildItem $cp -Recurse -File -ErrorAction SilentlyContinue |
                      Measure-Object).Count
        Write-Entry "FOUND  $cp"
        Write-Entry "       Files: $fileCount  |  Size: ${sizeMB} MB"
        $claudeFound.Add([ordered]@{ Path=$cp; FileCount=$fileCount; SizeMB=$sizeMB })
    } else {
        Write-Entry "absent $cp"
    }
}
$report.Sections['Claude'] = $claudeFound

# ── 2. Cowork ─────────────────────────────────────────────────────────────────
Write-Section "2. COWORK"
$coworkPaths = @(
    "$env:APPDATA\Cowork",
    "$env:LOCALAPPDATA\Cowork",
    "$env:USERPROFILE\Cowork",
    "$env:USERPROFILE\Documents\Cowork"
)
$coworkFound = [System.Collections.Generic.List[object]]::new()
foreach ($cp in $coworkPaths) {
    if (Test-Path $cp) {
        $size   = (Get-ChildItem $cp -Recurse -File -ErrorAction SilentlyContinue |
                   Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        Write-Entry "FOUND  $cp  (${sizeMB} MB)"
        $coworkFound.Add([ordered]@{ Path=$cp; SizeMB=$sizeMB })
    } else {
        Write-Entry "absent $cp"
    }
}
$coworkExe = Get-ChildItem "C:\Program Files", "C:\Program Files (x86)" `
             -Recurse -Filter "Cowork*.exe" -ErrorAction SilentlyContinue
foreach ($exe in $coworkExe) {
    Write-Entry "EXE    $($exe.FullName)"
    $coworkFound.Add([ordered]@{ Path=$exe.FullName; Type='Executable' })
}
$report.Sections['Cowork'] = $coworkFound

# ── 3. Git Repositories ───────────────────────────────────────────────────────
Write-Section "3. GIT REPOSITORIES (outside OneDrive)"
$odRoots    = Get-OneDriveRoots
$gitRepos   = [System.Collections.Generic.List[object]]::new()
$seenRepos  = [System.Collections.Generic.HashSet[string]]::new(
                  [StringComparer]::OrdinalIgnoreCase)

foreach ($searchPath in $repoSearchPaths) {
    $found = Find-GitRepos $searchPath $repoSearchDepth
    foreach ($repoPath in $found) {
        if (-not $seenRepos.Contains($repoPath)) {
            $null = $seenRepos.Add($repoPath)
            $inOD       = Is-InOneDrive $repoPath $odRoots
            $label      = if ($inOD) { "ONEDRIVE" } else { "LOCAL   " }
            $branch     = git -C $repoPath rev-parse --abbrev-ref HEAD 2>$null
            $lastCommit = git -C $repoPath log -1 --format="%ai %s" 2>$null
            $remoteUrl  = git -C $repoPath remote get-url origin 2>$null

            Write-Entry "$label  $repoPath"
            if ($branch)     { Write-Entry "          Branch : $branch" }
            if ($remoteUrl)  { Write-Entry "          Remote : $remoteUrl" }
            if ($lastCommit) { Write-Entry "          Last   : $lastCommit" }

            $gitRepos.Add([ordered]@{
                Path=$repoPath; InOneDrive=$inOD
                Branch=$branch; Remote=$remoteUrl; LastCommit=$lastCommit
            })
        }
    }
}
$localCount = ($gitRepos | Where-Object { -not $_.InOneDrive }).Count
Write-Entry ""
Write-Entry "Total repos: $($gitRepos.Count)  |  Local (need export): $localCount"
$report.Sections['GitRepos'] = $gitRepos

# ── 4. MCP Server Installs ────────────────────────────────────────────────────
Write-Section "4. MCP SERVER INSTALLS"
$mcpItems = [System.Collections.Generic.List[object]]::new()

# npm globals
$npmGlobal = npm list -g --depth=0 --json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
if ($npmGlobal -and $npmGlobal.dependencies) {
    $mcpPkgs = $npmGlobal.dependencies.PSObject.Properties |
               Where-Object { $_.Name -match 'mcp|model-context|claude' }
    foreach ($pkg in $mcpPkgs) {
        Write-Entry "npm-global  $($pkg.Name)  $($pkg.Value.version)"
        $mcpItems.Add([ordered]@{
            Type='npm-global'; Name=$pkg.Name; Version=$pkg.Value.version
        })
    }
}

# Claude Desktop config (contains MCP server definitions)
$claudeConfigPaths = @(
    "$env:APPDATA\Claude\claude_desktop_config.json",
    "$env:LOCALAPPDATA\Claude\claude_desktop_config.json"
)
foreach ($cfgPath in $claudeConfigPaths) {
    if (Test-Path $cfgPath) {
        $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($cfg -and $cfg.mcpServers) {
            Write-Entry "Claude Desktop config: $cfgPath"
            foreach ($server in $cfg.mcpServers.PSObject.Properties) {
                $args = $server.Value.args -join ' '
                Write-Entry "  MCP Server: $($server.Name)  =>  $($server.Value.command) $args"
                $mcpItems.Add([ordered]@{
                    Type='claude-desktop-mcp'; Name=$server.Name
                    Command=$server.Value.command; Args=$server.Value.args
                })
            }
        }
    }
}

# pnpm globals
$pnpmList = pnpm list -g --depth=0 --json 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
if ($pnpmList) {
    $pkgs = if ($pnpmList -is [array]) { $pnpmList } else { @($pnpmList) }
    foreach ($pkg in $pkgs) {
        if ($pkg.name -match 'mcp|model-context|claude') {
            Write-Entry "pnpm-global  $($pkg.name)  $($pkg.version)"
            $mcpItems.Add([ordered]@{
                Type='pnpm-global'; Name=$pkg.name; Version=$pkg.version
            })
        }
    }
}

if ($mcpItems.Count -eq 0) { Write-Entry "No MCP installs detected." }
$report.Sections['MCP'] = $mcpItems

# ── 5. PowerShell Scripts ─────────────────────────────────────────────────────
Write-Section "5. POWERSHELL SCRIPTS & MODULES"
$psScriptPaths = @(
    "$env:USERPROFILE\Documents\PowerShell",
    "$env:USERPROFILE\Documents\WindowsPowerShell",
    "$env:USERPROFILE\Documents\Scripts",
    "$env:USERPROFILE\Scripts",
    "$env:USERPROFILE\Desktop"
)
$psItems = [System.Collections.Generic.List[object]]::new()
foreach ($psPath in $psScriptPaths) {
    if (Test-Path $psPath) {
        $scripts = Get-ChildItem $psPath -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
        foreach ($s in $scripts) {
            Write-Entry "$($s.FullName)  ($([math]::Round($s.Length/1KB,1)) KB)"
            $psItems.Add([ordered]@{
                Path=$s.FullName
                SizeKB=[math]::Round($s.Length/1KB,1)
                LastModified=$s.LastWriteTime.ToString('o')
            })
        }
    }
}

$customModulePaths = $env:PSModulePath -split ';' |
    Where-Object { $_ -like "*$env:USERPROFILE*" -and (Test-Path $_) }
foreach ($mp in $customModulePaths) {
    Get-ChildItem $mp -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Entry "Module: $($_.FullName)"
        $psItems.Add([ordered]@{ Path=$_.FullName; Type='Module' })
    }
}

Write-Entry ""
Write-Entry "Total PS scripts/modules: $($psItems.Count)"
$report.Sections['PowerShell'] = $psItems

# ── 6. SA Case Zips (outside OneDrive) ───────────────────────────────────────
Write-Section "6. SA CASE ZIPS (outside OneDrive)"
$saZips = [System.Collections.Generic.List[object]]::new()
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
        $zips = Get-ChildItem $zp -Filter "*.zip" -Recurse -ErrorAction SilentlyContinue |
                Where-Object { -not (Is-InOneDrive $_.FullName $odRoots) }
        foreach ($z in $zips) {
            $sizeMB = [math]::Round($z.Length / 1MB, 2)
            Write-Entry "$($z.FullName)  (${sizeMB} MB)  Modified: $($z.LastWriteTime.ToString('yyyy-MM-dd'))"
            $saZips.Add([ordered]@{
                Path=$z.FullName; SizeMB=$sizeMB
                Modified=$z.LastWriteTime.ToString('o')
            })
        }
    }
}
Write-Entry ""
Write-Entry "Total zip files outside OneDrive: $($saZips.Count)"
$report.Sections['SAZips'] = $saZips

# ── 7. PST Files ──────────────────────────────────────────────────────────────
Write-Section "7. OUTLOOK PST FILES"
$pstItems = [System.Collections.Generic.List[object]]::new()
$pstSearchPaths = @(
    "$env:LOCALAPPDATA\Microsoft\Outlook",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop",
    "C:\",
    "D:\"
)
foreach ($pp in $pstSearchPaths) {
    if (Test-Path $pp) {
        Get-ChildItem $pp -Filter "*.pst" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $sizeMB = [math]::Round($_.Length / 1MB, 2)
            $inOD   = Is-InOneDrive $_.FullName $odRoots
            $label  = if ($inOD) { "[OneDrive]" } else { "[LOCAL   ]" }
            Write-Entry "$label $($_.FullName)  (${sizeMB} MB)"
            $pstItems.Add([ordered]@{
                Path=$_.FullName; SizeMB=$sizeMB; InOneDrive=$inOD
            })
        }
    }
}
$localPsts = ($pstItems | Where-Object { -not $_.InOneDrive }).Count
Write-Entry ""
Write-Entry "Total PSTs: $($pstItems.Count)  |  Local (need manual move): $localPsts"
$report.Sections['PSTs'] = $pstItems

# ── 8. Browser Bookmarks ──────────────────────────────────────────────────────
Write-Section "8. BROWSER BOOKMARKS"
$bookmarkItems = [System.Collections.Generic.List[object]]::new()
$browserProfiles = [ordered]@{
    'Chrome'  = "$env:LOCALAPPDATA\Google\Chrome\User Data"
    'Edge'    = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
    'Brave'   = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"
    'Firefox' = "$env:APPDATA\Mozilla\Firefox\Profiles"
    'Opera'   = "$env:APPDATA\Opera Software\Opera Stable"
}
foreach ($browser in $browserProfiles.GetEnumerator()) {
    $profileBase = $browser.Value
    if (-not (Test-Path $profileBase)) {
        Write-Entry "absent $($browser.Key)"
        continue
    }
    if ($browser.Key -eq 'Firefox') {
        Get-ChildItem $profileBase -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $places = Join-Path $_.FullName "places.sqlite"
            if (Test-Path $places) {
                $sizeMB = [math]::Round((Get-Item $places).Length / 1MB, 2)
                Write-Entry "FOUND  Firefox [$($_.Name)]  $places  (${sizeMB} MB)"
                $bookmarkItems.Add([ordered]@{
                    Browser='Firefox'; Profile=$_.Name; Path=$places; SizeMB=$sizeMB
                })
            }
        }
    } else {
        $profileDirs = @("Default") +
            (Get-ChildItem $profileBase -Directory -Filter "Profile *" -ErrorAction SilentlyContinue |
             Select-Object -ExpandProperty Name)
        foreach ($pd in $profileDirs) {
            $bmFile = Join-Path $profileBase "$pd\Bookmarks"
            if (Test-Path $bmFile) {
                $sizeMB = [math]::Round((Get-Item $bmFile).Length / 1MB, 3)
                Write-Entry "FOUND  $($browser.Key) [$pd]  $bmFile  (${sizeMB} MB)"
                $bookmarkItems.Add([ordered]@{
                    Browser=$browser.Key; Profile=$pd; Path=$bmFile; SizeMB=$sizeMB
                })
            }
        }
    }
}
$report.Sections['Bookmarks'] = $bookmarkItems

# ── 9. Word / Office Templates ────────────────────────────────────────────────
Write-Section "9. WORD / OFFICE TEMPLATES"
$templateItems = [System.Collections.Generic.List[object]]::new()
$templatePaths = @(
    "$env:APPDATA\Microsoft\Templates",
    "$env:APPDATA\Microsoft\Word\STARTUP",
    "$env:USERPROFILE\Documents\Custom Office Templates",
    "$env:USERPROFILE\Documents\Office Custom Templates"
)
foreach ($tp in $templatePaths) {
    if (Test-Path $tp) {
        Get-ChildItem $tp -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -match '\.(dotx|dotm|dot|xltx|xltm|potx|potm)$' } |
            ForEach-Object {
                Write-Entry "$($_.FullName)  ($([math]::Round($_.Length/1KB,1)) KB)"
                $templateItems.Add([ordered]@{
                    Path=$_.FullName; SizeKB=[math]::Round($_.Length/1KB,1)
                })
            }
    }
}
Write-Entry ""
Write-Entry "Total templates: $($templateItems.Count)"
$report.Sections['WordTemplates'] = $templateItems

# ── 10. Outlook Signatures ────────────────────────────────────────────────────
Write-Section "10. OUTLOOK SIGNATURES"
$sigItems = [System.Collections.Generic.List[object]]::new()
$sigPath  = "$env:APPDATA\Microsoft\Signatures"
if (Test-Path $sigPath) {
    $sigs = Get-ChildItem $sigPath -ErrorAction SilentlyContinue
    foreach ($sig in $sigs) {
        Write-Entry $sig.Name
        $sigItems.Add([ordered]@{
            Name=$sig.Name; Path=$sig.FullName; IsDirectory=$sig.PSIsContainer
        })
    }
    Write-Entry ""
    Write-Entry "Signature folder: $sigPath  ($($sigs.Count) items)"
} else {
    Write-Entry "No signatures folder found at: $sigPath"
}
$report.Sections['OutlookSignatures'] = $sigItems

# ── 11. Adobe Preferences ─────────────────────────────────────────────────────
Write-Section "11. ADOBE PREFERENCES"
$adobeItems = [System.Collections.Generic.List[object]]::new()
$adobePaths = @(
    "$env:APPDATA\Adobe",
    "$env:LOCALAPPDATA\Adobe"
)
foreach ($ap in $adobePaths) {
    if (Test-Path $ap) {
        $size    = (Get-ChildItem $ap -Recurse -File -ErrorAction SilentlyContinue |
                    Measure-Object -Property Length -Sum).Sum
        $sizeMB  = [math]::Round($size / 1MB, 2)
        $subDirs = Get-ChildItem $ap -Directory -ErrorAction SilentlyContinue |
                   Select-Object -ExpandProperty Name
        Write-Entry "FOUND  $ap  (${sizeMB} MB)"
        Write-Entry "       Products: $($subDirs -join ', ')"
        $adobeItems.Add([ordered]@{ Path=$ap; SizeMB=$sizeMB; Products=$subDirs })
    } else {
        Write-Entry "absent $ap"
    }
}
$report.Sections['Adobe'] = $adobeItems

# ── 12. User Environment Variables ───────────────────────────────────────────
Write-Section "12. USER ENVIRONMENT VARIABLES"
$envItems   = [System.Collections.Generic.List[object]]::new()
$userEnvKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment')
if ($userEnvKey) {
    foreach ($name in ($userEnvKey.GetValueNames() | Sort-Object)) {
        $val  = $userEnvKey.GetValue($name)
        $kind = $userEnvKey.GetValueKind($name)
        Write-Entry "$($name.PadRight(30)) = $val"
        $envItems.Add([ordered]@{ Name=$name; Value=$val; Kind=$kind.ToString() })
    }
    $userEnvKey.Close()
}
Write-Entry ""
Write-Entry "Total user env vars: $($envItems.Count)"
$report.Sections['EnvVars'] = $envItems

# ── 13. Installed Software ────────────────────────────────────────────────────
Write-Section "13. INSTALLED SOFTWARE"
$softwareItems = [System.Collections.Generic.List[object]]::new()
$regPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($rp in $regPaths) {
    Get-ItemProperty $rp -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        ForEach-Object {
            $key = "$($_.DisplayName)|$($_.DisplayVersion)"
            if ($seen.Add($key)) {
                Write-Entry "$($_.DisplayName)  $($_.DisplayVersion)  [$($_.Publisher)]"
                $softwareItems.Add([ordered]@{
                    Name=$_.DisplayName; Version=$_.DisplayVersion
                    Publisher=$_.Publisher; InstallDate=$_.InstallDate
                })
            }
        }
}
$softwareItems = $softwareItems | Sort-Object { $_.Name }
Write-Entry ""
Write-Entry "Total installed: $($softwareItems.Count)"
$report.Sections['InstalledSoftware'] = $softwareItems

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Section "SUMMARY"
$localRepos = ($report.Sections['GitRepos'] | Where-Object { -not $_.InOneDrive }).Count
$localPstCount = ($report.Sections['PSTs'] | Where-Object { -not $_.InOneDrive }).Count
Write-Item "Machine"            $machineName
Write-Item "User"               $env:USERNAME
Write-Item "Claude paths found" "$($report.Sections['Claude'].Count)"
Write-Item "Git repos (local)"  "$localRepos of $($report.Sections['GitRepos'].Count)"
Write-Item "MCP items"          "$($report.Sections['MCP'].Count)"
Write-Item "PS scripts/modules" "$($report.Sections['PowerShell'].Count)"
Write-Item "SA zips (local)"    "$($report.Sections['SAZips'].Count)"
Write-Item "PSTs (local)"       "$localPstCount"
Write-Item "Browser profiles"   "$($report.Sections['Bookmarks'].Count)"
Write-Item "Word templates"     "$($report.Sections['WordTemplates'].Count)"
Write-Item "Outlook signatures" "$($report.Sections['OutlookSignatures'].Count)"
Write-Item "Installed apps"     "$($report.Sections['InstalledSoftware'].Count)"
$lines.Add("")
$lines.Add("Output files written to: $OutputPath")
$lines.Add("  TXT : $(Split-Path $txtFile  -Leaf)")
$lines.Add("  JSON: $(Split-Path $jsonFile -Leaf)")
$lines.Add("")
$lines.Add("NEXT STEP: Run this script on the other source machine, then compare reports.")
$lines.Add("           When ready, run BDM-Export.ps1 on each source machine.")

# ── Write outputs ─────────────────────────────────────────────────────────────
$lines | Set-Content -Path $txtFile  -Encoding UTF8
$report | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFile -Encoding UTF8

Write-Host ""
Write-Host "INVENTORY COMPLETE" -ForegroundColor Green
Write-Host "  TXT : $txtFile"  -ForegroundColor Cyan
Write-Host "  JSON: $jsonFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open the .txt file and review. Then run on the second machine." -ForegroundColor Yellow
