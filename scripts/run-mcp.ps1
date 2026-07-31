#!/usr/bin/env pwsh
# Run the MCP Client with Ollama

param(
    [string]$ConfigFile = "C:\MCP-Projects\mcp-config.json",
    [string]$Model = "llama3.2",
    [switch]$Debug
)

Write-Host "🚀 Starting NetExec MCP Client with Ollama" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

# Check if config file exists
if (-not (Test-Path $ConfigFile)) {
    Write-Host "❌ Config file not found: $ConfigFile" -ForegroundColor Red
    Write-Host "Please run setup-windows.ps1 first or specify correct path." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage: .\run-mcp.ps1 [-ConfigFile <path>] [-Model <model-name>] [-Debug]" -ForegroundColor Gray
    Write-Host "Example: .\run-mcp.ps1 -ConfigFile C:\my-config.json -Model mistral -Debug" -ForegroundColor Gray
    exit 1
}

Write-Host "📁 Config file: $ConfigFile" -ForegroundColor Gray
Write-Host "🤖 Model: $Model" -ForegroundColor Gray
if ($Debug) { Write-Host "🐛 Debug mode: ON" -ForegroundColor Yellow }

# Check if Ollama is running
Write-Host "`n🦙 Checking Ollama status..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:11434" -UseBasicParsing -TimeoutSec 3
    Write-Host "✅ Ollama is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Ollama is not running" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Ollama:" -ForegroundColor Yellow
    Write-Host "  - Windows: Start menu > Ollama" -ForegroundColor White
    Write-Host "  - System tray: Look for Ollama icon" -ForegroundColor White
    Write-Host "  - Or run: ollama serve" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to continue anyway..." -ForegroundColor Gray
    Read-Host
}

# Check if model exists
Write-Host "`n🔍 Checking model: $Model..." -ForegroundColor Yellow
try {
    $models = ollama list 2>&1
    if ($LASTEXITCODE -eq 0) {
        if ($models -match $Model) {
            Write-Host "✅ Model '$Model' is available locally" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Model '$Model' not found locally" -ForegroundColor Yellow
            Write-Host "📥 Downloading model: ollama pull $Model" -ForegroundColor Yellow
            Write-Host "This may take a few minutes depending on your internet connection..." -ForegroundColor Gray
            ollama pull $Model
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Model downloaded successfully!" -ForegroundColor Green
            } else {
                Write-Host "❌ Failed to download model" -ForegroundColor Red
                Write-Host "Try: ollama pull $Model manually" -ForegroundColor Yellow
                exit 1
            }
        }
    } else {
        Write-Host "⚠️ Could not check models (ollama command failed)" -ForegroundColor Yellow
        Write-Host "Attempting to pull model anyway..." -ForegroundColor Gray
        ollama pull $Model
    }
} catch {
    Write-Host "⚠️ Error checking model: $_" -ForegroundColor Yellow
    Write-Host "Attempting to pull model anyway..." -ForegroundColor Gray
    ollama pull $Model
}

# Check if ollmcp is installed
Write-Host "`n🔧 Checking ollmcp installation..." -ForegroundColor Yellow
try {
    $ollmcpCheck = Get-Command ollmcp -ErrorAction Stop
    Write-Host "✅ ollmcp is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ ollmcp is not installed" -ForegroundColor Red
    Write-Host "Install it with: pip install ollmcp" -ForegroundColor Yellow
    Write-Host "Or run setup-windows.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Validate config file JSON
Write-Host "`n🔍 Validating config file..." -ForegroundColor Yellow
try {
    $configContent = Get-Content $ConfigFile -Raw
    $configJson = $configContent | ConvertFrom-Json
    Write-Host "✅ Config file is valid JSON" -ForegroundColor Green
    
    # Check if netexec server is configured
    if ($configJson.mcpServers.netexec) {
        Write-Host "✅ NetExec MCP server configured" -ForegroundColor Green
        if ($configJson.mcpServers.netexec.env.KALI_HOST) {
            Write-Host "   Target Kali: $($configJson.mcpServers.netexec.env.KALI_HOST)" -ForegroundColor Gray
        }
        if ($configJson.mcpServers.netexec.env.SSH_USER) {
            Write-Host "   SSH User: $($configJson.mcpServers.netexec.env.SSH_USER)" -ForegroundColor Gray
        }
    } else {
        Write-Host "⚠️ NetExec MCP server not found in config" -ForegroundColor Yellow
        Write-Host "Please check your config file format" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Invalid JSON in config file" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Please fix the config file and try again" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🚀 Launching MCP Client..." -ForegroundColor Green
Write-Host "Press Ctrl+C to exit" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Example commands:" -ForegroundColor Yellow
Write-Host "   Hello, how are you?" -ForegroundColor Gray
Write-Host "   Use nxc_smb to scan 192.168.1.0/24" -ForegroundColor Gray
Write-Host "   List all available modules" -ForegroundColor Gray
Write-Host ""

# Build the command
$commandArgs = @("--servers-json", $ConfigFile, "--model", $Model)
if ($Debug) {
    $commandArgs += "--debug"
}

# Run the MCP client
try {
    & ollmcp $commandArgs
} catch {
    Write-Host ""
    Write-Host "❌ Error running ollmcp: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "1. Check that Ollama is running" -ForegroundColor White
    Write-Host "2. Verify your SSH connection to Kali: ssh -v $($configJson.mcpServers.netexec.env.SSH_USER)@$($configJson.mcpServers.netexec.env.KALI_HOST)" -ForegroundColor White
    Write-Host "3. Check the config file path: $ConfigFile" -ForegroundColor White
    Write-Host "4. Try running with -Debug for more details" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}
