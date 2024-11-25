#!/bin/bash

echo "🚀 Installing Coofle's dotfiles..."

# Check if running on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo "❌ This script is designed for Arch Linux. Please install dependencies manually."
    exit 1
fi

# Install required packages
echo "📦 Installing required packages..."
sudo pacman -S --needed qtile kitty python python-pip playerctl feh curl ncmpcpp htop

# Install required Python packages
echo "🐍 Installing Python packages..."
pip install --user psutil

# Create backup of existing configs
echo "💾 Creating backup of existing configs..."
mkdir -p ~/.config-backup
for dir in qtile kitty; do
    if [ -d ~/.config/$dir ]; then
        mv ~/.config/$dir ~/.config-backup/$dir
    fi
done

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p ~/.config/qtile/scripts
mkdir -p ~/.cache/qtile/spotify
mkdir -p ~/.local/share/fonts

# Copy configurations
echo "📄 Copying configuration files..."
cp -r qtile/* ~/.config/qtile/
cp -r kitty/* ~/.config/kitty/

# Copy fonts if they exist
if [ -d fonts ]; then
    echo "🔤 Installing fonts..."
    cp -r fonts/* ~/.local/share/fonts/
    fc-cache -fv
fi

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x ~/.config/qtile/scripts/*

echo "✨ Installation complete! Please log out and log back in to apply changes."
echo "📝 Check the README.md for keybindings and customization options."
