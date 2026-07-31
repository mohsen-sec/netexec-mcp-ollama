```markdown
# 🔧 Troubleshooting Guide

> **Having issues?** This guide covers the most common problems and their solutions.

---

## 📑 Quick Navigation
- [SSH Connection Issues](#-ssh-connection-issues)
- [MCP Server Issues](#-mcp-server-issues)
- [Ollama Issues](#-ollama-issues)
- [Tools Not Recognized](#-tools-not-recognized)
- [Windows-Specific Issues](#-windows-specific-issues)
- [Python Issues](#-python-issues)
- [Reporting Issues](#-reporting-issues)
- [Logging](#-logging)
- [Quick Fix Checklist](#-quick-fix-checklist)

---

## 🔌 SSH Connection Issues

### ❌ "Connection refused" or "Operation timed out"

**Symptoms:**
- SSH connection fails when starting the MCP client
- Error: `Error: connect ECONNREFUSED 192.168.1.100:22`
- Error: `ssh: connect to host 192.168.1.100 port 22: Connection timed out`

**Solutions:**

| Step | Action |
|------|--------|
| 1 | Check SSH service on Kali: `sudo systemctl status ssh` |
| 2 | Start SSH: `sudo systemctl start ssh` |
| 3 | Enable on boot: `sudo systemctl enable ssh` |
| 4 | Check firewall: `sudo ufw status` |
| 5 | Allow SSH: `sudo ufw allow 22` |
| 6 | Test manually: `ssh -v kali@192.168.1.100` |
| 7 | Verify IP: `ip a | grep inet` |
| 8 | Test connectivity: `ping 192.168.1.100` |

---

### ❌ "Permission denied (publickey,password)"

**Symptoms:**
- Error: `Permission denied (publickey,password)`
- SSH asks for password even with key configured

**Solutions:**

**1. Generate SSH keys (if missing):**
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

**2. Copy public key to Kali:**

| Method | Command |
|--------|---------|
| Windows | `type C:\Users\%USERNAME%\.ssh\id_rsa.pub | ssh kali@192.168.1.100 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"` |
| Linux/macOS | `ssh-copy-id kali@192.168.1.100` |

**3. Fix permissions on Kali:**
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

**4. Verify SSH config:**
```bash
sudo nano /etc/ssh/sshd_config
```
Ensure these are set:
```
PubkeyAuthentication yes
PasswordAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

Then restart: `sudo systemctl restart ssh`

---

## 🖥️ MCP Server Issues

### ❌ "Cannot find module"

**Symptoms:**
- Error: `Error: Cannot find module 'C:/MCP-Projects/sec-netexec-mcp/dist/index.js'`
- MCP server fails to start

**Solutions:**

```bash
# 1. Navigate to project directory
cd C:\MCP-Projects\sec-netexec-mcp

# 2. Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# 3. Rebuild
npm run build

# 4. Verify file exists
ls dist/index.js
```

**Path requirements:**
- ✅ Use **forward slashes** (`/`) on Windows
- ✅ Use **absolute paths**, not relative
- ✅ Correct: `"C:/MCP-Projects/sec-netexec-mcp/dist/index.js"`
- ❌ Incorrect: `"C:\MCP-Projects\sec-netexec-mcp\dist\index.js"`

---

### ❌ "MCP Server not connecting"

**Symptoms:**
- No "Connected to MCP server" message
- Tools not appearing in ollmcp
- Error: `Failed to connect to MCP server`

**Solutions:**

| Check | Command/Action |
|-------|----------------|
| JSON syntax | Validate at [jsonlint.com](https://jsonlint.com/) |
| Node.js version | `node --version` (should be 18+) |
| Debug mode | `ollmcp --servers-json ./mcp-config.json --model llama3.2 --debug` |
| SSH manually | `ssh -v kali@192.168.1.100` |
| Firewall | Ensure Windows firewall allows Node.js |

---

## 🦙 Ollama Issues

### ❌ "Ollama is not running"

**Symptoms:**
- Error: `connect ECONNREFUSED 127.0.0.1:11434`
- Model not responding
- Ollama not found in system tray

**Solutions:**

**Start Ollama:**

| OS | Action |
|----|--------|
| Windows | Start menu > Ollama |
| Linux | `ollama serve` |
| macOS | Applications > Ollama |

**Check service status:**
```bash
# Linux
systemctl status ollama
sudo systemctl start ollama

# Windows
Get-Service -Name "Ollama"
Start-Service -Name "Ollama"
```

**Test API:**
```bash
curl http://localhost:11434
# Should return: "Ollama is running"
```

---

### ❌ "Model not found"

**Symptoms:**
- Error: `model 'llama3.2' not found`
- Ollama fails to load model

**Solutions:**

```bash
# Download model
ollama pull llama3.2

# List available models
ollama list

# Try alternative models
ollama pull phi        # Small, fast (2.3GB)
ollama pull mistral    # Medium (4.1GB)
ollama pull tinyllama  # Very small (637MB)
```

**Check disk space:**
```bash
# Windows
wmic logicaldisk where drivetype=3 get deviceid,size,freespace

# Linux
df -h
```

---

### ❌ "Model is too slow"

**Symptoms:**
- Responses take a long time
- System becomes sluggish
- High CPU/RAM usage

**Solutions:**

| Solution | Command |
|----------|---------|
| Use smaller model | `ollama pull phi` |
| Lower context size | `ollama run llama3.2 --ctx-size 2048` |
| Limit threads | `ollama run llama3.2 --num-thread 4` |
| Enable GPU | `ollama run llama3.2 --num-gpu 1` |
| Close apps | Free up RAM (need at least 8GB) |

---

## 🛠️ Tools Not Recognized

### ❌ "Tools not detected in ollmcp"

**Symptoms:**
- No tools appear after connection
- "Use nxc_smb" gives error about unknown tool
- MCP server connected but tools not showing

**Solutions:**

```bash
# 1. Check connection message
# Look for: "Connected to MCP server: netexec"

# 2. Check sec-netexec-mcp logs
cd C:\MCP-Projects\sec-netexec-mcp
node dist/index.js --debug

# 3. Verify SSH connection to Kali
ssh kali@192.168.1.100 "nxc --help"

# 4. Check NetExec installation
which nxc
nxc --version

# 5. Test raw command
# In ollmcp: Use nxc_raw with target "192.168.1.1" and command "smb"
```

---

## 🪟 Windows-Specific Issues

### ❌ "PowerShell script execution disabled"

**Symptoms:**
- Error: `Running scripts is disabled on this system`
- Script fails with execution policy error

**Solutions:**

| Method | Command |
|--------|---------|
| Change policy | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Bypass once | `powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1` |
| Dot source | `. .\scripts\setup-windows.ps1` |

---

### ❌ "Path too long" errors

**Solutions:**

**1. Enable long paths:**
```powershell
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

**2. Use shorter paths:**
```powershell
$projectDir = "C:\MCP"  # Instead of C:\MCP-Projects
```

---

## 🐍 Python Issues

### ❌ "pip not found"

**Solutions:**

| Step | Action |
|------|--------|
| 1 | Ensure Python installed with "Add to PATH" |
| 2 | Reinstall Python with PATH option checked |
| 3 | Use Python module: `python -m pip install ollmcp` |

---

### ❌ "ollmcp not found after pip install"

**Solutions:**

```bash
# Check Python location
python -c "import sys; print(sys.executable)"

# Add Scripts directory to PATH
# Windows: Add C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python3x\Scripts to PATH

# Use Python module directly
python -m ollmcp --servers-json ./mcp-config.json --model llama3.2
```

---

## 🐛 Reporting Issues

### What to Include

**1. System Information:**
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

**2. Error Logs:**
- Copy the full error message
- Include stack trace if available
- Run with `--debug` flag and include output

**3. Configuration:**
- `mcp-config.json` (remove sensitive info)
- What commands you tried
- Model being used

**4. Steps to Reproduce:**
- Clear step-by-step instructions
- What was expected vs actual result

---

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

| OS | Path |
|----|------|
| Windows | `%APPDATA%/ollama/logs/` |
| Windows | `%USERPROFILE%/AppData/Local/ollama/` |
| Linux | `~/.ollama/logs/` |
| Linux | `/var/log/ollama/` |

**Redirect MCP logs:**
```bash
ollmcp ... > mcp.log 2>&1
```

### Verbose Logging

```bash
# Enable verbose output in ollmcp
$env:DEBUG="*"
ollmcp --servers-json ./mcp-config.json --model llama3.2

# Enable Node.js debugging
node --trace-warnings --trace-deprecation dist/index.js

# Log SSH session
ssh -vvv kali@192.168.1.100
```

---

## ✅ Quick Fix Checklist

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

---

## 📞 Getting Help

| Resource | Link |
|----------|------|
| GitHub Issues | Search existing issues first |
| Create New Issue | Include all info from "Reporting Issues" |
| NetExec Discord | Community support |
| NetExec Wiki | [Documentation](https://github.com/Pennyw0rth/NetExec/wiki) |
| Ollama Docs | [Ollama Documentation](https://ollama.com/docs) |

---

**Last Updated:** July 2026
```

---

## ✨ What Was Improved

| Element | Before | After |
|---------|--------|-------|
| **Emojis** | Few | Many for visual hierarchy |
| **Tables** | No | Yes for structured data |
| **Code Blocks** | Mixed | Consistent with syntax highlighting |
| **Sections** | Plain | Interactive with checkboxes |
| **Navigation** | Missing | Table of contents |
| **Visual Hierarchy** | Flat | Clear header levels |
| **Badges** | No | Status indicators |
| **Callouts** | No | Blockquotes for emphasis |
