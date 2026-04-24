#!/bin/bash
################################################################################
# Cyber Range VPS Setup Script
# Automated deployment of DVWA + Juice Shop pentesting lab
# Author: Kavennesh Balachandar
# GitHub: https://github.com/Kavennesh/cyber-range-lab
################################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${RED}"
cat << "EOF"
  ____      _                 ____                       
 / ___|   _| |__   ___ _ __  |  _ \ __ _ _ __   __ _  ___ 
| |  | | | | '_ \ / _ \ '__| | |_) / _` | '_ \ / _` |/ _ \
| |__| |_| | |_) |  __/ |    |  _ < (_| | | | | (_| |  __/
 \____\__, |_.__/ \___|_|    |_| \_\__,_|_| |_|\__, |\___|
      |___/                                    |___/      
EOF
echo -e "${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo -e "${GREEN}  Automated Penetration Testing Lab Setup${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[ERROR]${NC} Please run this script as root or with sudo"
    echo "Usage: sudo ./setup.sh"
    exit 1
fi

# Get VPS IP address
VPS_IP=$(hostname -I | awk '{print $1}')

# Step 1: System Update
echo -e "${YELLOW}[1/8]${NC} Updating system packages..."
apt update -qq && apt upgrade -y -qq
echo -e "${GREEN}✓${NC} System updated successfully"

# Step 2: Install Dependencies
echo -e "${YELLOW}[2/8]${NC} Installing required packages..."
apt install -y -qq \
    git \
    curl \
    wget \
    ufw \
    docker.io \
    docker-compose \
    nmap \
    nikto \
    sqlmap \
    hydra
echo -e "${GREEN}✓${NC} All dependencies installed"

# Step 3: Configure Docker
echo -e "${YELLOW}[3/8]${NC} Starting and enabling Docker service..."
systemctl enable docker >/dev/null 2>&1
systemctl start docker
echo -e "${GREEN}✓${NC} Docker service is running"

# Step 4: Firewall Configuration
echo -e "${YELLOW}[4/8]${NC} Configuring UFW firewall..."
ufw --force reset >/dev/null 2>&1
ufw default deny incoming >/dev/null 2>&1
ufw default allow outgoing >/dev/null 2>&1
ufw allow OpenSSH >/dev/null 2>&1
ufw allow 80/tcp >/dev/null 2>&1
ufw allow 8080/tcp >/dev/null 2>&1
ufw allow 3000/tcp >/dev/null 2>&1
echo "y" | ufw enable >/dev/null 2>&1
echo -e "${GREEN}✓${NC} Firewall configured (SSH, HTTP, 8080, 3000)"

# Step 5: Create Docker Network
echo -e "${YELLOW}[5/8]${NC} Creating isolated Docker network 'cyberlab'..."
if docker network inspect cyberlab >/dev/null 2>&1; then
    echo -e "${BLUE}[INFO]${NC} Network 'cyberlab' already exists"
else
    docker network create cyberlab >/dev/null 2>&1
    echo -e "${GREEN}✓${NC} Docker network created"
fi

# Step 6: Clean Previous Containers
echo -e "${YELLOW}[6/8]${NC} Removing old containers (if any)..."
docker rm -f dvwa juice-shop >/dev/null 2>&1 || true
echo -e "${GREEN}✓${NC} Cleanup complete"

# Step 7: Deploy DVWA
echo -e "${YELLOW}[7/8]${NC} Deploying DVWA container..."
docker run -d \
    --name dvwa \
    --network cyberlab \
    --restart unless-stopped \
    -p 8080:80 \
    vulnerables/web-dvwa >/dev/null 2>&1

# Wait for DVWA to initialize
sleep 3
if docker ps | grep -q dvwa; then
    echo -e "${GREEN}✓${NC} DVWA deployed successfully"
else
    echo -e "${RED}[ERROR]${NC} DVWA deployment failed"
    exit 1
fi

# Step 8: Deploy Juice Shop
echo -e "${YELLOW}[8/8]${NC} Deploying OWASP Juice Shop container..."
docker run -d \
    --name juice-shop \
    --network cyberlab \
    --restart unless-stopped \
    -p 3000:3000 \
    bkimminich/juice-shop >/dev/null 2>&1

# Wait for Juice Shop to initialize
sleep 3
if docker ps | grep -q juice-shop; then
    echo -e "${GREEN}✓${NC} Juice Shop deployed successfully"
else
    echo -e "${RED}[ERROR]${NC} Juice Shop deployment failed"
    exit 1
fi

# Final Status
echo ""
echo -e "${BLUE}=====================================================${NC}"
echo -e "${GREEN}  ✓ Setup Complete!${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo ""

# Display running containers
echo -e "${YELLOW}Running Containers:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Access Information
echo -e "${BLUE}=====================================================${NC}"
echo -e "${GREEN}  Access Your Cyber Range Lab${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo ""
echo -e "${YELLOW}DVWA (Damn Vulnerable Web App):${NC}"
echo -e "  URL:      ${GREEN}http://$VPS_IP:8080${NC}"
echo -e "  Username: ${GREEN}admin${NC}"
echo -e "  Password: ${GREEN}password${NC}"
echo ""
echo -e "${RED}⚠ IMPORTANT:${NC} Initialize DVWA database:"
echo -e "  1. Open: ${GREEN}http://$VPS_IP:8080/setup.php${NC}"
echo -e "  2. Click: ${GREEN}Create / Reset Database${NC}"
echo ""
echo -e "${YELLOW}OWASP Juice Shop:${NC}"
echo -e "  URL: ${GREEN}http://$VPS_IP:3000${NC}"
echo ""

# Installed Tools
echo -e "${BLUE}=====================================================${NC}"
echo -e "${GREEN}  Installed Attack Tools${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo -e "  • Nmap       - Network scanner"
echo -e "  • SQLMap     - SQL injection tool"
echo -e "  • Hydra      - Brute force tool"
echo -e "  • Nikto      - Web vulnerability scanner"
echo ""

# Security Warning
echo -e "${RED}=====================================================${NC}"
echo -e "${RED}  ⚠  SECURITY WARNING ⚠${NC}"
echo -e "${RED}=====================================================${NC}"
echo -e "These applications are ${RED}INTENTIONALLY VULNERABLE${NC}"
echo -e "• Only use for educational purposes"
echo -e "• Do not expose for extended periods"
echo -e "• Monitor access logs regularly"
echo -e "• Shut down when not in use: ${YELLOW}docker stop dvwa juice-shop${NC}"
echo ""

# Useful Commands
echo -e "${BLUE}=====================================================${NC}"
echo -e "${GREEN}  Useful Commands${NC}"
echo -e "${BLUE}=====================================================${NC}"
echo -e "${YELLOW}View logs:${NC}       docker logs dvwa"
echo -e "${YELLOW}Stop lab:${NC}        docker stop dvwa juice-shop"
echo -e "${YELLOW}Start lab:${NC}       docker start dvwa juice-shop"
echo -e "${YELLOW}Remove lab:${NC}      docker rm -f dvwa juice-shop"
echo -e "${YELLOW}Check status:${NC}    docker ps"
echo ""

echo -e "${GREEN}Happy Hacking! 🎯${NC}"
echo ""
