# Dotfiles

## About Me
Hi, I'm Coofle420! I'm a Linux enthusiast who enjoys customizing my desktop environment. This is my personal collection of dotfiles that I use to maintain a consistent and efficient workflow across my systems.

### My Setup
- **OS**: Arch Linux
- **WM**: Qtile
- **Terminal**: Kitty
- **Shell**: Zsh
- **Editor**: Neovim
- **Compositor**: Picom
- **Application Launcher**: Rofi
- **Notification Daemon**: Dunst

## What's Inside

This repository contains my personal dotfiles for:
- Qtile window manager
- Picom compositor
- Rofi application launcher
- Dunst notification daemon

## Screenshot
![Desktop Screenshot](screenshots/desktop.png)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/Coofle420/dotfiles.git
```

2. Create symbolic links:
```bash
# Create symbolic links for each config
ln -s ~/dotfiles/.config/qtile ~/.config/qtile
ln -s ~/dotfiles/.config/picom ~/.config/picom
ln -s ~/dotfiles/.config/rofi ~/.config/rofi
ln -s ~/dotfiles/.config/dunst ~/.config/dunst
```
