-- Active theme. Omarchy symlinks this file to the current desktop theme's
-- neovim.lua; here it is fixed to Catppuccin Frappe to match Ghostty and tmux.
-- To switch, change the flavour (or plugin) below; every Omarchy theme plugin
-- is already installed by all-themes.lua.
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "frappe",
			transparent_background = true,
			float = {
				transparent = true,
			},
		},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin-frappe",
		},
	},
}
