# 🛡️ CDS Host Guardian

**The ultimate Zero-Trust defense for Linux hosts and Docker environments.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Interactive Demo](https://img.shields.io/badge/Live-Interactive%20Lab-brightgreen)](https://m0ndsuchtig.github.io/cds-host-guardian/)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-lightgrey.svg)](https://www.linux.org/)

---

## 🌟 Overview

**CDS Host Guardian** is a comprehensive security ecosystem designed to protect your infrastructure from the ground up. It bridges the gap between **filesystem integrity** and **container trust**, ensuring that your host is as secure as the workloads it runs.

### The Problem
Traditional security focuses on either the host *or* the container. Attackers can bypass container security by corrupting the host's filesystem or injecting untrusted images.

### The CDS Solution
We provide a unified defense:
1. **What runs:** Only cryptographically signed and authorized Docker images can start.
2. **Where it runs:** The underlying Btrfs root filesystem is continuously monitored for unauthorized changes or corruption.

---

## 🎮 Interactive Security Lab

Don't just take our word for it—try it yourself! We built a browser-based simulator where you can play the role of both an attacker and a defender.

**[👉 Launch the CDS Security Lab](https://m0ndsuchtig.github.io/cds-host-guardian/)**

**What you can do in the lab:**
- 🔨 **Simulate Corruption:** "Break" the Btrfs rootfs and see how the system reacts.
- 🔍 **Real-time Monitoring:** Watch as CDS detects integrity violations instantly.
- 🛡️ **Zero-Trust in Action:** Try to run an unauthorized container and witness the "Fail-Closed" protection.

---

## 🏗️ Architecture & Components

The project consists of two core pillars:

### 1. [CDS AuthZ System](https://github.com/M0NDsuChTiG/cds-authz-system)
A Managed Trust Authority for Docker.
- **Fail-Closed Authorization:** If trust isn't verified, the container doesn't start.
- **Signature Verification:** Deep integration with `Cosign` and public key management.
- **Audit Logs:** Full traceability for every `docker run` attempt.

### 2. [Btrfs Root Hunter](https://github.com/M0NDsuChTiG/btrfs-root-hunter)
Filesystem-level integrity and recovery.
- **Btrfs Integration:** Leverages snapshots and checksums for subvolume protection.
- **Auto-Recovery:** Detects rootfs tampering and provides paths to restoration.

---

## 🚀 Quick Start

Get the full stack up and running on your Linux host:

```bash
# Clone the project with all security modules
git clone --recurse-submodules https://github.com/M0NDsuChTiG/cds-host-guardian.git
cd cds-host-guardian

# Run the unified installer
sudo ./install.sh

# Apply Docker security policy
sudo systemctl restart docker
```

---

## 🛡️ Security Philosophy

- **Zero-Trust:** Never trust, always verify every layer.
- **Fail-Closed:** Security by default. If a component fails or is uncertain, access is denied.
- **Transparency:** Every decision is logged and auditable.

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.

---
*Built with ❤️ for a more secure Linux ecosystem.*
