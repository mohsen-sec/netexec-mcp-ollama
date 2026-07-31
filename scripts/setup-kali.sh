#!/bin/bash
# Kali Linux Setup Script for NetExec

set -e

echo "🚀 Starting NetExec Setup on Kali Linux"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ This script should not be run as root${NC}"
   echo -e "${YELLOW}Run as a regular user with sudo privileges${NC}"
   exit 1
fi

echo -e "\n${YELLOW}📦 Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "\n${YELLOW}🔧 Installing pipx...${NC}"
sudo apt install pipx -y
pipx ensurepath

# Reload shell
export PATH="$HOME/.local/bin:$PATH"

echo -e "\n${YELLOW}🐍 Installing NetExec...${NC}"
pipx install git+https://github.com/Pennyw0rth/NetExec

# Verify installation
if command -v nxc &> /dev/null; then
    echo -e "${GREEN}✅ NetExec installed successfully!${NC}"
    echo -e "${BLUE}Version info:${NC}"
    nxc --version 2>/dev/null || echo "  (version check not available)"
    nxc --help | head -n 5
else
    echo -e "${RED}❌ NetExec installation failed${NC}"
    exit 1
fi

echo -e "\n${YELLOW}🔐 Setting up SSH...${NC}"
# Enable and start SSH
sudo systemctl enable ssh --now

# Check SSH status
if sudo systemctl is-active --quiet ssh; then
    echo -e "${GREEN}✅ SSH service is running${NC}"
else
    echo -e "${RED}❌ SSH service failed to start${NC}"
    echo -e "${YELLOW}Attempting to start manually...${NC}"
    sudo systemctl start ssh
    if sudo systemctl is-active --quiet ssh; then
        echo -e "${GREEN}✅ SSH service started successfully${NC}"
    else
        echo -e "${RED}❌ Could not start SSH service${NC}"
        exit 1
    fi
fi

# Get IP address
echo -e "\n${YELLOW}🌐 Network Information:${NC}"
echo -e "${BLUE}IP Addresses:${NC}"
ip addr show | grep -E "inet (10\.|172\.|192\.)" | awk '{print "  " $2}' || echo "  No private IP found"
echo ""
echo -e "${BLUE}Hostname:${NC}"
hostname -I | awk '{print "  " $1}'

# Check if SSH keys exist
echo -e "\n${YELLOW}🔑 Checking SSH keys...${NC}"
if [[ -f ~/.ssh/id_rsa.pub ]] || [[ -f ~/.ssh/id_ed25519.pub ]]; then
    echo -e "${GREEN}✅ SSH public key found${NC}"
    echo -e "${BLUE}Your public key:${NC}"
    cat ~/.ssh/id_*.pub 2>/dev/null | head -n 1 || echo "  (no public key found)"
else
    echo -e "${YELLOW}⚠️ No SSH public key found${NC}"
    echo -e "${YELLOW}Generate one with: ssh-keygen -t rsa -b 4096${NC}"
fi

echo -e "\n${GREEN}✅ Kali Linux setup completed successfully!${NC}"
echo -e "\n${YELLOW}📝 Next steps on your local machine:${NC}"
echo -e "1. ${BLUE}Note your Kali IP address from above${NC}"
echo -e "2. ${BLUE}Copy your SSH public key to this machine:${NC}"
echo -e "   ${YELLOW}ssh-copy-id kali@<your-kali-ip>${NC}"
echo -e "3. ${BLUE}Update mcp-config.json with your Kali IP and username${NC}"
echo -e "4. ${BLUE}Run the local setup script (setup-windows.ps1 or setup-mac.sh)${NC}"
echo -e "\n${YELLOW}📖 For more details, see README.md${NC}"

# Optional: Test NetExec
echo -e "\n${YELLOW}🧪 Quick NetExec test:${NC}"
echo -e "${BLUE}Try running: nxc smb 127.0.0.1${NC}"
