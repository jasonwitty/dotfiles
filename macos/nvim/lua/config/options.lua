-- Options are automatically loaded before lazy.nvim startup.
-- Omarchy's clipboard bridge targets Linux (Wayland, /proc). macOS already
-- shares the system clipboard through pbcopy/pbpaste, inside tmux too.
if vim.fn.has("mac") == 0 then
  require("config.remote_clipboard").setup()
end

vim.opt.relativenumber = false
vim.g.autoformat = false
