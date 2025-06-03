#!/bin/bash

echo "🔧 Updating & installing dependencies..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install curl ufw iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip -y

echo "🧹 Removing old docker versions..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

echo "🐋 Installing Docker..."
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo "✅ Docker installed. Testing..."
sudo docker run hello-world

echo "🚀 Installing Drosera CLI..."
curl -L https://app.drosera.io/install | bash
source ~/.bashrc
droseraup

echo "🔨 Installing Foundry..."
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup

echo "🍞 Installing Bun..."
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

echo "📁 Creating drosera trap folder..."
mkdir -p ~/my-drosera-trap
cd ~/my-drosera-trap

# Prompt GitHub identity
read -p "📧 Enter your GitHub Email: " github_email
read -p "👤 Enter your GitHub Username: " github_username

git config --global user.email "$github_email"
git config --global user.name "$github_username"

echo "📦 Initializing Drosera Trap with Foundry template..."
forge init -t drosera-network/trap-foundry-template

echo "📚 Installing JS dependencies with Bun..."
bun install

echo "🛠️ Building project..."
forge build

# Prompt private key and RPC
read -p "🔑 Enter your EVM private key (Holesky ETH funded): " evm_key
read -p "🌐 Enter your Holesky RPC URL (from Alchemy or QuickNode): " rpc_url

echo "📡 Deploying Trap..."
DROSERA_PRIVATE_KEY="$evm_key" drosera apply --eth-rpc-url "$rpc_url"

echo ""
echo "✅ Trap deployment done. Now check it at https://app.drosera.io/"
echo "👉 Connect your wallet and look under 'Traps Owned'"
echo "🚀 Finally, run 'drosera dryrun' to begin fetching blocks"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💥  SCRIPT WRITTEN BY: **SAINT KHEN** (@admirkhen) 💥"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
