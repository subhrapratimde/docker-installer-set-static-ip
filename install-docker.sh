#!/bin/bash

# Docker & System Configuration Script for Ubuntu
# Author: Subho

echo "🔄 Updating package list..."
sudo apt-get update -y

echo "📦 Installing prerequisites..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release tzdata network-manager

echo "📁 Creating keyring directory..."
sudo install -m 0755 -d /etc/apt/keyrings

echo "🔑 Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "➕ Adding Docker APT repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔄 Updating package list again..."
sudo apt-get update -y

echo "📥 Installing Docker Engine and related components..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "🚀 Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "👤 Adding current user ($USER) to docker group..."
sudo usermod -aG docker "$USER"
sudo systemctl restart docker

echo "✅ Docker Status:"
sudo systemctl status docker

echo "🐳 Docker Version:"
docker --version

echo "⚙️ Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "🌐 Timezone Configuration"
read -p "Enter your timezone (e.g., Asia/Kolkata) [default: Asia/Kolkata]: " tz_input
TZ=${tz_input:-Asia/Kolkata}
sudo timedatectl set-timezone "$TZ"
echo "✅ Timezone set to:"
timedatectl

echo "🌐 Network Configuration (Static IP Setup)"

# Detect interface name
IFACE=$(nmcli device status | awk '$2 == "ethernet" && $3 == "connected" {print $1}' | head -n 1)
echo "🖧 Detected interface: $IFACE"

# Ask user for static IP and gateway
read -p "Enter static IP address with CIDR (e.g., 192.168.1.10/24): " static_ip
read -p "Enter gateway IP (e.g., 192.168.1.1): " gateway_ip

# Backup old netplan config
if [ -f /etc/netplan/01-netcfg.yaml ]; then
  sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bak
fi

# Create new netplan config
sudo tee /etc/netplan/01-netcfg.yaml > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $IFACE:
      dhcp4: no
      addresses:
        - $static_ip
      routes:
        - to: default
          via: $gateway_ip
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

sudo chmod 600 /etc/netplan/01-netcfg.yaml
echo "✅ New Netplan config written."

echo "📡 Applying network settings..."
sudo netplan apply
ip a

read -p "Do you want to reboot now to apply all changes including group membership? (y/n): " reboot_choice
if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
  sudo reboot
fi

echo "📤 Final System Update & Upgrade (optional)"
read -p "Do you want to update & upgrade the system now? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
  sudo apt update -y && sudo apt upgrade -y
fi

echo "🐙 Docker Compose Version:"
docker-compose --version

echo "✅ Script completed successfully."
