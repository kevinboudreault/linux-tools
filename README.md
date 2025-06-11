# Linux Tools Configuration for SysAdmin & DevOps 🛠️

My curated collection of Linux tools, scripts, and configurations to streamline my daily sysadmin and DevOps tasks, troubleshooting, and system management. This repo serves as a centralized hub for automation, monitoring, and efficiency in Linux environments.

---


## Overview

This repository contains:

- **Configuration files** for tools like `zsh`, `oh my zsh`, `Docker`, `Prometheus`, `Grafana` and more as I learn
- **Custom scripts** for automation, troubleshooting, and monitoring
- **Essential Linux tools** for system administration and DevOps workflows

---


## Tools & Scripts

### Configuration Management
- **`~/.config/`**: Local configuration
- **`/etc/caddy/`**: Custom Caddy setups
- **`/etc/profile.d/`**: Custom environment variables

### Containerization
- **`docker compose`**: Multi-container applications
- **`crictl`**: Debug container runtime issues

### System Monitoring
- **`Prometheus & Grafana`**: Setup for real-time system metrics
- **`Loki`**: System logs aggregation
- **`Promtail`**: System logs scrapper
- **`cAdvisor`**: Continuous Containers monitoring
- **`Nagios`**: Custom checks for server health
- **`Netdata`**: Lightweight real-time performance dashboard

### Debugging & Troubleshooting
- **`tcpdump` + `Wireshark`**: Network analysis tools
- **`strace` / `ltrace`**: Trace system calls and library calls

---


## Steps

#### ZSH
1. [Install ZSH & dependancies](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
2. **Clone the repo**:
   ```bash
      git clone https://github.com/kevinboudreault/linux-tools.git
   ```
