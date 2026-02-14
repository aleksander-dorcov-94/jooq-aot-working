#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Ultimate Post-Install Script..."
echo "------------------------------------------------------------"
echo "📦 This script will install:"
echo "🔹 System: Updates, Restricted Extras, Dual-Boot Time Fix"
echo "🔹 Shell: Zsh & Oh My Zsh (Default), Aliases, eza"
echo "🔹 Fonts: JetBrains Mono Nerd Font"
echo "🔹 Drivers & Desktop: Mesa Drivers, COSMIC Desktop, Fastfetch"
echo "🔹 Browsers & Terminal: Chrome, Brave, Warp Terminal"
echo "🔹 DevOps: Docker (No-Sudo), kubectl, k9s, kubefwd"
echo "🔹 Development: IntelliJ IDEA, VS Code, SDKMAN!, Micro Editor, Postman"
echo "🔹 Workarounds: Night Light (drm-colortemp)"
echo "🔹 Other: BTop, VLC"
echo "------------------------------------------------------------"

# --- 1. System Updates & Basic Configuration ---
echo "🔧 Updating system and fixing dual-boot clock..."
sudo apt update && sudo apt upgrade -y
timedatectl set-local-rtc 1 --adjust-system-clock
sudo apt install -y ubuntu-restricted-extras curl wget gpg zip unzip git fontconfig

# --- 2. Zsh & Oh My Zsh ---
echo "🐚 Installing Zsh and Oh My Zsh..."
sudo apt install -y zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
sudo chsh -s $(which zsh) $USER

# --- 3. Repository Setup (PPAs & External Repos) ---
echo "📦 Adding Repositories..."
sudo add-apt-repository -y ppa:hepp3n/cosmic-epoch
sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
sudo add-apt-repository -y ppa:kisak/kisak-mesa

# Brave Browser Repo
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# eza Repo
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list

# Docker Repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Kubectl Repo
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

# --- 4. Font Installation (JetBrains Mono Nerd Font) ---
echo "🔡 Installing JetBrains Mono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
wget -nc https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d "$FONT_DIR"
rm JetBrainsMono.zip
fc-cache -fv

# --- 5. Core Software Installation ---
echo "🖥️  Installing Desktop & DevOps Tools..."
sudo apt install -y cosmic-session fastfetch kubectl docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin eza brave-browser

# --- 6. kubefwd Installation ---
echo "🔌 Installing kubefwd..."
KFWD_VERSION=$(curl -s https://api.github.com/repos/txn2/kubefwd/releases/latest | grep tag_name | cut -d '"' -f 4)
wget -nc "https://github.com/txn2/kubefwd/releases/download/${KFWD_VERSION}/kubefwd_amd64.deb"
sudo dpkg -i kubefwd_amd64.deb || sudo apt install -f -y
rm kubefwd_amd64.deb

# --- 7. Night Light Workaround ---
echo "🌙 Setting up Night Light workaround..."
sudo apt install -y build-essential libdrm-dev linux-libc-dev libnotify-bin
if [ ! -d "drm-colortemp" ]; then
    git clone https://github.com/jjo/drm-colortemp.git
fi
cd drm-colortemp && make && sudo ./install_daemon.sh && cd ..

# --- 8. Browsers & Terminal ---
echo "🌐 Installing Chrome and Warp..."
wget -nc https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
wget -nc https://app.warp.dev/download?package=deb -O warp-terminal.deb
sudo apt install -y ./warp-terminal.deb

# --- 9. Developer Tools ---
echo "🛠️  Installing CLI Tools & SDKs..."
curl https://getmic.ro | bash
sudo install micro /usr/local/bin/ && rm micro
curl -sS https://webi.sh/k9s | sh
curl -s "https://get.sdkman.io" | bash

# --- 10. Snaps & Permissions ---
echo "📝 Installing Snaps and configuring Docker..."
sudo snap install intellij-idea --classic
sudo snap install code --classic
sudo snap install postman
sudo snap install btop
sudo snap install vlc

if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker $USER

# --- 11. Zsh Aliases Configuration (Smart Placement) ---
echo "⚙️  Adding custom aliases to .zshrc..."
if ! grep -q "alias lst=" "$HOME/.zshrc"; then
    # We find the line BEFORE the SDKMAN block and insert there
    sed -i '/#THIS MUST BE AT THE END/i \
# --- Custom Aliases ---\
alias ls="eza --icons"\
alias lst="eza --tree --icons --ignore-glob='\''node_modules|target|dist|build|.git|.idea|.vscode|.gradle|.mvn|coverage|.next|.nuxt|.angular|bower_components|__pycache__|.svn|.hg|.DS_Store|*.class|*.jar|*.war|*.ear|logs'\''"\
alias nano="micro"\
# ----------------------\
' "$HOME/.zshrc"
    echo "✅ Aliases inserted before SDKMAN block."
fi

echo "------------------------------------------------------------"
echo "✅ SETUP COMPLETE! REBOOTING IN 5 SECONDS..."
echo "------------------------------------------------------------"
sleep 5
sudo reboot
