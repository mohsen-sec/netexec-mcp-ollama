# 📄 troubleshooting.md

Copy and paste the following content into a file named `troubleshooting.md` in the `docs/` directory of your repository.

```markdown
# 🔧 Troubleshooting Guide

## Common Issues and Solutions

### SSH Connection Issues

#### "Connection refused" or "Operation timed out"

**Symptoms**:
- SSH connection fails when starting the MCP client
- Error: `Error: connect ECONNREFUSED 192.168.1.100:22`
- Error: `ssh: connect to host 192.168.1.100 port 22: Connection timed out`

**Solutions**:

1. **Check SSH service on Kali**:
   ```bash
   sudo systemctl status ssh
   sudo systemctl start ssh
   sudo systemctl enable ssh
   ```

2. **Verify firewall settings**:
   ```bash
   sudo ufw status
   sudo ufw allow 22
   sudo ufw disable  # Temporarily disable for testing
   ```

3. **Test SSH manually**:
   ```bash
   ssh -v kali@192.168.1.100
   ```

4. **Verify IP address**:
   ```bash
   ip a | grep inet
   # Check if IP matches your config
   ```

5. **Check if Kali is reachable**:
   ```bash
   ping 192.168.1.100
   ```

#### "Permission denied (publickey,password)"

**Symptoms**:
- Error: `Permission denied (publickey,password)`
- SSH asks for password even with key configured

**Solutions**:

1. **Regenerate SSH keys**:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

2. **Copy public key to Kali**:
   ```bash
   # On local machine
   type C:\Users\YourUsername\.ssh\id_rsa.pub | ssh kali@192.168.1.100 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
   
   # Or using ssh-copy-id (Linux/macOS)
   ssh-copy-id kali@192.168.1.100
   ```

3. **Check file permissions on Kali**:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/id_rsa  # Private key on local machine
   ```

4. **Verify SSH config on Kali**:
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Ensure these are set:
   # PubkeyAuthentication yes
   # PasswordAuthentication yes  # (if using password)
   # AuthorizedKeysFile .ssh/authorized_keys
   
   sudo systemctl restart ssh
   ```

### MCP Server Issues

#### "Cannot find module"

**Symptoms**:
- Error: `Error: Cannot find module 'C:/MCP-Projects/sec-netexec-mcp/dist/index.js'`
- MCP server fails to start

**Solutions**:

1. Navigate to sec-netexec-mcp directory:
   ```bash
   cd C:\MCP-Projects\sec-netexec-mcp
   ```

2. Reinstall dependencies:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   npm run build
   ```

3. Verify `index.js` exists:
   ```bash
   ls dist/index.js
   # Should show: dist/index.js
   ```

4. Check path in config file:
   ```json
   {
     "args": ["C:/MCP-Projects/sec-netexec-mcp/dist/index.js"]
   }
   ```
   - Use **forward slashes** (`/`) on Windows
   - Use **absolute paths** not relative

#### "MCP Server not connecting"

**Symptoms**:
- No "Connected to MCP server" message
- Tools not appearing in ollmcp
- Error: `Failed to connect to MCP server`

**Solutions**:

1. **Check config file syntax**:
   - Verify JSON syntax using [jsonlint.com](https://jsonlint.com/)
   - Use forward slashes (`/`) in paths on Windows
   - Validate environment variables

2. **Check Node.js version**:
   ```bash
   node --version  # Should be 18+
   ```

3. **Test with debug mode**:
   ```bash
   ollmcp --servers-json ./mcp-config.json --model llama3.2 --debug
   ```

4. **Verify SSH connection**:
   ```bash
   ssh -v kali@192.168.1.100
   ```

5. **Check firewall**:
   - Ensure Windows firewall allows Node.js
   - Check if antivirus is blocking

### Ollama Issues

#### "Ollama is not running"

**Symptoms**:
- Error: `connect ECONNREFUSED 127.0.0.1:11434`
- Model not responding
- Ollama not found in system tray

**Solutions**:

1. **Start Ollama manually**:
   - Windows: Start menu > Ollama
   - Linux: `ollama serve`
   - macOS: Applications > Ollama

2. **Check service status**:
   ```bash
   # Linux
   systemctl status ollama
   sudo systemctl start ollama
   
   # Windows
   Get-Service -Name "Ollama"
   Start-Service -Name "Ollama"
   ```

3. **Test API endpoint**:
   ```bash
   curl http://localhost:11434
   # Should return: "Ollama is running"
   ```

4. **Check for port conflicts**:
   ```bash
   netstat -ano | findstr :11434
   # If another service uses port 11434, change Ollama port
   ```

#### "Model not found"

**Symptoms**:
- Error: `model 'llama3.2' not found`
- Ollama fails to load model

**Solutions**:

1. **Download the model**:
   ```bash
   ollama pull llama3.2
   ```

2. **List available models**:
   ```bash
   ollama list
   ```

3. **Try a different model**:
   ```bash
   ollama pull phi  # Smaller model, faster
   ollama pull mistral  # Medium model
   ollama pull tinyllama  # Very small model
   ```

4. **Check disk space**:
   ```bash
   # Windows
   wmic logicaldisk where drivetype=3 get deviceid,size,freespace
   
   # Linux
   df -h
   ```

#### "Model is too slow"

**Symptoms**:
- Responses take a long time
- System becomes sluggish
- High CPU/RAM usage

**Solutions**:

1. **Use smaller model**:
   ```bash
   ollama pull phi        # 2.3GB
   ollama pull tinyllama  # 637MB
   ollama pull llama3.2   # 2.0GB (balanced)
   ```

2. **Check system resources**:
   - Close other applications
   - Verify RAM usage (should have at least 8GB)
   - Check CPU/GPU utilization

3. **Optimize Ollama settings**:
   ```bash
   # Set lower context size
   ollama run llama3.2 --ctx-size 2048
   
   # Limit number of threads
   ollama run llama3.2 --num-thread 4
   ```

4. **Enable GPU acceleration** (if available):
   ```bash
   # NVIDIA GPU
   ollama run llama3.2 --num-gpu 1
   ```

### Tools Not Recognized

#### "Tools not detected in ollmcp"

**Symptoms**:
- No tools appear after connection
- "Use nxc_smb" gives error about unknown tool
- MCP server connected but tools not showing

**Solutions**:

1. **Check connection message**:
   - Look for: "Connected to MCP server: netexec"
   - If not shown, server not connected

2. **Verify module exports**:
   ```bash
   # Check sec-netexec-mcp logs
   cd C:\MCP-Projects\sec-netexec-mcp
   node dist/index.js --debug
   ```

3. **Verify SSH connection to Kali**:
   ```bash
   ssh kali@192.168.1.100 "nxc --help"
   ```

4. **Check NetExec installation on Kali**:
   ```bash
   which nxc
   nxc --version
   ```

5. **Test with raw command**:
   ```
   Use nxc_raw with target "192.168.1.1" and command "smb"
   ```

### Windows-Specific Issues

#### "PowerShell script execution disabled"

**Symptoms**:
- Error: `Running scripts is disabled on this system`
- Script fails with execution policy error

**Solutions**:

1. **Run as Administrator and change policy**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Bypass for current session**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1
   ```

3. **Run script with dot sourcing**:
   ```powershell
   . .\scripts\setup-windows.ps1
   ```

#### "Path too long" errors

**Solutions**:
1. Enable long paths in Windows:
   ```powershell
   New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
   ```

2. Use shorter directory paths:
   ```powershell
   $projectDir = "C:\MCP"
   ```

### Python Issues

#### "pip not found"

**Solutions**:
1. Ensure Python is installed with "Add to PATH"
2. Reinstall Python with PATH option checked
3. Use Python's `-m pip`:
   ```bash
   python -m pip install ollmcp
   ```

#### "ollmcp not found after pip install"

**Solutions**:
1. Check Python scripts directory in PATH:
   ```bash
   python -c "import sys; print(sys.executable)"
   # Add Scripts directory to PATH
   ```

2. Use Python module directly:
   ```bash
   python -m ollmcp --servers-json ./mcp-config.json --model llama3.2
   ```

## 🐛 Reporting Issues

When reporting issues, please include:

1. **System Information**:
   ```bash
   # Windows
   systeminfo | findstr /B /C:"OS Name" /C:"System Type" /C:"Total Physical Memory"
   node --version
   python --version
   ollama --version
   nxc --version
   
   # Linux
   uname -a
   node --version
   python --version
   ollama --version
   nxc --version
   ```

2. **Error Logs**:
   - Copy the full error message
   - Include stack trace if available
   - Run with `--debug` flag and include output

3. **Configuration**:
   - mcp-config.json (remove sensitive info)
   - What commands you tried
   - Model being used

4. **Steps to reproduce**:
   - Clear step-by-step instructions
   - What was expected vs actual result

## 📝 Logging

### Enable Debug Logging

```bash
# For ollmcp
ollmcp --servers-json ./mcp-config.json --model llama3.2 --debug

# For sec-netexec-mcp
cd C:\MCP-Projects\sec-netexec-mcp
node dist/index.js --debug

# For NetExec
nxc --verbose [command]
```

### Log File Locations

```bash
# Windows
%APPDATA%/ollama/logs/
%USERPROFILE%/AppData/Local/ollama/

# Linux
~/.ollama/logs/
/var/log/ollama/

# MCP logs
# Typically output to terminal, redirect to file:
ollmcp ... > mcp.log 2>&1
```

### Verbose Logging

1. **Enable verbose output** in ollmcp:
   ```bash
   $env:DEBUG="*"
   ollmcp --servers-json ./mcp-config.json --model llama3.2
   ```

2. **Enable Node.js debugging**:
   ```bash
   node --trace-warnings --trace-deprecation dist/index.js
   ```

3. **Log SSH session**:
   ```bash
   ssh -vvv kali@192.168.1.100
   ```

## 🚀 Quick Fix Checklist

If things aren't working, try these in order:

- [ ] Restart Ollama
- [ ] Rebuild sec-netexec-mcp (`npm install && npm run build`)
- [ ] Check SSH connection manually
- [ ] Verify config file JSON syntax
- [ ] Check paths use forward slashes (`/`)
- [ ] Ensure Node.js 18+ is installed
- [ ] Test Python is in PATH
- [ ] Check Windows firewall
- [ ] Run PowerShell as Administrator
- [ ] Update all packages: `npm update`, `pip install --upgrade ollmcp`

## 📞 Getting Help

If you still need help:

1. **Check GitHub Issues**: Search existing issues first
2. **Create a New Issue**: Include all information from "Reporting Issues" section
3. **Community**: Check the NetExec Discord or GitHub Discussions
4. **Documentation**: Read the [NetExec Wiki](https://github.com/Pennyw0rth/NetExec/wiki)

---

**Last Updated**: July 2026
```

---

## 📝 Instructions for GitHub

1. In your repository, click **"Add file"** → **"Create new file"**
2. Navigate to the docs directory: type `docs/troubleshooting.md` as the file name
3. Copy and paste the content above
4. Click **"Commit new file"**

---

## 📋 Section Overview

| Section | Description |
|---------|-------------|
| **SSH Connection Issues** | Solutions for SSH connectivity problems |
| **MCP Server Issues** | Fixes for MCP server setup and connection |
| **Ollama Issues** | Troubleshooting for Ollama installation and models |
| **Tools Not Recognized** | When MCP tools don't appear in ollmcp |
| **Windows-Specific Issues** | PowerShell and Windows-specific problems |
| **Python Issues** | Python installation and package problems |
| **Reporting Issues** | What to include when filing bugs |
| **Logging** | How to enable debug logging |
| **Quick Fix Checklist** | Step-by-step troubleshooting sequence |

---

## 🔗 Related Files

- [README.md](../README.md) - Main documentation
- [advanced-configuration.md](advanced-configuration.md) - Advanced setup options
- [../scripts/setup-windows.ps1](../scripts/setup-windows.ps1) - Windows setup script
- [../scripts/setup-kali.sh](../scripts/setup-kali.sh) - Kali setup script
- [../scripts/run-mcp.ps1](../scripts/run-mcp.ps1) - MCP client runner
