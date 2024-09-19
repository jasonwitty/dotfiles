![image](Screenshot_20240804_154227.png) – 


# prerequisites

FiraCode Nerd Font Mono

```
yay -S ttf-firacode-nerd
```

Starship

```
curl -sS https://starship.rs/install.sh | sh
```

Alacritty

```
pacman -S alacritty
```

Alacritty Themes

```
yay -S alacritty-themes
```

Fish Shell

```
pacman -S fish
```

Pfetch-rs (requires rustup - https://rustup.rs/)

```
cargo install pfetch
```

eza zoxide and fzf

```
pacman -S eza zoxide fzf
```

## notes for fedora

install prereq

```
sudo dnf install fira-code-fonts
sudo dnf install eza zoxide fzf fish
```

modify .config/alacritty/alacritty.toml and change fonts to Firacode (remove Nerd Mono)

## notes for debian

```
sudo nala install fonts-firacode fish zoxide fzf ugrep 

cargo install --locked bat
cargo install pfetch-rs
cargo install eza

```

## notes for MACOS

```
brew install wezterm
brew install ugrep
brew install starship
brew install --cask alacritty --no-quarantine
brew install --cask font-hack-nerd-font
brew install bat

cat ~/.wezterm.lua
File: /Users/jasonwitty/.wezterm.lua
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Dracula'

config.window_background_opacity = 0.7

config.font = wezterm.font 'FiraCode Nerd Font Mono'

-- and finally, return the configuration to wezterm
return config

```
