#!/usr/bin/env pwsh
# Windows Setup Script for NetExec MCP with Ollama

Write-Host "🚀 Starting NetExec MCP Setup for Windows" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Check prerequisites
function Test-Prerequisite {
    param($Command, $Name)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        Write-Host "✅ $Name is installed" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ $Name is not installed" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n📋 Checking prerequisites..." -ForegroundColor Yellow
$allGood = $true

if (-not (Test-Prerequisite -Command "node" -Name "Node.js")) { $allGood = $false }
if (-not (Test-Prerequisite -Command "npm" -Name "npm")) { $allGood = $false }
if (-not (Test-Prerequisite -Command "python" -Name "Python")) { $allGood = $false }
if (-not (Test-Prerequisite -Command "pip" -Name "pip")) { $allGood = $false }
if (-not (Test-Prerequisite -Command "git" -Name "Git")) { $allGood = $false }

if (-not $allGood) {
    Write-Host "`n❌ Please install missing prerequisites and run this script again." -ForegroundColor Red
    Write-Host "See README.md for installation instructions." -ForegroundColor Yellow
    exit 1
}

# Create project directory
$projectDir = "C:\MCP-Projects"
if (-not (Test-Path $projectDir)) {
    Write-Host "`n📁 Creating project directory: $projectDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
}

# Clone and build sec-netexec-mcp
Write-Host "`n🔧 Setting up sec-netexec-mcp..." -ForegroundColor Yellow
Set-Location $projectDir

if (Test-Path "sec-netexec-mcp") {
    Write-Host "⚠️ sec-netexec-mcp already exists. Updating..." -ForegroundColor Yellow
    Set-Location "sec-netexec-mcp"
    git pull
} else {
    Write-Host "📥 Cloning sec-netexec-mcp repository..." -ForegroundColor Yellow
    git clone https://github.com/schwarztim/sec-netexec-mcp.git
    Set-Location "sec-netexec-mcp"
}

Write-Host "📦 Installing npm dependencies..." -ForegroundColor Yellow
npm install

Write-Host "🏗️ Building project..." -ForegroundColor Yellow
npm run build

Set-Location $projectDir

# Install ollmcp
Write-Host "`n🐍 Installing ollmcp..." -ForegroundColor Yellow
pip install ollmcp --upgrade

# Create example config if it doesn't exist
$configFile = "$projectDir\mcp-config.json"
if (-not (Test-Path $configFile)) {
    Write-Host "`n📝 Creating example configuration file..." -ForegroundColor Yellow
    
    # Try to copy from the repo first
    if (Test-Path "$projectDir\sec-netexec-mcp\config\mcp-config.example.json") {
        Copy-Item "$projectDir\sec-netexec-mcp\config\mcp-config.example.json" $configFile
    } else {
        # Create default config
        $defaultConfig = @{
            mcpServers = @{
                netexec = @{
                    command = "node"
                    args = @("$projectDir/sec-netexec-mcp/dist/index.js")
                    env = @{
                        KALI_HOST = "192.168.1.100"
                        SSH_USER = "kali"
                        SSH_KEY = "$env:USERPROFILE\.ssh\id_rsa"
                    }
                }
            }
        }
        $defaultConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $configFile
    }
    Write-Host "✅ Configuration file created at: $configFile" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Configuration file already exists: $configFile" -ForegroundColor Gray
}

# Check if Ollama is installed
Write-Host "`n🦙 Checking Ollama installation..." -ForegroundColor Yellow
try {
    $ollamaCheck = ollama --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Ollama is installed" -ForegroundColor Green
        
        # Check if any models are installed
        $models = ollama list
        if ($models -match "NAME") {
            Write-Host "📋 Installed models:" -ForegroundColor Gray
            $models | Select-String -Pattern "^\S+" | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
        } else {
            Write-Host "⚠️ No models found. Run: ollama pull llama3.2" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "❌ Ollama is not installed or not in PATH" -ForegroundColor Red
    Write-Host "📥 Download from: https://ollama.com/" -ForegroundColor Yellow
}

Write-Host "`n✅ Setup completed successfully!" -ForegroundColor Green
Write-Host "`n📝 Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit $configFile with your Kali credentials" -ForegroundColor White
Write-Host "2. Install Ollama from https://ollama.com/ (if not installed)" -ForegroundColor White
Write-Host "3. Pull a model: ollama pull llama3.2" -ForegroundColor White
Write-Host "4. Run: .\scripts\run-mcp.ps1" -ForegroundColor White
Write-Host "`n📖 For more details, see README.md" -ForegroundColor Yellow
