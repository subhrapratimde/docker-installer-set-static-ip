# Ubuntu Docker & Network Setup Script

This script installs Docker, Docker Compose, configures the system timezone, and sets a static IP address using Netplan on Ubuntu systems.

## 📦 Features

- Docker & Docker Compose Installation (latest version)
- Timezone setup with user prompt (e.g., Asia/Kolkata)
- Static IP configuration via Netplan (auto detects interface)
- Reboot and upgrade options

## 🧑‍💻 How to Run

Run this script directly from GitHub:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/subhrapratimde/docker-installer-set-static-ip/main/install-docker.sh)
