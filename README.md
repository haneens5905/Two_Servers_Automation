# BARQ-Lite Project

The **BARQ-Lite Project** is a DevOps automation challenge that
demonstrates skills in **Bash scripting** and **Ansible automation**.\
It simulates real-world operations tasks: managing logs, deploying
applications, and monitoring TLS certificates.

The project consists of **three main parts**:
1. Automated Log Setup and Rotation
2. Java Application Deployment with systemd
3. TLS Certificate Reporting with cron

By combining Bash scripts and Ansible playbooks, this project ensures
tasks are reproducible, automated, and easy to maintain.

------------------------------------------------------------------------

##  Table of Contents

1.  [Overview](#overview)\
2.  [Project Description](#project-description)\
3.  [Prerequisites & Dependencies](#prerequisites--dependencies)\
4.  [Assumptions](#assumptions)\
5.  [Project Structure](#project-structure)\
6.  [How to Run the Playbooks](#how-to-run-the-playbooks)\
7.  [Part 1 -- Log Setup](#part-1--log-setup)\
8.  [Part 2 -- Java App Deployment](#part-2--java-app-deployment)\
9.  [Part 3 -- TLS Certificate Report](#part-3--tls-certificate-report)\
10. [Verification](#verification)

------------------------------------------------------------------------

##  Overview

The **BARQ-Lite Project** automates essential system administration
tasks using Ansible and Bash.

It covers:\
- **Log management:** Automatically rotates and compresses logs.\
- **Application deployment:** Deploys a Java app as a managed service.\
- **Security monitoring:** Reports TLS certificate expiry daily.

------------------------------------------------------------------------

##  Project Description

-   **Part 1 -- Log Setup:**\
    Simulates a log rotation system. Logs are rotated daily, compressed,
    and archived to avoid filling up disk space.

-   **Part 2 -- Java App Deployment:**\
    Demonstrates how to deploy a Java application using a release-based
    directory structure, symbolic links, and systemd service management
    for reliability.

-   **Part 3 -- TLS Certificate Report:**\
    Provides visibility into TLS certificate expiry dates by scanning
    certificates and producing a daily report. Ensures proactive
    monitoring to prevent outages.

------------------------------------------------------------------------

##  Prerequisites & Dependencies

### System

-   Ubuntu 20.04+ (tested on Ubuntu 20.04)\
-   Bash shell (default)\
-   cron (default on Ubuntu)\
-   systemd (default on Ubuntu)

### Packages

Install required packages:

``` bash
sudo apt update
sudo apt install ansible openjdk-17-jdk openssl -y
```

### Ansible

-   Version: 2.9+\
-   Inventory defined in `inventory.txt`

------------------------------------------------------------------------

##  Assumptions

-   Inventory file (`inventory.txt`) contains the managed VM IPs:

    ``` ini
    [barq_servers]
    192.168.1.7
    192.168.1.8
    ```

-   SSH access is set up for Ansible (via password or SSH key).\

-   Java JAR file (`barq-lite.jar`) is provided in the `files/`
    directory.\

-   TLS certificates are stored in `/etc/ssl/patrol/*.crt`.\

-   All scripts are placed in `/usr/local/bin` and set as executable.

------------------------------------------------------------------------

##  Project Structure

    BARQ-Lite-Project/
    │
    ├── ansible/
    │   ├── inventory.txt
    │   ├── playbooks/
    │   │   ├── log_setup.yml
    │   │   ├── java_deploy.yml
    │   │   └── cert_report.yml
    │   └── files/
    │       ├── log-lite.sh
    │       ├── barq-lite.jar
    │       └── cert-lite.sh
    │
    └── verify_barq.sh   # Verification script

------------------------------------------------------------------------

##  How to Run the Playbooks

Navigate to the Ansible project folder:

``` bash
cd BARQ-Lite-Project/ansible
```

Run each playbook:

### Part 1 -- Log Setup

``` bash
ansible-playbook -i inventory.txt playbooks/log_setup.yml --ask-become-pass
```

### Part 2 -- Java App Deployment

``` bash
ansible-playbook -i inventory.txt playbooks/java_deploy.yml --ask-become-pass
```

### Part 3 -- TLS Certificate Report

``` bash
ansible-playbook -i inventory.txt playbooks/cert_report.yml --ask-become-pass
```

------------------------------------------------------------------------

##  Part 1 -- Log Setup

**Description:**\
Implements automated log rotation and archiving to simulate log
lifecycle management.

-   **Script:** `log-lite.sh`\

-   **Location:** `/usr/local/bin/log-lite.sh`\

-   **Behavior:**

    -   Rotates `/var/log/barq.log` daily.\
    -   Archives logs into `/var/log/barq-YYYY-MM-DD.log.gz`.

-   **Cron job:**

        10 1 * * * /usr/local/bin/log-lite.sh

------------------------------------------------------------------------

##  Part 2 -- Java App Deployment

**Description:**\
Deploys a Java application with a versioned release structure and runs
it as a systemd service.

-   **Deployment Path:** `/opt/barq/releases/<version>`\

-   **Symlink:** `/opt/barq/current` → active release.\

-   **Systemd Service:** `/etc/systemd/system/barq.service`\

-   **Executes:**

    ``` bash
    /usr/bin/java -jar /opt/barq/current/barq-lite.jar
    ```

-   **Service Control:**

    ``` bash
    sudo systemctl start barq
    sudo systemctl status barq
    sudo systemctl enable barq
    ```

------------------------------------------------------------------------

##  Part 3 -- TLS Certificate Report

**Description:**\
Provides proactive monitoring of certificate expiry dates by scanning
certificates in `/etc/ssl/patrol`.

-   **Script:** `cert-lite.sh`\

-   **Location:** `/usr/local/bin/cert-lite.sh`\

-   **Behavior:**

    -   Scans `/etc/ssl/patrol/*.crt`.\
    -   Extracts `NotAfter` field.\
    -   Calculates days until expiry.\
    -   Outputs `/var/reports/cert-lite.txt`.

-   **Sample Output:**

        cert_name | NotAfter_date | days_remaining
        barq-3day.crt | Aug 27 12:30:14 2025 GMT | 1
        barq.crt      | Aug 31 13:22:44 2025 GMT | 5

-   **Cron job:**

        0 7 * * * /usr/local/bin/cert-lite.sh

------------------------------------------------------------------------

##  Verification

A helper script `verify_barq.sh` is provided to confirm the setup. Run:

``` bash
./verify_barq.sh
```

It checks: - Log rotation script + cron\
- Java app deployment + systemd service\
- TLS certificate report + cron
