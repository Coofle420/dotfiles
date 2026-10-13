# Mango config

My [Mango](https://github.com/DreamMaoMao/mango) (mangowm) Wayland compositor config on Artix Linux. Written for Mango **0.18+**, which uses `snake_case` config keys (`exec_once`, `window_rule`, `border_px`, ...). It will not load on 0.17 or older.

Setup: Mango + [Noctalia](https://github.com/noctalia-dev) shell, kitty, a dark-purple palette. Monitors: DP-2 2560x1440@200Hz (primary, VRR) and HDMI-A-1 1920x1080@144Hz.

## Files

| File | What it does |
|---|---|
| `config.conf` | Entry point. Autostart (`exec_once`), monitor rules, then sources the files below. |
| `visuals.conf` | Borders, gaps, corner radius, shadows, animations. |
| `layouts.conf` | Layout settings (master/stack, scroller, dwindle, ...) and per-tag rules. |
| `input.conf` | Keyboard repeat, focus behaviour, cursor. |
| `rules.conf` | Window and layer rules (floating kitty, no swallowing, launcher animation). |
| `binds.conf` | Keybinds. |
| `portals.sh` | Starts the screen-share portals with the right session environment. |
| `noctalia-template/mango.conf` | Noctalia colour template that writes `noctalia.conf` with the 0.18 key names. |

`noctalia.conf` is **not** in this repo. Noctalia generates it from my palette (via a user template) and `config.conf` loads it with `source_optional`. If it is missing, Mango still starts with default colours.

## Keybinds (Super-centric)

| Keys | Action |
|---|---|
| Super+Enter | Floating kitty |
| Super+Ctrl+Enter | Tiled kitty |
| Super+Space | App launcher |
| Super+S / Super+, | Control center / settings |
| Super+V / Super+W | Clipboard / wallpaper panel |
| Super+Shift+S, Print | Region screenshot |
| Shift+Print | Fullscreen screenshot |
| Super+B / Super+E | Browser / file manager |
| Super+R / T / Y / X | Reddit / Twitch / YouTube / X.com |
| Super+Shift+F | yazi in a floating kitty |
| Super+Shift+K | Steam |
| Super+L | Lock |
| Super+Q | Close window |
| Super+F / Super+Ctrl+F | Fullscreen / fake fullscreen |
| Super+Shift+T | Toggle floating |
| Super+Tab | Cycle focus |
| Super+Shift+arrows (or H / J / ;) | Focus window in that direction |
| Super+Ctrl+arrows (or H / J / K / ;) | Swap window in that direction |
| Super+Alt+arrows | Move a floating window by 50px |
| Super+[ / Super+] | Shrink / grow window width |
| Super+Ctrl+[ / Super+Ctrl+] | Shrink / grow window height |
| Super+1..9 | Go to workspace |
| Super+Shift+1..9 | Send window to workspace |
| Super+Ctrl+Shift+arrows | Focus other monitor |
| Super+Alt+Shift+arrows | Send window to other monitor |
| Super+Shift+R | Reload config |
| Super+Shift+Q | Quit Mango |

Mouse: Super+left-drag moves a window, Super+right-drag resizes it. Middle-click is left free for apps (e.g. camera rotation in games).

`binds.conf` has the full list, including media and brightness keys.

## Install

Only Arch/Artix is tested by me. The other distros below are copied from the upstream install docs ([Mango](https://mangowm.github.io/docs/installation), [Noctalia](https://docs.noctalia.dev/noctalia/getting-started/installation/)), so check those if a step fails.

You need two things: **Mango** (0.18 or newer) and **Noctalia** (v5, the shell/bar). Then clone this config.

### 1. Mango

| Distro | Command |
|---|---|
| Arch / Artix / CachyOS | `sudo pacman -S mangowm` (or `yay -S mangowm-git` for the git version) |
| Fedora | `dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release`, then `dnf install mangowm` |
| Gentoo | `emerge --ask --verbose eselect-repository`, `eselect repository enable guru`, `emerge --sync guru`, add `gui-libs/scenefx` and `gui-wm/mangowm` to `package.accept_keywords`, then `emerge --ask --verbose gui-wm/mangowm` |
| NixOS | Add the flake input `github:mangowm/mango` (with `inputs.nixpkgs.follows = "nixpkgs"`), import `inputs.mangowm.nixosModules.mango`, set `programs.mango.enable = true;` |
| Guix | Add the `mangowm` channel (`https://github.com/mangowm/mango.git`, branch `main`) to `~/.config/guix/channels.scm`, run `guix pull`, then `guix install mangowm` |
| AerynOS | `sudo moss install mangowm` |
| PikaOS | `pikman install mangowm` |
| Alpine (edge) | `apk add mangowm` exists in `community`, but when I checked (2026-10) it was **0.17.5, too old for this config**. Build 0.18+ from source (below). `wlroots0.20-dev` (0.20.2) and `scenefx-dev` (0.5) are in Alpine `community`, so install those with `apk` instead of building them by hand. |
| Debian / Ubuntu / openSUSE / Void | No package listed upstream. Build from source (below). |

**Build from source** (any distro; on Alpine skip the wlroots and scenefx clones and `apk add wlroots0.20-dev scenefx-dev` instead). Dependencies: wayland, wayland-protocols, libinput, libdrm, libxkbcommon, pixman, libdisplay-info, libliftoff, hwdata, seatd, pcre2, pango, cjson, xorg-xwayland, libxcb. wlroots and scenefx must be built by hand first:

```sh
git clone -b 0.20.2 https://gitlab.freedesktop.org/wlroots/wlroots.git
cd wlroots && meson build -Dprefix=/usr && sudo ninja -C build install && cd ..

git clone -b 0.5 https://github.com/wlrfx/scenefx.git
cd scenefx && meson build -Dprefix=/usr && sudo ninja -C build install && cd ..

git clone https://github.com/mangowm/mango.git
cd mango && meson build -Dprefix=/usr && sudo ninja -C build install
```

### 2. Noctalia

| Distro | Command |
|---|---|
| Arch / Artix / CachyOS | `sudo pacman -S noctalia` |
| Fedora 44+ | `sudo dnf install noctalia` (git snapshot: `sudo dnf copr enable lionheartp/Hyprland`, then `sudo dnf install noctalia-git`) |
| Debian Trixie / Sid, Ubuntu 26.04 | Install the key: `wget https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb && sudo dpkg -i nickh-archive-keyring.deb`. Add the source for your release: `sudo wget -O /etc/apt/sources.list.d/noctalia-trixie.sources https://pkg.noctalia.dev/deb/noctalia-trixie.sources` (use `noctalia-unstable.sources` for Sid, `noctalia-resolute.sources` for Ubuntu 26.04). Then `sudo apt update && sudo apt install noctalia`. amd64 and arm64 only. |
| openSUSE (Tumbleweed / Slowroll only) | `sudo zypper addrepo --refresh --name noctalia-v5 https://download.opensuse.org/repositories/home:neifua:Noctalia/openSUSE_Tumbleweed/home:neifua:Noctalia.repo` (use `openSUSE_Slowroll` for Slowroll), then `sudo zypper refresh && sudo zypper install noctalia`. Leap 16.0 can't build it. |
| Gentoo | Enable the GURU overlay, add `gui-apps/noctalia ~amd64` to `package.accept_keywords`, then `emerge --ask gui-apps/noctalia` |
| Guix | Package `noctalia-shell` (main channel), or add the `noctalia` channel (`https://github.com/noctalia-dev/noctalia`) for `noctalia-git` |
| Chimera | As root: `apk add chimera-repo-user` (if needed), `apk update`, `apk add noctalia` |
| NixOS | See the [Noctalia docs](https://docs.noctalia.dev/noctalia/getting-started/installation/) (the repo has a flake) |
| Alpine | No `noctalia` package in Alpine edge when I checked (2026-10). Build from source (below). Alpine uses musl and OpenRC, and I haven't tried it, so dependency package names may differ. |
| Anything else | Build from source (below) |

**Build Noctalia from source** (needs `just` and `meson`; assets must be installed too, copying only the binary won't work):

```sh
# Arch dependencies (other distros: see the Noctalia install docs)
sudo pacman -S meson gcc just wayland wayland-protocols libglvnd freetype2 fontconfig \
  cairo pango harfbuzz libxkbcommon glib2 libsecret libsodium sdbus-cpp libpipewire \
  wireplumber polkit pam curl libwebp libjxl libsndfile librsvg libqalculate libxml2 \
  md4c tomlplusplus nlohmann-json stb jemalloc

git clone https://github.com/noctalia-dev/noctalia --branch main
cd noctalia
just configure release && just build release && sudo just install release
```

### 3. Other programs the keybinds launch

Install what you want to keep, and edit `binds.conf` for what you don't:

- `kitty` (terminal), `yazi` (file manager in a terminal), `dolphin` (file manager), `steam`
- `helium-browser`, used by the Super+B/R/T/Y/X binds. Replace it with your own browser in `binds.conf`.
- `jq`, needed by the Noctalia `mango_layouts` plugin
- A polkit agent. `config.conf` starts `/usr/lib/polkit-kde-authentication-agent-1`, which is the Arch path. Other distros put it elsewhere (for example `/usr/libexec/`), so fix that `exec_once` line.

### 4. Clone this config

```sh
git clone https://github.com/Coofle420/mango-config ~/.config/mango
```

Then fix the machine-specific bits:

```sh
# config.conf has /home/tree hard-coded in two exec_once lines
sed -i "s|/home/tree|$HOME|g" ~/.config/mango/config.conf
```

- `config.conf` ends with `exec_once=.../wavv-listener-start`. That is my personal push-to-talk helper and isn't in this repo. **Delete that line.**
- Monitor names, sizes and refresh rates in `monitor_rule` are mine (`DP-2`, `HDMI-A-1`). Run `mmsg get all-monitors` or check your outputs and edit them.
- If you use Noctalia's palette sync for Mango, add the user template described below.

Check the config, then start Mango:

```sh
mango -p      # prints nothing when the config is valid
mango         # from a TTY, or pick "mango" in your display manager
```

### Noctalia palette template (optional)

Noctalia 5.2's built-in Mango template still writes the pre-0.18 key names, which breaks the config. I use my own template instead. In `~/.config/noctalia/config.toml`:

```toml
[theme.templates.user.mango]
input_path = "templates/mango.conf"
output_path = "$XDG_CONFIG_HOME/mango/noctalia.conf"
post_hook = "mmsg dispatch reload_config"
```

and remove `"mango"` from `builtin_ids`. Copy `noctalia-template/mango.conf` from this repo to `~/.config/noctalia/templates/mango.conf`. It uses the new names (`root_color`, `border_color`, `focus_color`, ...) with Noctalia's `{{colors.<role>.default.hex_stripped}}` placeholders. If you skip all this, Mango still starts with its default colours.
