# Dotfiles (Artix -> Void backup)

My whole rice: Mango (WM), Noctalia (shell/bar), kitty, Neovim, yazi, starship, fastfetch, btop, and the
**DarkPurple** colour scheme (`.config/noctalia/palettes/DarkPurple.json`).

| Path | What |
|---|---|
| `.config/mango/` | Mango 0.18 config (also in Coofle420/mango-config) |
| `.config/noctalia/` | Noctalia config, `palettes/DarkPurple.json`, `templates/` |
| `.config/{kitty,nvim,yazi,btop,fastfetch,starship.toml,...}` | Terminal and app themes |
| `.config/{gtk-3.0,gtk-4.0,qt5ct,qt6ct,kdeglobals,...}` | GTK/Qt/KDE theme settings |
| `.local/bin/` | Personal scripts |
| `.local/share/applications/` | Launchers (Discord wrapper, etc.) |
| `.local/state/noctalia/settings.toml` | Noctalia saved state |
| `rice/` | Setup scripts from the Artix install (system-specific, for reference) |
| `packages/` | Package lists from Artix (names differ on Void) |

Not included: logins and app data (Discord, Helium, Cider, Signal), secrets and keys, wallpapers
(see Coofle420/wallpapers), and system files such as `/etc` and GRUB.

Restore: copy the folders into `$HOME`, then replace `/home/tree` with your home directory in `.config/mango/config.conf`.
