from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
import os
import subprocess
import psutil
from typing import List
from libqtile.widget import base

mod = "mod4"  # Super/Windows key
terminal = "kitty"  # Set kitty as default terminal

# Cyberpunk color scheme with gradients
colors = {
    'bg': '#0a0b16',
    'bg_dark': '#080910',
    'fg': '#c0caf5',
    'neon_pink': '#ff007c',
    'neon_purple': '#bf00ff',
    'neon_blue': '#00fff9',
    'cyber_yellow': '#f0c674',
    'cyber_green': '#00ff9f',
    'cyber_red': '#ff3c3c',
    'inactive': '#1a1b26',
    'urgent': '#ff3c3c',
    'gradient_1': '#ff007c',
    'gradient_2': '#bf00ff',
    'gradient_3': '#00fff9',
    'bar_bg': '#12001F',  # Dark purple background
    'bar_border': '#bf00ff',  # Neon purple border
}

# Custom separator widget with cyberpunk styling
def create_separator(color='gradient_1', padding=0, size=18):
    return widget.TextBox(
        text='',  # Using a simpler separator
        foreground=colors[color],
        padding=padding,
        fontsize=size,
    )

# Custom Music Widget
class MusicWidget(base.ThreadPoolText):
    defaults = [
        ("update_interval", 0.5, "Update interval in seconds"),
        ("play_icon", "󰐊", "Play icon"),
        ("pause_icon", "󰏤", "Pause icon"),
    ]

    def __init__(self, **config):
        base.ThreadPoolText.__init__(self, "", **config)
        self.add_defaults(MusicWidget.defaults)
        self.add_callbacks({
            'Button1': self.toggle_play_pause,
            'Button4': self.next_track,
            'Button5': self.previous_track,
        })

    def get_player_status(self):
        try:
            return subprocess.check_output(['playerctl', 'status']).decode().strip()
        except:
            return 'Stopped'

    def get_player_metadata(self, field):
        try:
            return subprocess.check_output(['playerctl', 'metadata', field]).decode().strip()
        except:
            return ''

    def toggle_play_pause(self):
        subprocess.run(['playerctl', 'play-pause'])

    def next_track(self):
        subprocess.run(['playerctl', 'next'])

    def previous_track(self):
        subprocess.run(['playerctl', 'previous'])

    def poll(self):
        status = self.get_player_status()
        if status == 'Stopped':
            return ' No music playing'
        
        artist = self.get_player_metadata('artist')
        title = self.get_player_metadata('title')
        icon = self.pause_icon if status == 'Playing' else self.play_icon
        
        if not artist and not title:
            return ' No metadata'
            
        artist = (artist[:20] + '...') if len(artist) > 20 else artist
        title = (title[:30] + '...') if len(title) > 30 else title
        
        return f"{icon} {artist} - {title}"

def init_widgets_list():
    return [
        widget.CurrentLayout(
            foreground=colors['neon_purple'],
            padding=10,
            background=colors['bar_bg'],
        ),
        create_separator('gradient_1'),
        
        widget.GroupBox(
            active=colors['fg'],
            inactive=colors['inactive'],
            highlight_method='line',
            highlight_color=[colors['bar_bg'], colors['bar_bg']],
            this_current_screen_border=colors['neon_purple'],
            urgent_border=colors['cyber_red'],
            urgent_text=colors['cyber_red'],
            padding=6,         # Moderate padding
            borderwidth=3,     # Standard border
            rounded=False,
            margin_y=4,        # Standard margin
            fontsize=18,       # More moderate font size
            spacing=6,         # Balanced spacing
            disable_drag=True,
            background=colors['bar_bg'],
        ),
        create_separator('gradient_2'),
        
        widget.WindowName(
            foreground=colors['neon_blue'],
            padding=10,
            max_chars=40,
            background=colors['bar_bg'],
        ),
        
        widget.Spacer(),
        
        # Previous Track Button
        widget.TextBox(
            text='',  # Previous track
            foreground=colors['neon_purple'],
            padding=3,
            fontsize=16,
            background=colors['bar_bg'],
            mouse_callbacks={'Button1': lambda: subprocess.run(['playerctl', 'previous'])}
        ),
        widget.TextBox(
            text='󰙣',  # Skip back 10s
            foreground=colors['neon_purple'],
            padding=3,
            fontsize=14,
            background=colors['bar_bg'],
            mouse_callbacks={'Button1': lambda: subprocess.run(['playerctl', 'position', '10-'])}
        ),
        
        # Music Widget with metadata
        MusicWidget(
            foreground=colors['cyber_green'],
            padding=10,
            update_interval=0.5,
            background=colors['bar_bg'],
        ),
        
        # Center Play Button
        widget.TextBox(
            text='',  # Play/Pause
            foreground=colors['neon_pink'],
            padding=3,
            fontsize=16,
            background=colors['bar_bg'],
            mouse_callbacks={'Button1': lambda: subprocess.run(['playerctl', 'play-pause'])}
        ),
        
        # Next Controls
        widget.TextBox(
            text='󰙡',  # Skip forward 10s
            foreground=colors['neon_purple'],
            padding=3,
            fontsize=14,
            background=colors['bar_bg'],
            mouse_callbacks={'Button1': lambda: subprocess.run(['playerctl', 'position', '10+'])}
        ),
        widget.TextBox(
            text='',  # Next track
            foreground=colors['neon_purple'],
            padding=3,
            fontsize=16,
            background=colors['bar_bg'],
            mouse_callbacks={'Button1': lambda: subprocess.run(['playerctl', 'next'])}
        ),
        
        widget.Spacer(),
        
        # CPU Graph with neon effect
        widget.CPUGraph(
            border_color=colors['neon_pink'],
            graph_color=colors['neon_pink'],
            fill_color=colors['neon_pink'].replace('ff', '33'),
            line_width=2,
            width=50,
            margin_y=5,
            padding=5,
            background=colors['bar_bg'],
        ),
        widget.CPU(
            format=' {load_percent}%',
            foreground=colors['cyber_green'],
            padding=10,
            update_interval=2.0,
            background=colors['bar_bg'],
        ),
        create_separator('gradient_2'),
        
        # Memory Graph with neon effect
        widget.MemoryGraph(
            border_color=colors['neon_blue'],
            graph_color=colors['neon_blue'],
            fill_color=colors['neon_blue'].replace('ff', '33'),
            line_width=2,
            width=50,
            margin_y=5,
            padding=5,
            background=colors['bar_bg'],
        ),
        widget.Memory(
            format=' {MemPercent}%',
            foreground=colors['cyber_yellow'],
            padding=10,
            update_interval=2.0,
            background=colors['bar_bg'],
        ),
        create_separator('gradient_3'),
        
        # Volume with pulse audio
        widget.Volume(
            fmt='󰕾 {}',
            foreground=colors['neon_purple'],
            padding=10,
            update_interval=0.1,
            step=5,
            device='pulse',
            background=colors['bar_bg'],
        ),
        create_separator('gradient_1'),
        
        # Date and time with modern styling
        widget.TextBox(
            text='',  # Clock icon
            foreground=colors['neon_purple'],
            padding=2,
            fontsize=16,
            background=colors['bar_bg'],
        ),
        widget.Clock(
            format='%H:%M',
            foreground=colors['neon_pink'],
            padding=2,
            fontsize=14,
            background=colors['bar_bg'],
        ),
        widget.TextBox(
            text='•',  # Dot separator
            foreground=colors['neon_purple'],
            padding=4,
            fontsize=14,
            background=colors['bar_bg'],
        ),
        widget.TextBox(
            text='',  # Calendar icon
            foreground=colors['neon_purple'],
            padding=2,
            fontsize=14,
            background=colors['bar_bg'],
        ),
        widget.Clock(
            format='%Y-%m-%d',
            foreground=colors['neon_blue'],
            padding=4,
            fontsize=13,
            background=colors['bar_bg'],
        ),
        widget.TextBox(
            text='•',  # Dot separator
            foreground=colors['neon_purple'],
            padding=4,
            fontsize=14,
            background=colors['bar_bg'],
        ),
        
        widget.Systray(
            padding=10,
            icon_size=16,
            background=colors['bar_bg'],
        ),
    ]

keys = [
    # Essential window control
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    
    # Move windows
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    
    # Grow/shrink windows
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    
    # Toggle floating and fullscreen
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    Key([mod, "shift"], "space", lazy.window.toggle_floating(), desc="Toggle floating"),
    
    # Switch focus between screens
    Key([mod], "period", lazy.next_screen(), desc="Move focus to next monitor"),
    Key([mod], "comma", lazy.prev_screen(), desc="Move focus to prev monitor"),
    
    # Launch applications
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "space", lazy.spawn("rofi -show drun -show-icons"), desc="Application launcher"),
    Key([mod], "r", lazy.spawn("rofi -show run"), desc="Run command"),
    Key([mod, "shift"], "e", lazy.spawn("rofi -show emoji -modi emoji"), desc="Emoji picker"),
    Key([mod], "p", lazy.spawn("/home/demitri/.config/rofi/powermenu.sh"), desc="Power menu"),
    Key([mod], "b", lazy.spawn("firefox"), desc="Launch Firefox"),
    
    # Quick Settings Panel
    Key([mod], "x", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/quick_settings.sh")), 
        desc="Show Quick Settings"),
    
    # Volume Control
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"), desc="Volume Up"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"), desc="Volume Down"),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Toggle Mute"),
    
    # Media Control
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play/Pause"),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Next Track"),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Previous Track"),
]

# Add group switching keys
for i in range(1, 10):
    keys.extend([
        # Switch to group
        Key([mod], str(i), lazy.group[str(i)].toscreen(),
            desc=f"Switch to group {i}"),
        # Move window to group
        Key([mod, "shift"], str(i), lazy.window.togroup(str(i)),
            desc=f"Move focused window to group {i}"),
    ])

# Window switcher function
def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)

def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)

def window_to_previous_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i != 0:
        group = qtile.screens[i - 1].group.name
        qtile.current_window.togroup(group)

def window_to_next_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i + 1 != len(qtile.screens):
        group = qtile.screens[i + 1].group.name
        qtile.current_window.togroup(group)

# Add to keys list
keys.extend([
    # Window switcher with rofi
    Key(['mod1'], 'Tab', lazy.spawn('rofi -show window -window-format "{c}: {t}"'), desc='Window switcher'),
    
    # Spotify controls
    Key([], 'XF86AudioPlay', lazy.spawn('playerctl play-pause'), desc='Play/Pause Spotify'),
    Key([], 'XF86AudioNext', lazy.spawn('playerctl next'), desc='Next Spotify track'),
    Key([], 'XF86AudioPrev', lazy.spawn('playerctl previous'), desc='Previous Spotify track'),
])

groups = [
    Group("1", label="󰖟"),  # Terminal
    Group("2", label="󰈹"),  # Web
    Group("3", label="󰨞"),  # Code
    Group("4", label="󰉋"),  # Files
    Group("5", label="󰙯"),  # Media
    Group("6", label="󰭹"),  # Chat
    Group("7", label="󰊗"),  # Design
    Group("8", label="󰇮"),  # Games
    Group("9", label="󰕧"),  # Settings
]

# Update layouts with cyberpunk colors
layouts = [
    layout.Columns(
        border_focus=colors['neon_pink'],
        border_focus_stack=colors['neon_purple'],
        border_normal=colors['inactive'],
        border_normal_stack=colors['inactive'],
        border_width=3,
        border_on_single=True,
        margin=4,
        margin_on_single=4,
    ),
    layout.Max(),
    layout.MonadTall(
        border_focus=colors['neon_pink'],
        border_normal=colors['inactive'],
        border_width=3,
        margin=4,
        single_border_width=3,
    ),
    layout.MonadWide(
        border_focus=colors['neon_pink'],
        border_normal=colors['inactive'],
        border_width=3,
        margin=4,
        single_border_width=3,
    ),
    layout.Floating(
        border_focus=colors['neon_purple'],
        border_normal=colors['inactive'],
        border_width=3,
    ),
]

# Update screens configuration - bar only on primary monitor
screens = [
    Screen(  # Primary monitor with bar
        top=bar.Bar(
            init_widgets_list(),
            28,  # Slightly taller bar
            background=colors['bar_bg'],
            margin=[5, 8, 2, 8],  # [top, right, bottom, left]
            border_width=[2, 0, 2, 0],  # [top, right, bottom, left]
            border_color=[colors['bar_border'], "000000", colors['bar_border'], "000000"],
            opacity=0.95,
        ),
    ),
    Screen()  # Secondary monitor without bar
]

widget_defaults = dict(
    font='JetBrainsMono Nerd Font',
    fontsize=13,
    padding=3,
    background=colors['bar_bg'],
    foreground=colors['fg'],
)

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

# Floating layout with distinct purple borders
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
        Match(wm_class="pavucontrol"),
        Match(wm_class="nm-connection-editor"),
        Match(wm_class="blueman-manager"),
        Match(wm_class="gpick"),
        Match(wm_class="lxappearance"),
        Match(wm_class="nitrogen"),
        Match(wm_class="arandr"),
        Match(wm_class="feh"),
        Match(wm_class="flameshot"),
    ],
    border_focus=colors['neon_purple'],    # Bright purple for active floating windows
    border_normal=colors['inactive'],      # Dark for inactive floating windows
    border_width=3,                        # Thicker borders
)

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.Popen([home])
    # Set maximum refresh rates for monitors
    subprocess.run([
        "xrandr",
        "--output", "DisplayPort-0", "--mode", "1920x1080", "--rate", "164.96",
        "--output", "HDMI-A-0", "--mode", "1920x1080", "--rate", "144", "--right-of", "DisplayPort-0"
    ])

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None
wmname = "Qtile"
