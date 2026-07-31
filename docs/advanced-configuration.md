```markdown
# ⚙️ Advanced Configuration Guide

> **Take full control** of your NetExec MCP setup with these advanced configuration options.

---

## 📑 Quick Navigation
- [Custom Ollama Settings](#-custom-ollama-settings)
- [SSH Configuration](#-ssh-configuration)
- [NetExec Advanced Options](#-netexec-advanced-options)
- [Performance Optimization](#-performance-optimization)
- [Security Hardening](#-security-hardening)
- [Custom Scripts](#-custom-scripts)
- [Tool Integration](#-tool-integration)
- [Environment Variables Reference](#-environment-variables-reference)

---

## 🦙 Custom Ollama Settings

### Using Different Models

| Model | Size | Speed | Use Case |
|-------|------|-------|----------|
| `phi` | 2.3GB | ⚡⚡⚡ | Fast, lightweight tasks |
| `tinyllama` | 637MB | ⚡⚡⚡⚡ | Minimal resources |
| `llama3.2` | 2.0GB | ⚡⚡ | Balanced performance |
| `mistral` | 4.1GB | ⚡⚡ | Powerful, general purpose |
| `codellama` | 3.8GB | ⚡⚡ | Code generation |
| `llama3.2:70b` | ~40GB | ⚡ | Maximum capability |

**Pull a model:**
```bash
ollama pull mistral
ollama pull codellama
ollama pull phi
```

### Model Parameters

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `--temperature` | Controls randomness (0-1) | 0.8 | `--temperature 0.7` |
| `--top-p` | Nucleus sampling threshold | 0.9 | `--top-p 0.85` |
| `--top-k` | Top-k sampling | 40 | `--top-k 50` |
| `--repeat-penalty` | Penalize repetition | 1.1 | `--repeat-penalty 1.2` |
| `--ctx-size` | Context window size | 2048 | `--ctx-size 4096` |
| `--num-thread` | CPU threads | Auto | `--num-thread 8` |
| `--num-gpu` | GPU layers | 0 | `--num-gpu 1` |

**Example with custom parameters:**
```bash
ollmcp --servers-json ./mcp-config.json \
  --model llama3.2 \
  --temperature 0.7 \
  --top-p 0.85 \
  --ctx-size 4096
```

### Multiple Models Configuration

Create `ollama-config.json`:

```json
{
  "models": {
    "default": "llama3.2",
    "fast": "phi",
    "powerful": "mistral"
  },
  "settings": {
    "default": {
      "temperature": 0.7,
      "top_p": 0.9
    },
    "fast": {
      "temperature": 0.5,
      "top_p": 0.8,
      "num_thread": 8
    }
  }
}
```

---

## 🔐 SSH Configuration

### Multiple Kali Machines

```json
{
  "mcpServers": {
    "netexec-dev": {
      "command": "node",
      "args": ["/path/to/sec-netexec-mcp/dist/index.js"],
      "env": {
        "KALI_HOST": "192.168.1.100",
        "SSH_USER": "kali",
        "SSH_KEY": "~/.ssh/kali-dev"
      }
    },
    "netexec-prod": {
      "command": "node",
      "args": ["/path/to/sec-netexec-mcp/dist/index.js"],
      "env": {
        "KALI_HOST": "192.168.1.200",
        "SSH_USER": "kali",
        "SSH_KEY": "~/.ssh/kali-prod"
      }
    }
  }
}
```

### SSH Tunneling

```json
{
  "env": {
    "KALI_HOST": "localhost",
    "SSH_USER": "kali",
    "SSH_PORT": "2222",
    "SSH_KEY": "~/.ssh/id_rsa"
  }
}
```

### SSH with Jump Host

```json
{
  "env": {
    "KALI_HOST": "internal-kali",
    "SSH_USER": "kali",
    "SSH_KEY": "~/.ssh/id_rsa",
    "SSH_JUMP_HOST": "bastion.example.com",
    "SSH_JUMP_USER": "jump-user",
    "SSH_JUMP_PORT": "22"
  }
}
```

### SSH Keep-Alive Settings

```json
{
  "env": {
    "SSH_KEEPALIVE_INTERVAL": "60",
    "SSH_KEEPALIVE_COUNT": "3"
  }
}
```

---

## 🛠️ NetExec Advanced Options

### Custom NetExec Path

```json
{
  "env": {
    "NXC_PATH": "/usr/local/bin/nxc",
    "PATH": "/usr/local/bin:$PATH"
  }
}
```

### Protocol-Specific Options

```json
{
  "env": {
    "SMB_TIMEOUT": "60",
    "LDAP_TIMEOUT": "120",
    "WINRM_TIMEOUT": "90",
    "SSH_TIMEOUT": "300",
    "MSSQL_TIMEOUT": "120",
    "RDP_TIMEOUT": "30",
    "WMI_TIMEOUT": "60"
  }
}
```

### Custom Module Directory

```bash
# Export in environment
export NXC_MODULES_PATH=/path/to/custom/modules
```

### Global NetExec Options

```json
{
  "env": {
    "NXC_VERBOSE": "true",
    "NXC_DEBUG": "true",
    "NXC_LOG_FILE": "/var/log/nxc.log",
    "NXC_OUTPUT_FORMAT": "json"
  }
}
```

---

## ⚡ Performance Optimization

### Memory Management

| Setting | Command | Impact |
|---------|---------|--------|
| Limit GPU layers | `--num-gpu 1` | Faster with GPU |
| Limit CPU threads | `--num-thread 4` | Balanced CPU usage |
| Max loaded models | `OLLAMA_MAX_LOADED_MODELS=1` | Lower RAM usage |
| Parallel requests | `OLLAMA_NUM_PARALLEL=2` | Better throughput |

**Example:**
```bash
# Limit Ollama memory usage
ollama run llama3.2 --num-gpu 1 --num-thread 4

# Set environment limits
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_NUM_PARALLEL=2
```

### Caching

| Option | Description | Default |
|--------|-------------|---------|
| `NXC_CACHE` | Enable credential caching | `false` |
| `NXC_CACHE_TTL` | Cache TTL (seconds) | `3600` |
| `NXC_CRED_CACHE` | Enable credential cache | `false` |

**Enable caching:**
```json
{
  "env": {
    "NXC_CACHE": "true",
    "NXC_CACHE_TTL": "7200",
    "NXC_CRED_CACHE": "true"
  }
}
```

### Parallel Execution

```json
{
  "env": {
    "MAX_CONCURRENT": "3",
    "BATCH_SIZE": "10",
    "THREADS": "4"
  }
}
```

### Connection Pooling

```json
{
  "env": {
    "CONNECTION_POOL_SIZE": "5",
    "CONNECTION_TIMEOUT": "30",
    "CONNECTION_RETRY": "3"
  }
}
```

---

## 🔒 Security Hardening

### IP Restrictions

```bash
# Allow only local subnet
sudo ufw allow from 192.168.1.0/24 to any port 22

# Allow specific IP
sudo ufw allow from 10.0.0.100 to any port 22

# Deny all other SSH
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### SSH Hardening

Edit `/etc/ssh/sshd_config` on Kali:

```ini
# Authentication
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers kali

# Security
MaxAuthTries 3
MaxSessions 2
ClientAliveInterval 300
ClientAliveCountMax 0
X11Forwarding no
AllowTcpForwarding no

# Logging
LogLevel VERBOSE
```

**Apply changes:**
```bash
sudo systemctl restart ssh
```

### Audit Logging

```bash
# Enable comprehensive logging
export NXC_DEBUG=true
export NXC_LOG_FILE=/var/log/nxc.log
export NXC_VERBOSE=true
```

**Log rotation** (`/etc/logrotate.d/netexec`):
```
/var/log/nxc.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 644 root root
    postrotate
        systemctl reload nxc >/dev/null 2>&1 || true
    endscript
}
```

### Command Sanitization

```json
{
  "env": {
    "ALLOWED_COMMANDS": "smb,ldap,winrm,ssh,mssql,rdp,wmi",
    "BLOCKED_COMMANDS": "rm,dd,mkfs,shutdown,reboot",
    "COMMAND_WHITELIST": "true"
  }
}
```

---

## 📜 Custom Scripts

### Auto-Response Script

Create `scripts/auto-response.sh`:

```bash
#!/bin/bash
# Auto-respond to common prompts

case "$1" in
  "ready")
    echo "✅ NetExec MCP ready for commands"
    ;;
  "status")
    echo "📊 Status: Online"
    echo "📅 Date: $(date)"
    ;;
  "scan")
    echo "🔍 Starting scan on $2"
    nxc smb $2
    ;;
  *)
    echo "❌ Command not recognized"
    ;;
esac
```

**Make executable:**
```bash
chmod +x scripts/auto-response.sh
```

### Scheduled Scans

**Add to crontab:**
```bash
crontab -e
```

```cron
# Daily scan at 2 AM
0 2 * * * /path/to/auto-response.sh scan 192.168.1.0/24

# Weekly full scan on Sunday at 3 AM
0 3 * * 0 /path/to/full-scan.sh

# Hourly status check
0 * * * * /path/to/auto-response.sh status > /dev/null 2>&1
```

### Webhook Notifications

```json
{
  "env": {
    "WEBHOOK_URL": "https://hooks.slack.com/services/xxx",
    "WEBHOOK_EVENTS": "scan_complete,error,credential_found",
    "WEBHOOK_HEADERS": "Content-Type: application/json"
  }
}
```

**Webhook payload example:**
```json
{
  "event": "scan_complete",
  "timestamp": "2026-07-31T10:00:00Z",
  "hosts": 45,
  "findings": 12
}
```

---

## 🔗 Tool Integration

### BloodHound Integration

```bash
# Configure NetExec to work with BloodHound
export BLOODHOUND_INGESTOR=/opt/BloodHound/Collectors/SharpHound.ps1
```

**In mcp-config.json:**
```json
{
  "env": {
    "BLOODHOUND_COLLECTION": "All",
    "BLOODHOUND_OUTPUT": "/tmp/bloodhound",
    "BLOODHOUND_ZIP": "true",
    "BLOODHOUND_COMPRESS": "true"
  }
}
```

### Metasploit Integration

```bash
export MSF_PATH=/opt/metasploit-framework
export MSF_RPC_HOST=localhost
export MSF_RPC_PORT=55553
export MSF_RPC_USER=msf
export MSF_RPC_PASS=password
```

### Empire Integration

```bash
export EMPIRE_HOST=localhost
export EMPIRE_PORT=1337
export EMPIRE_USER=empire
export EMPIRE_PASS=password
export EMPIRE_SSL_VERIFY=false
```

### Elasticsearch/Logstash Integration

```json
{
  "env": {
    "ELASTICSEARCH_HOST": "localhost",
    "ELASTICSEARCH_PORT": "9200",
    "ELASTICSEARCH_INDEX": "nxc-logs",
    "LOGSTASH_ENABLED": "true",
    "LOGSTASH_HOST": "localhost",
    "LOGSTASH_PORT": "5044"
  }
}
```

---

## 📊 Environment Variables Reference

### Core Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `KALI_HOST` | Kali IP/hostname | **Required** |
| `SSH_USER` | SSH username | **Required** |
| `SSH_KEY` | SSH private key path | **Required** (or SSH_PASSWORD) |
| `SSH_PASSWORD` | SSH password | **Required** (or SSH_KEY) |
| `SSH_PORT` | SSH port | `22` |
| `SSH_TIMEOUT` | SSH timeout (seconds) | `300` |

### NetExec Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `NXC_PATH` | NetExec binary path | `nxc` |
| `NXC_VERBOSE` | Enable verbose output | `false` |
| `NXC_DEBUG` | Enable debug mode | `false` |
| `NXC_LOG_FILE` | Log file path | None |
| `NXC_CACHE` | Enable caching | `false` |
| `NXC_CACHE_TTL` | Cache TTL (seconds) | `3600` |
| `NXC_CRED_CACHE` | Enable credential cache | `false` |

### Performance Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `MAX_CONCURRENT` | Max concurrent operations | `1` |
| `BATCH_SIZE` | Operations per batch | `10` |
| `THREADS` | Number of threads | Auto |
| `CONNECTION_POOL_SIZE` | Connection pool size | `5` |
| `CONNECTION_TIMEOUT` | Connection timeout | `30` |

### Protocol Timeouts

| Variable | Description | Default |
|----------|-------------|---------|
| `SMB_TIMEOUT` | SMB timeout (seconds) | `60` |
| `LDAP_TIMEOUT` | LDAP timeout (seconds) | `120` |
| `WINRM_TIMEOUT` | WinRM timeout (seconds) | `90` |
| `SSH_TIMEOUT` | SSH timeout (seconds) | `300` |
| `MSSQL_TIMEOUT` | MSSQL timeout (seconds) | `120` |
| `RDP_TIMEOUT` | RDP timeout (seconds) | `30` |
| `WMI_TIMEOUT` | WMI timeout (seconds) | `60` |

---

## 📚 Additional Resources

| Resource | Description |
|----------|-------------|
| [NetExec Wiki](https://github.com/Pennyw0rth/NetExec/wiki) | Official NetExec documentation |
| [Ollama Models](https://ollama.com/library) | Available models and their features |
| [MCP Protocol](https://modelcontextprotocol.ai/spec) | MCP specification |
| [SSH Hardening](https://www.ssh.com/academy/ssh/hardening) | Security best practices |
| [Linux Performance Tuning](https://linux.die.net/man/1/perf) | Performance optimization guide |

---

**Last Updated:** July 2026
```

---

## ✨ What Was Improved

| Element | Before | After |
|---------|--------|-------|
| **Emojis** | Limited | Extensive for visual hierarchy |
| **Tables** | Few | Many for structured data |
| **Code Blocks** | Plain | Syntax-highlighted with labels |
| **Navigation** | Missing | Table of contents with links |
| **Visual Hierarchy** | Flat | Clear header levels with emojis |
| **Section Icons** | None | Each section has a relevant emoji |
| **Callouts** | No | Blockquotes for important notes |
| **Parameter Tables** | Mixed | Clean tables with descriptions |
| **Examples** | Plain | Formatted with consistent styling |
| **Checkboxes** | No | ✅ Used for features and tasks |
