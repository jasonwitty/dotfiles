# Omarchy setup

My config for [Omarchy](https://omarchy.org/) (Hyprland, Lua config). It lives
apart from the older ML4W/Hyprland config in `../hypr` and `../fish`, which is
left as it was.

## Layout

| Path | Install to | What it is |
|---|---|---|
| `hypr/bindings.lua` | `~/.config/hypr/bindings.lua` | My old ML4W keybindings, ported to Omarchy. Every Omarchy default they displaced is moved to a free key, not dropped. |
| `hypr/monitors.lua` | `~/.config/hypr/monitors.lua` | Dual ASUS 1440p at 144Hz. VG27A is primary (left), VG27B is on the right. Matched by serial, so swapping cables doesn't flip them. |
| `fish/` | `~/.config/fish/` | Fish config from `../fish`, adjusted for Omarchy (see below). |
| `themes/frappe/` | `~/.config/omarchy/themes/frappe/` | Catppuccin Frappé theme with an animated intro. |
| `tools/render_frappe_intro.py` | — | Renders the Frappé intro clip. |

The Starship config is unchanged, so use `../starship.toml`.

## Fish changes compared with `../fish`

- `upd` runs `omarchy update` instead of `garuda-update`.
- `grubup` runs `sudo limine-update`, because Omarchy boots with Limine.
- Removed the duplicate starship init that pointed at `/usr/local/bin/starship`.
- Added a blank line after `pfetch`.
- `conf.d/done.fish` reads the focused window's PID from `hyprctl activewindow -j`.
  Parsing line 13 of the plain-text output broke on newer Hyprland.

Packages this config expects: `fish starship zoxide eza bat ugrep expac wget hwinfo reflector meld`,
plus `atuin` and `pfetch` (installed per-user here). For `pi-vnc`: `lsof gamescope tigervnc`.

Make fish the login shell with `chsh -s /usr/bin/fish`.

## Frappé theme

```bash
cp -r themes/frappe ~/.config/omarchy/themes/
omarchy theme set frappe
```

- Uses the Catppuccin Frappé palette with lavender accents.
- Window styling comes from the old ML4W setup:
  - Rounding 10, 2px borders: text color on the focused window, blue on the others.
  - Gaps: 10 between windows, 20 at the screen edges.
  - Unfocused windows at 90% opacity, with blur and shadow.
- `shell.toml` gives the bar a translucent Frappé background and lavender popups and menus.
- The wallpaper is *symmetry-in-the-stillness* from
  [mylinuxforwork/wallpaper](https://github.com/mylinuxforwork/wallpaper).
- `backgrounds/intros/*.mp4` plays when you switch to the theme and at login:
  1. A gust comes in from the left: the tree sways and leaves blow off.
  2. Wind ripples cross the lake, and leaves land on it with ring ripples.
  3. The grass in the bottom-right sways.
  4. The clip settles exactly onto the still image.

To re-render the intro (needs `uv` and `ffmpeg`):

```bash
ffmpeg -i wallpaper.jpg -vf scale=2560:1440:flags=area base2560.png
uv run --with numpy --with opencv-python-headless python tools/render_frappe_intro.py base2560.png out.mp4
# preview single frames instead:
uv run --with numpy --with opencv-python-headless python tools/render_frappe_intro.py base2560.png x --frames 60,90 --outdir frames
```

### Brave (Origin) theming

Omarchy writes the theme color into a browser policy file, but only when the
policy directory already exists. Create it once:

```bash
sudo install -d -m 0755 /etc/brave/policies/managed
omarchy-theme-set-browser
```
