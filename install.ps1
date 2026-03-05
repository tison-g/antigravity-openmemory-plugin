param (
    [string]$AntigravityProjectDir = $pwd.Path,
    [string]$OpenMemoryRepoUrl = "https://github.com/openmemory/openmemory.git",
    [string]$OpenMemoryBranch = "main"
)

Write-Host "=================================="
Write-Host " Antigravity OpenMemory Installer "
Write-Host "=================================="

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$openMemoryDir = Join-Path -Path $scriptDir -ChildPath "OpenMemory"

# 1. Clone OpenMemory
if (-not (Test-Path -Path $openMemoryDir)) {
    Write-Host "Cloning OpenMemory repository..."
    git clone -b $OpenMemoryBranch $OpenMemoryRepoUrl $openMemoryDir
}
else {
    Write-Host "OpenMemory directory already exists. Pulling latest changes..."
    Push-Location $openMemoryDir
    git pull
    Pop-Location
}

# 2. Build OpenMemory
Write-Host "Installing dependencies and building OpenMemory..."
Push-Location $openMemoryDir
npm install
npm run build
Pop-Location

# 3. Setup .env
$envExample = Join-Path -Path $openMemoryDir -ChildPath ".env.example"
$envFile = Join-Path -Path $openMemoryDir -ChildPath ".env"
if (-not (Test-Path -Path $envFile)) {
    if (Test-Path -Path $envExample) {
        Write-Host "Creating default .env file..."
        Copy-Item -Path $envExample -Destination $envFile
    }
    else {
        Write-Host "Warning: No .env.example found. You may need to configure .env manually."
    }
}

# 4. Link Skill to desired Antigravity Project
$targetAgentsDir = Join-Path -Path $AntigravityProjectDir -ChildPath ".agents"
$targetSkillsDir = Join-Path -Path $targetAgentsDir -ChildPath "skills"
$targetSkillJunction = Join-Path -Path $targetSkillsDir -ChildPath "memory-management"
$sourceSkillDir = Join-Path -Path $scriptDir -ChildPath "skills\memory-management"

if (-not (Test-Path -Path $targetSkillsDir)) {
    Write-Host "Creating skills directory in target project: $targetSkillsDir"
    New-Item -ItemType Directory -Path $targetSkillsDir -Force | Out-Null
}

if (Test-Path -Path $targetSkillJunction) {
    Write-Host "Skill mapping already exists at: $targetSkillJunction. Overwriting..."
    Remove-Item -Path $targetSkillJunction -Force -Recurse
}

Write-Host "Linking memory-management skill to target project..."
# PowerShell equivalent of mklink /J
New-Item -ItemType Junction -Path $targetSkillJunction -Target $sourceSkillDir -Force | Out-Null

Write-Host ""
Write-Host "=== Installation Complete! ==="
Write-Host "Next Steps:"
Write-Host "1. Open your Antigravity global MCP config (usually ~/.gemini/antigravity/mcp_config.json)"
Write-Host "2. Add the following stdio server configuration:"
Write-Host ""
Write-Host '    "openmemory": {'
Write-Host '      "type": "stdio",'
Write-Host '      "command": "node",'
Write-Host "      `"args`": [`"${openMemoryDir.Replace('\','/')}/packages/openmemory-js/bin/opm.js`", `"mcp`"]"
Write-Host '    }'
Write-Host ""
Write-Host "3. Restart Antigravity."
