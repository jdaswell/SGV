# Deploy-AgentFolderTemplates.ps1
# Creates the AGENT_FOLDER_TEMPLATE skeleton in 00_BDM_TEMPLATES
# and stubs the three template files. Replace stub content with the
# real .md files from this package after the script runs.
# Safe to re-run — uses -Force on folder creation, skips existing files.

[CmdletBinding()]
param(
    [string]$BDMRoot = "$env:USERPROFILE\OneDrive - JDA\JDA BDM CLAUDE FILES",
    [string]$TemplatesDir = "00_BDM_TEMPLATES"
)

$ErrorActionPreference = "Stop"

# --- Paths ---
$templateBase   = Join-Path $BDMRoot $TemplatesDir
$agentTemplate  = Join-Path $templateBase "AGENT_FOLDER_TEMPLATE"
$handoffsDir    = Join-Path $agentTemplate "HANDOFFS"
$contextFile    = Join-Path $agentTemplate "CONTEXT.md"
$todoFile       = Join-Path $agentTemplate "TODO.md"
$gitkeep        = Join-Path $handoffsDir ".gitkeep"

# --- Validate BDM root exists ---
if (-not (Test-Path $BDMRoot)) {
    Write-Error "BDM root not found: $BDMRoot`nCheck that OneDrive is synced and the path is correct."
    exit 1
}

Write-Host "`n[BDM Orchestrator] Deploying agent folder templates..." -ForegroundColor Cyan
Write-Host "Target: $templateBase`n"

# --- Create folder skeleton ---
foreach ($dir in @($agentTemplate, $handoffsDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  Exists (skipped): $dir"
    }
}

# --- Create .gitkeep in HANDOFFS ---
if (-not (Test-Path $gitkeep)) {
    New-Item -ItemType File -Path $gitkeep -Force | Out-Null
    Write-Host "  Created: $gitkeep" -ForegroundColor Green
}

# --- Stub CONTEXT.md ---
if (-not (Test-Path $contextFile)) {
    @"
# Agent Context — [AGENT_ROLE] | [CASE_NAME]
# STUB — Replace with content from AGENT_CONTEXT_TEMPLATE.md
"@ | Set-Content -Path $contextFile -Encoding UTF8
    Write-Host "  Stubbed: $contextFile" -ForegroundColor Yellow
} else {
    Write-Host "  Exists (skipped): $contextFile"
}

# --- Stub TODO.md ---
if (-not (Test-Path $todoFile)) {
    @"
# Agent TODO — [AGENT_ROLE] | [CASE_NAME]
# STUB — Replace with content from AGENT_TODO_TEMPLATE.md
"@ | Set-Content -Path $todoFile -Encoding UTF8
    Write-Host "  Stubbed: $todoFile" -ForegroundColor Yellow
} else {
    Write-Host "  Exists (skipped): $todoFile"
}

Write-Host "`n[Done] Template skeleton created at:" -ForegroundColor Cyan
Write-Host "  $agentTemplate`n"
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Open AGENT_FOLDER_TEMPLATE\ in File Explorer"
Write-Host "  2. Replace CONTEXT.md stub with content from AGENT_CONTEXT_TEMPLATE.md"
Write-Host "  3. Replace TODO.md stub with content from AGENT_TODO_TEMPLATE.md"
Write-Host "  4. Copy the HANDOFF_TEMPLATE.md from this package into 00_BDM_TEMPLATES\"
Write-Host "  5. Open bdm-orchestrator\SKILL.md and paste the SKILL_PATCH.md content"
Write-Host "  6. Restart Claude Desktop"
Write-Host "  7. Validate on Robinson v. CleanBlast`n"
