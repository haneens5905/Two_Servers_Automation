# BARQ Lite – Two Servers Automation Project

The **Two Servers Automation** is a DevOps automation challenge completed during my internship at **BARQ Systems**.  
It demonstrates **Bash scripting** and **Ansible automation** for real-world operational tasks:
- **Log management:** Automatically rotates and compresses logs.
- **Application deployment:** Deploys a Java app as a managed service.
- **Security monitoring:** Reports TLS certificate expiry daily.

---

## 📑 Table of Contents
1. [Overview](#overview)  
2. [Architecture](#architecture)  
3. [Project Description](#project-description)  
4. [Prerequisites & Dependencies](#prerequisites--dependencies)  
5. [Assumptions](#assumptions)  
6. [Project Structure](#project-structure)  
7. [How to Run the Playbooks](#how-to-run-the-playbooks)  
8. [Part 1 – Log Setup](#part-1--log-setup)  
9. [Part 2 – Java App Deployment](#part-2--java-app-deployment)  
10. [Part 3 – TLS Certificate Report](#part-3--tls-certificate-report)  
11. [Verification](#verification)  
12. [Error Handling & Best Practices](#error-handling--best-practices)  
13. [Docker (Optional)](#docker-bonus-challenge--optional)  
14. [Deliverables](#deliverables)  
15. [Future Improvements](#future-improvements)  

---

##  Overview
The **BARQ Lite Project** automates essential system administration tasks using **Ansible** and **Bash**.  

It covers:  
- **Log management:** Automated rotation, compression, retention.  
- **Application deployment:** Java JAR deployment with systemd service.  
- **Security monitoring:** TLS certificate expiry reporting.  

Key objectives:
- Environment setup (logs, releases, certificates).  
- Automated log compression & retention.  
- Automated Java JAR deployment (with release versioning + systemd).  
- TLS certificate scanning & reporting.  
- Idempotent automation using Ansible.  
- (Optional) Docker containerization.  

---

##  Architecture

```
              +-------------------+
              |   Ansible Host    |
              | (Control Machine) |
              +-------------------+
                        |
         -----------------------------------
         |                                 |
+-------------------+           +-------------------+
|    Server s1      |           |    Server s2      |
|-------------------|           |-------------------|
| /var/log/barq/    |           | /var/log/barq/    |
| /opt/barq/releases|           | /opt/barq/releases|
| /etc/ssl/patrol/  |           | /etc/ssl/patrol/  |
| systemd: barq.service         | systemd: barq.service
+-------------------+           +-------------------+
```

---

##  Project Description

- **Part 1 – Log Setup:**  
  Simulates a log rotation system. Logs are rotated daily, compressed, and archived to avoid disk exhaustion.

- **Part 2 – Java Application Deployment:**  
  Deploys the Java JAR with a release-based directory structure, symlink to current release, and systemd service for reliability.

- **Part 3 – TLS Certificate Report:**  
  Scans certs, extracts expiry, calculates days remaining, and outputs daily reports to ensure proactive monitoring.  

---

##  Prerequisites & Dependencies

### System
- Ubuntu 20.04+ (tested on 20.04)  
- Bash, cron, systemd  

### Packages
```bash
sudo apt update
sudo apt install ansible openjdk-17-jdk openssl -y
```

### Ansible
- Version: 2.9+  
- Inventory defined in `inventory.txt`  

---

##  Assumptions
- Inventory file (`inventory.txt`) lists servers:
  ```ini
  [barq_servers]
  192.168.1.7
  192.168.1.8
  ```
- SSH access with sudo privileges.  
- JAR (`barq-lite.jar`) placed in `files/`.  
- Certs stored at `/etc/ssl/patrol/*.crt`.  
- Scripts installed to `/usr/local/bin` and executable.  

---

##  Project Structure

```
BARQ-Lite-Project/
│
├── ansible/
│   ├── inventory.txt
│   ├── java_deploy.yml
│   ├── log_setup.yml
│   ├── cert_report.yml
│   └── files/
│       ├── log-lite.sh
│       ├── barq-lite.jar
│       ├── cert-lite.sh
│       └── verify_barq.sh   # Verification script
├── .gitignore
└── README.md
```

---

##  How to Run the Playbooks

Navigate to the Ansible folder:
```bash
cd BARQ-Lite-Project/ansible
```

Run each playbook:

### Part 1 – Log Setup
```bash
ansible-playbook -i inventory.txt log_setup.yml --ask-become-pass
```

### Part 2 – Java App Deployment
```bash
ansible-playbook -i inventory.txt java_deploy.yml --ask-become-pass
```

### Part 3 – TLS Certificate Report
```bash
ansible-playbook -i inventory.txt cert_report.yml --ask-become-pass
```

---

##  Part 1 – Log Setup

- **Script:** `log-lite.sh`  
- **Location:** `/usr/local/bin/log-lite.sh`  
- **Behavior:**  
  - Rotates `/var/log/barq/*.log`.  
  - Compresses yesterday’s logs.  
  - Deletes compressed logs older than 7 days.  
- **Cron job:**  
  ```
  10 1 * * * /usr/local/bin/log-lite.sh
  ```

Example run:
```bash
$ ls /var/log/barq/
barq-20250824.log  barq-20250825.log  barq-20250824.log.gz
```

---

##  Part 2 – Java App Deployment

- **Deployment Path:** `/opt/barq/releases/<release_id>`  
- **Symlink:** `/opt/barq/current`  
- **Systemd Service:** `/etc/systemd/system/barq.service`  

Executes:
```bash
/usr/bin/java -jar /opt/barq/current/barq-lite.jar
```

Service control:
```bash
sudo systemctl start barq
sudo systemctl status barq
sudo systemctl enable barq
```

---

##  Part 3 – TLS Certificate Report

- **Script:** `cert-lite.sh`  
- **Location:** `/usr/local/bin/cert-lite.sh`  
- **Behavior:**  
  - Scans `/etc/ssl/patrol/*.crt`.  
  - Extracts expiry (`NotAfter`).  
  - Outputs `/var/reports/cert-lite.txt`.  
- **Cron job:**  
  ```
  0 7 * * * /usr/local/bin/cert-lite.sh
  ```

Example output:
```
cert_name   | NotAfter_date | days_remaining
barq.crt    | Aug 31 2025   | 5 days
```

---

##  Verification
Helper script: `verify_barq.sh`  
```bash
./verify_barq.sh
```
Checks:  
- Log rotation script & cron  
- Java app deployment & service status  
- TLS certificate report  

---

##  Error Handling & Best Practices
- Bash scripts use `set -euo pipefail` and `"quoted variables"`.  
- Ansible playbooks are **idempotent** (safe to rerun).  
- Logs are rotated and retained only as required.  

---

## 🐳 Docker (Bonus Challenge – Optional)
- Dockerfile wraps the app into a container (based on `openjdk:17-jdk`).  
- Container exposes port **8080**.  
- Managed via Ansible tasks.  

---

##  Deliverables
- Bash scripts: `log-lite.sh`, `cert-lite.sh`, `verify_barq.sh`.  
- Ansible playbooks: `log_setup.yml`, `java_deploy.yml`, `cert_report.yml`.  
- `barq.service` systemd unit.  
- Documentation: `README.md`.  

---
