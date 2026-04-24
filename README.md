<div align="center">

# 🔴 CYBER RANGE LAB

### *Docker-Based Penetration Testing Environment on Cloud VPS*

<img src="https://img.shields.io/badge/Security-Offensive-critical?style=for-the-badge&logo=hackaday&logoColor=white" />
<img src="https://img.shields.io/badge/Platform-Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
<img src="https://img.shields.io/badge/Infrastructure-VPS-FF6C37?style=for-the-badge&logo=ubuntu&logoColor=white" />
<img src="https://img.shields.io/badge/Automation-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" />
<img src="https://img.shields.io/badge/Status-Live-00FF00?style=for-the-badge" />

**A fully isolated, cloud-hosted cybersecurity laboratory for practicing real-world exploitation techniques**

[📖 Documentation](#-documentation) • [⚡ Quick Start](#-quick-start) • [🎯 Attack Scenarios](#-attack-scenarios) • [🛡️ Security](#-security-considerations)

---

</div>

## 🎯 Project Overview

Built a **production-grade penetration testing lab** on a remote VPS, simulating vulnerable web applications in an isolated Docker environment. This project demonstrates end-to-end capability in offensive security operations—from infrastructure provisioning to active exploitation.

**🔥 Fully automated deployment** via custom bash script reduces setup time from 30+ minutes to under 5 minutes.

### 💡 Why This Matters

- **Real Infrastructure**: Not a local VM—actual cloud deployment with public exposure
- **Automated Deployment**: One-command setup script with error handling and validation
- **Practical Skills**: Hands-on exploitation of OWASP Top 10 vulnerabilities
- **Operational Security**: Proper network segmentation, firewall rules, and container isolation
- **Attack Lifecycle**: Complete workflow from reconnaissance to post-exploitation

---

## 🏗️ Architecture

```
┌────────────────────────────────────────────────────┐
│              VPS (Public Internet)                 │
│  ┌──────────────────────────────────────────────┐  │
│  │         Docker Network: cyberlab             │  │
│  │  ┌────────────────┐  ┌──────────────────┐    │  │
│  │  │ DVWA Container │  │ Juice Shop       │    │  │
│  │  │ Port: 8080     │  │ Port: 3000       │    │  │
│  │  │ Skill Level: 🟢 │  │ Skill Level: 🔴│    │  │
│  │  └────────────────┘  └──────────────────┘    │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  Attack Tools (Host):                              │
│  • Nmap • SQLMap • Hydra • Metasploit • Nikto      │
└────────────────────────────────────────────────────┘
```

### 📦 Components

| Component | Purpose | Difficulty |
|-----------|---------|------------|
| **DVWA** | Damn Vulnerable Web App - Classic pentesting training | Beginner-Friendly |
| **Juice Shop** | OWASP Modern Web App - Advanced vulnerabilities | Advanced |
| **Attack Tools** | Exploitation framework suite | N/A |

---

## ⚡ Quick Start

### Prerequisites

- VPS with Ubuntu (Hostinger, DigitalOcean, AWS, etc.)
- SSH access with root privileges
- Basic Linux/networking knowledge

### 🚀 Automated Deployment (Recommended)

**One-command setup** using the automated deployment script:

```bash
# Download and execute the setup script
wget https://raw.githubusercontent.com/Kavennesh/cyber-range-lab/main/setup.sh
chmod +x setup.sh
sudo ./setup.sh
```

The script automatically:
- ✅ Updates system packages
- ✅ Installs Docker and attack tools (Nmap, SQLMap, Hydra, Nikto)
- ✅ Configures UFW firewall rules
- ✅ Creates isolated Docker network
- ✅ Deploys DVWA and Juice Shop containers
- ✅ Displays access URLs and credentials

**Post-Installation:**
```bash
# Initialize DVWA database
Open: http://YOUR_VPS_IP:8080/setup.php
Click: "Create / Reset Database"

# Verify containers are running
docker ps
```

### 🔧 Manual Deployment

If you prefer manual control:

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install dependencies
sudo apt install -y docker.io docker-compose nmap nikto sqlmap hydra

# 3. Configure firewall
sudo ufw allow OpenSSH
sudo ufw allow 80,8080,3000/tcp
sudo ufw enable

# 4. Create Docker network
docker network create cyberlab

# 5. Deploy DVWA
docker run -d \
  --name dvwa \
  --network cyberlab \
  -p 8080:80 \
  vulnerables/web-dvwa

# 6. Deploy Juice Shop
docker run -d \
  --name juice-shop \
  --network cyberlab \
  -p 3000:3000 \
  bkimminich/juice-shop

# 7. Verify deployment
docker ps
nmap -sV localhost -p 8080,3000
```

---

## 🎯 Attack Scenarios

### 🔍 Scenario 1: SQL Injection (DVWA)

**Objective**: Extract database records via SQL injection vulnerability

```bash
# 1. Reconnaissance
nmap -sV <VPS_IP> -p 8080

# 2. Access DVWA
http://<VPS_IP>:8080
# Default credentials: admin / password

# 3. Navigate to SQL Injection module

# 4. Inject payload
Input: 1' OR '1'='1
```

**Expected Result**:
```
✅ Authentication bypass
✅ Database enumeration
✅ Full table dump
```

### 💉 Scenario 2: Automated Exploitation (SQLMap)

```bash
# Capture vulnerable request
# Use SQLMap for automated exploitation
sqlmap -u "http://<VPS_IP>:8080/vulnerabilities/sqli/?id=1&Submit=Submit" \
  --cookie="security=low; PHPSESSID=<session>" \
  --dbs
```

### 🔐 Scenario 3: Brute Force Attack (Hydra)

```bash
# Attack login form
hydra -l admin -P /usr/share/wordlists/rockyou.txt \
  <VPS_IP> http-post-form \
  "/login.php:username=^USER^&password=^PASS^:F=incorrect"
```

---

## 🛠️ Technical Challenges & Solutions

### ⚠️ Challenge 1: ISP Blocking
**Problem**: ISP flagged VPS traffic as phishing/malicious  
**Solution**: 
- Switched to mobile hotspot for testing
- Used VPN for ISP bypass
- Configured proper DNS records

### ⚠️ Challenge 2: DVWA Database Initialization
**Problem**: Container started but database not configured  
**Solution**:
```bash
# Access setup page
http://<VPS_IP>:8080/setup.php

# Debug container
docker logs dvwa
docker exec -it dvwa /bin/bash
```

### ⚠️ Challenge 3: Session Management
**Problem**: Cookie/session handling in automated tools  
**Solution**: 
- Captured cookies via browser DevTools
- Used `--cookie` flag in SQLMap
- Configured session persistence

---

## 📊 Vulnerability Analysis

### 🔴 SQL Injection

**Description**: Improper input sanitization allows SQL query manipulation

**Attack Vector**:
```sql
-- Authentication Bypass
' OR '1'='1' --

-- Data Extraction
' UNION SELECT username, password FROM users--
```

**Impact**:
- 🚨 Complete database compromise
- 🚨 Authentication bypass
- 🚨 Sensitive data exposure

**Remediation**:
```php
// Use parameterized queries
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$user_input]);
```

### 🟡 Cross-Site Scripting (XSS)

**Payload Example**:
```javascript
<script>alert(document.cookie)</script>
```

**Fix**: Implement proper output encoding and CSP headers

---

## 🧠 Key Learnings

### Offensive Security
- ✅ Complete attack lifecycle (Recon → Exploit → Post-Exploitation)
- ✅ Manual vs. automated exploitation techniques
- ✅ OWASP Top 10 practical exploitation
- ✅ Tool proficiency (Nmap, SQLMap, Hydra, Metasploit)

### Infrastructure & DevOps
- ✅ Docker networking and container isolation
- ✅ Cloud VPS management (SSH, firewall, monitoring)
- ✅ CLI-only environment operations
- ✅ Network security configuration
- ✅ **Infrastructure as Code (IaC)** - Automated deployment scripts
- ✅ **Bash scripting** for system automation
- ✅ **Container orchestration** with error handling

### Problem Solving
- ✅ Troubleshooting ISP-level restrictions
- ✅ Debugging containerized applications
- ✅ Managing public-facing vulnerable services responsibly

---

## 🚀 Future Enhancements

### Phase 2: Advanced Monitoring
- [ ] Deploy **Wazuh SIEM** for threat detection
- [ ] Integrate **ELK Stack** for log analysis
- [ ] Implement honeypot (Cowrie SSH)

### Phase 3: Advanced Exploitation
- [ ] Command Injection scenarios
- [ ] Remote Code Execution (RCE)
- [ ] XML External Entity (XXE) attacks
- [ ] Server-Side Request Forgery (SSRF)

### Phase 4: Automation & Reporting
- [ ] Automated vulnerability scanning pipeline
- [ ] Custom exploitation scripts
- [ ] Real-time dashboard (Grafana)
- [ ] Automated penetration testing reports

---

## 🛡️ Security Considerations

### ⚠️ Responsible Disclosure

This lab is deployed on a **private VPS for educational purposes only**. 

**NEVER**:
- Attack systems you don't own
- Deploy vulnerable apps on production networks
- Use techniques learned here for unauthorized access

**ALWAYS**:
- Follow responsible disclosure practices
- Obtain written permission before testing
- Comply with local cybersecurity laws

### 🔒 Lab Security

- Firewall rules restrict unnecessary access
- Containers run in isolated network
- Regular monitoring of access logs
- Services shut down when not in use

---

## 📚 Resources

### Learning Platforms
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [HackTheBox](https://www.hackthebox.com/)
- [TryHackMe](https://tryhackme.com/)

### Documentation
- [DVWA Official Docs](https://github.com/digininja/DVWA)
- [Juice Shop Guide](https://pwning.owasp-juice.shop/)
- [Metasploit Unleashed](https://www.offensive-security.com/metasploit-unleashed/)

---

## 🤝 Contributing

Found a bug? Want to add new attack scenarios? Contributions welcome!

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-exploit`)
3. Commit changes (`git commit -m 'Add new XSS scenario'`)
4. Push to branch (`git push origin feature/new-exploit`)
5. Open a Pull Request

---

## 📜 License

This project is for **educational purposes only**. Use responsibly and ethically.

**MIT License** - See [LICENSE](LICENSE) for details

---

## 👨‍💻 Author

<div align="center">

**Kavennesh Balachandar**

*Cybersecurity Graduate Student | Offensive Security Enthusiast*

[![Portfolio](https://img.shields.io/badge/Portfolio-kavennesh.com-00C7B7?style=for-the-badge&logo=About.me&logoColor=white)](https://kavennesh.com)
[![GitHub](https://img.shields.io/badge/GitHub-Kavennesh-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Kavennesh)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/kavennesh)

*"From packets to payloads, every vulnerability tells a story."*

---

⭐ **Star this repo** if you found it useful!

</div>
