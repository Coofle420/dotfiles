# Coofle's Dotfiles 

A collection of my personal dotfiles for my Linux setup, featuring a cyberpunk-themed Qtile configuration with custom widgets and scratchpads.

![Screenshot of the setup](screenshots/preview.png)

## Features 

- **Window Manager**: Qtile with custom configuration
  - Cyberpunk color scheme
  - Custom Spotify widget with album art
  - System monitoring widgets
  - Scratchpad support
  - Dynamic workspace management

- **Terminal**: Kitty
  - Custom color scheme
  - Nerd Font support
  - GPU acceleration

- **Key Features**:
  - Spotify integration with album art display
  - System monitoring with graphs
  - Quick access scratchpads
  - Modern, neon-themed UI
  - Efficient keyboard-driven workflow

## Prerequisites 

```bash
# Arch Linux / Manjaro
sudo pacman -S qtile kitty python python-pip playerctl feh curl ncmpcpp htop

# Install Python packages
pip install psutil
```

## Installation 

1. **Clone the repository**:
```bash
git clone https://github.com/Coofle420/dotfiles.git
cd dotfiles
```

2. **Create backup of existing configs**:
```bash
mkdir -p ~/.config-backup
cp -r ~/.config/qtile ~/.config-backup/
cp -r ~/.config/kitty ~/.config-backup/
```

3. **Install the dotfiles**:
```bash
# Create necessary directories
mkdir -p ~/.config/qtile/scripts
mkdir -p ~/.cache/qtile/spotify

# Copy configurations
cp -r qtile/* ~/.config/qtile/
cp -r kitty/* ~/.config/kitty/

# Make scripts executable
chmod +x ~/.config/qtile/scripts/*
```

4. **Install fonts**:
```bash
# Create fonts directory
mkdir -p ~/.local/share/fonts

# Copy fonts
cp -r fonts/* ~/.local/share/fonts/

# Refresh font cache
fc-cache -fv
```

## Keybindings 

### Window Management
- `Super + [1-9]`: Switch to workspace
- `Super + Shift + [1-9]`: Move window to workspace
- `Super + [h,j,k,l]`: Navigate windows
- `Super + Shift + [h,j,k,l]`: Move windows
- `Super + Space`: Toggle floating
- `Super + f`: Toggle fullscreen

### Scratchpads
- `Super + t`: Terminal scratchpad
- `Super + p`: Python REPL
- `Super + m`: Music player (ncmpcpp)
- `Super + h`: System monitor (htop)

### Media Controls
- Left click on Spotify widget: Play/Pause
- Right click on Spotify widget: Show/Hide album art
- Mouse wheel on Spotify widget: Next/Previous track

## Customization 

### Changing Colors
Edit `~/.config/qtile/config.py`:
```python
colors = {
    'bg': '#0a0b16',
    'bg_dark': '#080910',
    'fg': '#c0caf5',
    'neon_pink': '#ff007c',
    'neon_purple': '#bf00ff',
    'neon_blue': '#00fff9',
    # ... add more colors
}
```

### Modifying Scratchpads
Adjust size and position in `~/.config/qtile/config.py`:
```python
DropDown("term", terminal,
         width=0.8,    # 80% of screen width
         height=0.6,   # 60% of screen height
         x=0.1,        # 10% from left
         y=0.1,        # 10% from top
         opacity=1.0)
```

## Troubleshooting 

1. **Spotify widget not working**:
   - Ensure playerctl is installed
   - Check if spotify_status.py is executable
   - Verify Spotify is running

2. **Missing icons**:
   - Make sure JetBrainsMono Nerd Font is installed
   - Run `fc-cache -fv` to refresh font cache

3. **Scratchpads not appearing**:
   - Check if required programs are installed (python, htop, ncmpcpp)
   - Verify keybindings in config.py

## Contributing 

Feel free to submit issues and enhancement requests!
