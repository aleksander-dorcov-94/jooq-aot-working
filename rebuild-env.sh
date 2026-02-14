#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- 0. Color Definitions ---
CYAN='\e[1;36m'
NC='\e[0m' # No Color (Reset)

echo -e "${CYAN}🚀 Starting Post-Install Script...${NC}"
echo -e "${CYAN}------------------------------------------------------------${NC}"
echo -e "${CYAN}📦 This script will install:${NC}"
echo -e "${CYAN}🔹 System: Updates, Restricted Extras, Dual-Boot Time Fix${NC}"
echo -e "${CYAN}🔹 Shell: Zsh & Oh My Zsh (Default), Aliases, eza${NC}"
echo -e "${CYAN}🔹 Fonts: JetBrains Mono Nerd Font${NC}"
echo -e "${CYAN}🔹 Drivers & Desktop: Mesa Drivers, COSMIC Desktop, Fastfetch${NC}"
echo -e "${CYAN}🔹 Browsers & Terminal: Chrome, Brave, Warp Terminal${NC}"
echo -e "${CYAN}🔹 DevOps: Docker (No-Sudo), kubectl, k9s, kubefwd${NC}"
echo -e "${CYAN}🔹 Development: IntelliJ IDEA, VS Code, SDKMAN!, Micro Editor, Postman, Git, Curl${NC}"
echo -e "${CYAN}🔹 Workarounds: Night Light (drm-colortemp)${NC}"
echo -e "${CYAN}🔹 Other: BTop, VLC${NC}"
echo -e "${CYAN}------------------------------------------------------------${NC}"

# --- 1. System Updates & Basic Configuration ---
echo -e "${CYAN}🔧 Updating system and fixing boot/time settings...${NC}"
sudo apt update && sudo apt upgrade -y

# GRUB (Boot Menu) Optimization
echo -e "${CYAN}⏳ Updating GRUB: Shortening boot menu timeout to 1 second...${NC}"
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub

# Fix for Ubuntu's hidden 30s timeout on failed boot/dual-boot
if ! grep -q "GRUB_RECORDFAIL_TIMEOUT" /etc/default/grub; then
    echo "GRUB_RECORDFAIL_TIMEOUT=1" | sudo tee -a /etc/default/grub
else
    sudo sed -i 's/^GRUB_RECORDFAIL_TIMEOUT=.*/GRUB_RECORDFAIL_TIMEOUT=1/' /etc/default/grub
fi
sudo update-grub

# Dual-boot clock fix and core packages
timedatectl set-local-rtc 1 --adjust-system-clock
sudo apt install -y ubuntu-restricted-extras curl wget gpg zip unzip git fontconfig

# --- 2. Zsh & Oh My Zsh ---
echo -e "${CYAN}🐚 Installing Zsh and Oh My Zsh...${NC}"
sudo apt install -y zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
sudo chsh -s $(which zsh) $USER

# --- 3. Repository Setup (PPAs & External Repos) ---
echo -e "${CYAN}📦 Adding Repositories Cosmic, Fastfetch, Mesa gpu drivers...${NC}"
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
echo -e "${CYAN}🔡 Installing JetBrains Mono Nerd Font...${NC}"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
wget -nc https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d "$FONT_DIR"
rm JetBrainsMono.zip
fc-cache -fv

# --- 5. Core Software Installation ---
echo -e "${CYAN}🖥️  Installing Desktop & DevOps Tools...${NC}"
sudo apt install -y cosmic-session fastfetch kubectl docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin eza brave-browser

# --- 6. kubefwd Installation ---
echo -e "${CYAN}🔌 Installing kubefwd...${NC}"
KFWD_VERSION=$(curl -s https://api.github.com/repos/txn2/kubefwd/releases/latest | grep tag_name | cut -d '"' -f 4)
wget -nc "https://github.com/txn2/kubefwd/releases/download/${KFWD_VERSION}/kubefwd_amd64.deb"
sudo dpkg -i kubefwd_amd64.deb || sudo apt install -f -y
rm kubefwd_amd64.deb

# --- 7. Night Light Workaround ---
echo -e "${CYAN}🌙 Setting up Night Light workaround for Cosmic...${NC}"
sudo apt install -y build-essential libdrm-dev linux-libc-dev libnotify-bin
if [ ! -d "drm-colortemp" ]; then
    git clone https://github.com/jjo/drm-colortemp.git
fi
cd drm-colortemp && make && sudo ./install_daemon.sh && cd ..

# --- 8. Browsers & Terminal ---
echo -e "${CYAN}🌐 Installing Chrome and Warp...${NC}"
wget -nc https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
wget -nc https://app.warp.dev/download?package=deb -O warp-terminal.deb
sudo apt install -y ./warp-terminal.deb

# --- 9. Developer Tools ---
echo -e "${CYAN}🛠️  Installing Micro and SDKMAN!...${NC}"
curl https://getmic.ro | bash
sudo install micro /usr/local/bin/ && rm micro
curl -sS https://webi.sh/k9s | sh
curl -s "https://get.sdkman.io" | bash

# --- 10. Snaps & Permissions ---
echo -e "${CYAN}📝 Installing Snaps (Intellij, VSCode, Postman, BTop, VLC) and configuring Docker...${NC}"
sudo snap install intellij-idea --classic
sudo snap install code --classic
sudo snap install postman
sudo snap install btop --edge
sudo snap install vlc

if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker $USER

# --- 11. Zsh Aliases Configuration (Smart Placement) ---
echo -e "${CYAN}⚙️  Adding custom aliases and IntelliJ path to .zshrc...${NC}"
if ! grep -q "alias idea=" "$HOME/.zshrc"; then
    # We find the line BEFORE the SDKMAN block and insert there
    sed -i '/#THIS MUST BE AT THE END/i \
# --- Custom Aliases ---\
alias ls="eza --icons"\
alias lst="eza --tree --icons --ignore-glob='\''node_modules|target|dist|build|.git|.idea|.vscode|.gradle|.mvn|coverage|.next|.nuxt|.angular|bower_components|__pycache__|.svn|.hg|.DS_Store|*.class|*.jar|*.war|*.ear|logs'\''"\
alias nano="micro"\
alias idea="intellij-idea"\
# ----------------------\
' "$HOME/.zshrc"
    echo -e "${CYAN}✅ IntelliJ alias and custom aliases inserted.${NC}"
fi

# script ending
echo -e "${CYAN}------------------------------------------------------------${NC}"
echo -e "${CYAN}✅ SETUP COMPLETE! REBOOTING IN 5 SECONDS...${NC}"
echo -e "${CYAN}------------------------------------------------------------${NC}"
sleep 5
sudo reboot
