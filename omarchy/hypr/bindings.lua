-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- ---------------------------------------------------------------------------
-- Restored from old ML4W config (jasonwitty/dotfiles hypr/conf/keybindings/default.conf)
-- These keys were free in Omarchy, so they're added alongside the defaults.
-- ---------------------------------------------------------------------------
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + ALT + T", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")
o.bind("SUPER + SHIFT + R", "Reload Hyprland config", "hyprctl reload")
o.bind("SUPER + ALT + A", "Extract text (OCR) from screenshot", "omarchy-capture-text")
o.bind("SUPER + SHIFT + H", "Toggle nightlight", "omarchy-toggle-nightlight")
o.bind("CTRL + ALT + T", "Theme menu", { menu = "theme" })

-- Next empty workspace on the focused monitor (per-monitor workspaces 1-10).
o.bind("SUPER + CTRL + DOWN", "Open next empty workspace", function()
  local monitor = hl.get_active_monitor()
  if not monitor then return end
  for slot = 1, 10 do
    local ws = hl.get_workspace(o.workspaces.workspace_id(monitor, slot))
    if not ws or (ws.windows or 0) == 0 then
      o.workspaces.focus(slot)()
      return
    end
  end
end)

-- Display zoom: SUPER+SHIFT+scroll, SUPER+SHIFT+Z resets.
o.bind("SUPER + SHIFT + mouse_down", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 0.5 } })
end)
o.bind("SUPER + SHIFT + mouse_up", "Zoom out", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = math.max(1, zoom - 0.5) } })
end)
o.bind("SUPER + SHIFT + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)

-- ---------------------------------------------------------------------------
-- Conflicts resolved in favor of old ML4W muscle memory (2026-11-07).
-- Displaced Omarchy defaults are relocated, never dropped.
-- ---------------------------------------------------------------------------

-- Arrows: SHIFT = resize, ALT = swap (old). Move-into-group -> SUPER+CTRL+ALT+arrows.
o.rebind("SUPER + SHIFT + LEFT", "Shrink window width", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.rebind("SUPER + SHIFT + RIGHT", "Grow window width", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
o.rebind("SUPER + SHIFT + UP", "Shrink window height", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
o.rebind("SUPER + SHIFT + DOWN", "Grow window height", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
o.rebind("SUPER + ALT + LEFT", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.rebind("SUPER + ALT + RIGHT", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.rebind("SUPER + ALT + UP", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.rebind("SUPER + ALT + DOWN", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + CTRL + ALT + LEFT", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + CTRL + ALT + RIGHT", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))
o.bind("SUPER + CTRL + ALT + UP", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.bind("SUPER + CTRL + ALT + DOWN", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))

-- SUPER+M = maximize (old). Minimize to dock -> SUPER+ALT+M.
o.rebind("SUPER + M", "Maximize window", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + ALT + M", "Minimize window to the dock", "omarchy-hyprland-window-minimize")

-- SUPER+K = swap split, SUPER+CTRL+K = cheat sheet (old). Herdr cheat sheet -> SUPER+CTRL+ALT+K.
o.rebind("SUPER + K", "Swap split", hl.dsp.layout("swapsplit"))
o.rebind("SUPER + CTRL + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + CTRL + ALT + K", "Herdr keybindings", "omarchy-menu-herdr-keybindings")

-- SUPER+SHIFT+RETURN and SUPER+CTRL+RETURN = app launcher (old). Herdr -> SUPER+CTRL+ALT+RETURN.
o.rebind("SUPER + SHIFT + RETURN", "Apps", "omarchy-shell omarchy.dock apps")
o.rebind("SUPER + CTRL + RETURN", "Apps", "omarchy-shell omarchy.dock apps")
o.bind("SUPER + CTRL + ALT + RETURN", "Herdr", { omarchy = "terminal-herdr" })

-- Screenshots (old). Color picker -> SUPER+SHIFT+PRINT, send to scratchpad -> SUPER+CTRL+ALT+S.
o.rebind("SUPER + PRINT", "Screenshot", "omarchy-capture-screenshot")
o.bind("SUPER + SHIFT + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a")
o.rebind("SUPER + ALT + F", "Screenshot full screen (instant)", "omarchy-capture-screenshot fullscreen")
o.rebind("SUPER + ALT + S", "Screenshot area", "omarchy-capture-screenshot region")
o.bind("SUPER + CTRL + ALT + S", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Game mode / animations (old SUPER+ALT+G and SUPER+SHIFT+A).
-- Ungroup -> SUPER+CTRL+ALT+G, ChatGPT -> SUPER+CTRL+ALT+A.
o.rebind("SUPER + ALT + G", "Toggle game mode (animations, blur, shadows)", "omarchy-toggle-animations")
o.rebind("SUPER + SHIFT + A", "Toggle animations", "omarchy-toggle-animations")
o.bind("SUPER + CTRL + ALT + G", "Move active window out of group", hl.dsp.window.move({ out_of_group = true }))
o.bind("SUPER + CTRL + ALT + A", "ChatGPT", { webapp = "https://chatgpt.com" })

-- Old bindings placed on free keys, since Omarchy kept the originals.
o.bind("SUPER + SHIFT + ALT + Q", "Kill all instances of active app", "hyprctl activewindow -j | jq -r .pid | xargs -r kill")
o.bind("SUPER + ALT + B", "Restart Omarchy shell (bar)", "omarchy-restart-shell")

-- Float all windows on the workspace; if all already float, tile them all.
o.bind("SUPER + SHIFT + ALT + T", "Toggle floating for all windows", function()
  local ws = hl.get_active_workspace()
  if not ws then return end
  local windows = {}
  local any_tiled = false
  for _, window in ipairs(hl.get_windows()) do
    if window.workspace and window.workspace.id == ws.id then
      windows[#windows + 1] = window
      if not window.floating then any_tiled = true end
    end
  end
  for _, window in ipairs(windows) do
    hl.dispatch(hl.dsp.window.float({ action = any_tiled and "on" or "off", window = window }))
  end
end)

-- Next wallpaper (old SUPER+SHIFT+W, which Omarchy keeps for Omawrite).
o.bind("SUPER + SHIFT + ALT + W", "Next wallpaper", "omarchy-theme-bg-next")
-- Calendar on an easier key (old SUPER+CTRL+C, which Omarchy keeps for Capture menu).
o.bind("SUPER + ALT + C", "Calendar", { panel = "omarchy.clock" })

-- SUPER+CTRL+1-0 = move all windows on this workspace to workspace N (old).
-- Bar panels -> SUPER+CTRL+ALT+1-9.
for slot = 1, 10 do
  local key = "code:" .. tostring(slot + 9)
  o.rebind("SUPER + CTRL + " .. key, "Move all windows to workspace " .. slot, function()
    local monitor = hl.get_active_monitor()
    local ws = hl.get_active_workspace()
    if not monitor or not ws then return end
    local target = tostring(o.workspaces.workspace_id(monitor, slot))
    for _, window in ipairs(hl.get_windows()) do
      if window.workspace and window.workspace.id == ws.id then
        hl.dispatch(hl.dsp.window.move({ workspace = target, follow = false, window = "address:" .. window.address }))
      end
    end
    o.workspaces.focus(slot)()
  end)
  if slot <= 9 then
    o.bind("SUPER + CTRL + ALT + " .. key, "Bar panel " .. slot, "omarchy-shell -q shell togglePanelAt right " .. slot)
  end
end

-- COSMIC-style vertical workspace scrolling: SUPER+UP/DOWN step through this
-- monitor's own workspaces 1-10. Down stops one past the last workspace with
-- windows, so there's always exactly one empty workspace "below".
-- (Replaces Omarchy's focus-window-up/down; ALT+TAB still cycles windows.)
local function workspace_step(delta)
  return function()
    local monitor = hl.get_active_monitor()
    if not monitor then return end
    local base = o.workspaces.workspace_id(monitor, 1) - 1
    local active = monitor.active_workspace
    local slot = (active and active.id > base and active.id <= base + 10) and (active.id - base) or 1

    local last_used = 0
    for s = 1, 10 do
      local ws = hl.get_workspace(base + s)
      if ws and (ws.windows or 0) > 0 then last_used = s end
    end

    local target = slot + delta
    if target < 1 then return end
    if target > math.min(10, math.max(last_used, slot) + 1) then return end
    o.workspaces.focus(target)()
  end
end
o.rebind("SUPER + UP", "Previous workspace on this monitor", workspace_step(-1))
o.rebind("SUPER + DOWN", "Next workspace on this monitor", workspace_step(1))
