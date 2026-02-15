#!/bin/bash

# Exit on any error
set -e

# Variables
GITHUB_REPO="https://github.com/cabhinaba3/dotfiles" # <-- Replace with your GitHub repo (owner/repo)
NVIM_CONFIG_FILE="nvim"                              # Name of the config file in the repo
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# Check if git is installed
if ! command -v git &>/dev/null; then
  echo "Git not found. Installing git..."
  if [[ -f /etc/debian_version ]]; then
    sudo apt update && sudo apt install -y git
  elif [[ -f /etc/redhat-release ]]; then
    sudo yum install -y git
  else
    echo "Unsupported OS. Please install git manually."
    exit 1
  fi
fi

# Temporary clone directory
TMP_DIR=$(mktemp -d)

echo "Cloning GitHub repository..."
git clone https://github.com/$GITHUB_REPO.git "$TMP_DIR"

# Verify that nvim config exists
if [[ ! -f "$TMP_DIR/$NVIM_CONFIG_FILE" ]]; then
  echo "Error: $NVIM_CONFIG_FILE not found in the repo."
  rm -rf "$TMP_DIR"
  exit 1
fi

# Create nvim config directory if it doesn't exist
mkdir -p "$NVIM_CONFIG_DIR"

# Copy config file to correct location
echo "Installing nvim config..."
cp "$TMP_DIR/$NVIM_CONFIG_FILE" "$NVIM_CONFIG_DIR/init.vim"

# Clean up
rm -rf "$TMP_DIR"

echo "nvim config installed successfully at $NVIM_CONFIG_DIR/init.vim"
