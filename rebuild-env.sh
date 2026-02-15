#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- 0. Color Definitions ---
CYAN='\e[1;36m'
NC='\e[0m' # No Color (Reset)

echo -e "${CYAN}------------------------------------------------------------${NC}"
echo -e "${CYAN}📦 What this script installs and does:${NC}"
echo -e "${CYAN}🔹 OS: Core Updates, Media Extras, GRUB (1s) & RTC Sync${NC}"
echo -e "${CYAN}🔹 Shell: Zsh/Oh My Zsh with eza icons & Shorthand Aliases${NC}"
echo -e "${CYAN}🔹 UI: JetBrains Mono Nerd Font, COSMIC DE, & Fastfetch${NC}"
echo -e "${CYAN}🔹 Graphics: Kisak-Mesa Drivers (Vulkan/OpenGL Optimization)${NC}"
echo -e "${CYAN}🔹 Apps: Chrome, Brave, Warp, Postman, VLC, BTop${NC}"
echo -e "${CYAN}🔹 DevOps: Docker (No-Sudo), Kubectl, K9s, Kubefwd Tunneling${NC}"
echo -e "${CYAN}🔹 Dev Stack: IntelliJ IDEA, VS Code, SDKMAN!, & Micro Editor${NC}"
echo -e "${CYAN}🔹 Display: 4500K tint via drm-colortemp (Source Build)${NC}"
echo -e "${CYAN}------------------------------------------------------------${NC}"

# --- 1. System Updates & Basic Configuration ---
echo -e "${CYAN}🔧 Syncing repositories and upgrading system packages...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${CYAN}⏳ Optimizing GRUB: Setting 1s timeout and fixing recordfail hang...${NC}"
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
sudo sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub

if ! grep -q "GRUB_RECORDFAIL_TIMEOUT" /etc/default/grub; then
    echo "GRUB_RECORDFAIL_TIMEOUT=1" | sudo tee -a /etc/default/grub
else
    sudo sed -i 's/^GRUB_RECORDFAIL_TIMEOUT=.*/GRUB_RECORDFAIL_TIMEOUT=1/' /etc/default/grub
fi
sudo update-grub

echo -e "${CYAN}⏰ Aligning RTC for Dual-Boot and installing base build-tools...${NC}"
timedatectl set-local-rtc 1 --adjust-system-clock
sudo apt install -y ubuntu-restricted-extras curl wget gpg zip unzip git fontconfig

# --- 2. Zsh & Oh My Zsh ---
echo -e "${CYAN}🐚 Configuring Zsh as primary shell and deploying Oh My Zsh...${NC}"
sudo apt install -y zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
sudo chsh -s $(which zsh) $USER

# --- 3. Repository Setup (PPAs & External Repos) ---
echo -e "${CYAN}📦 Injecting PPAs for COSMIC, Fastfetch, and Mesa GPU Drivers...${NC}"
sudo add-apt-repository -y ppa:hepp3n/cosmic-epoch
sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
sudo add-apt-repository -y ppa:kisak/kisak-mesa

echo -e "${CYAN}🔑 Importing GPG keys for Brave, eza, Docker, and Kubernetes...${NC}"
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
echo -e "${CYAN}🔡 Deploying JetBrains Mono Nerd Font for terminal aesthetics...${NC}"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
wget -nc https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d "$FONT_DIR"
rm JetBrainsMono.zip
fc-cache -fv

# --- 5. Core Software Installation ---
echo -e "${CYAN}🖥️  Installing COSMIC Desktop, Fastfetch, Docker Suite, Kubectl, and eza and Brave...${NC}"
sudo apt install -y cosmic-session fastfetch kubectl docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin eza brave-browser

# --- 6. kubefwd Installation ---
echo -e "${CYAN}🔌 Pulling latest kubefwd binary from GitHub for K8s tunneling...${NC}"
KFWD_VERSION=$(curl -s https://api.github.com/repos/txn2/kubefwd/releases/latest | grep tag_name | cut -d '"' -f 4)
wget -nc "https://github.com/txn2/kubefwd/releases/download/${KFWD_VERSION}/kubefwd_amd64.deb"
sudo dpkg -i kubefwd_amd64.deb || sudo apt install -f -y
rm kubefwd_amd64.deb

# --- 7. Night Light Workaround ---
echo -e "${CYAN}🌙 Compiling drm-colortemp Night Light workaround from source...${NC}"
sudo apt install -y build-essential libdrm-dev linux-libc-dev libnotify-bin
if [ ! -d "drm-colortemp" ]; then
    git clone https://github.com/jjo/drm-colortemp.git
fi
cd drm-colortemp && make && sudo ./install_daemon.sh && cd ..

# --- 8. Browsers & Terminal ---
echo -e "${CYAN}🌐 Downloading and installing Google Chrome and Warp Terminal...${NC}"
wget -nc https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
wget -nc https://app.warp.dev/download?package=deb -O warp-terminal.deb
sudo apt install -y ./warp-terminal.deb

# --- 9. Developer Tools ---
echo -e "${CYAN}🛠️  Setting up Micro editor, K9s, and SDKMAN! Manager...${NC}"
curl https://getmic.ro | bash
sudo install micro /usr/local/bin/ && rm micro
curl -sS https://webi.sh/k9s | sh
curl -s "https://get.sdkman.io" | bash

# --- 10. Snaps & Permissions ---
echo -e "${CYAN}📝 Installing Snaps (IntelliJ, VSCode, Postman, BTop and VLC) and granting Docker permissions...${NC}"
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
echo -e "${CYAN}⚙️  Configuring .zshrc custom  aliases for eza, micro and intellij...${NC}"
if ! grep -q "alias idea=" "$HOME/.zshrc"; then
    sed -i '/#THIS MUST BE AT THE END/i \
# --- Custom Aliases ---\
alias ls="eza --icons"\
alias lst="eza --tree --icons --ignore-glob='\''node_modules|target|dist|build|.git|.idea|.vscode|.gradle|.mvn|coverage|.next|.nuxt|.angular|bower_components|__pycache__|.svn|.hg|.DS_Store|*.class|*.jar|*.war|*.ear|logs'\''"\
alias nano="micro"\
alias idea="intellij-idea"\
# ----------------------\
' "$HOME/.zshrc"
    echo -e "${CYAN}✅ Environment variables and aliases integrated into shell.${NC}"
fi

# script ending
echo -e "${CYAN}------------------------------------------------------------${NC}"
echo -e "${CYAN}✅ SETUP COMPLETE! Finalizing changes and rebooting in 5s...${NC}"
echo -e "${CYAN}------------------------------------------------------------${NC}"
sleep 5
sudo reboot
