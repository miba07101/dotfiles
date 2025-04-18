-- pull in the wezterm API
local wezterm = require 'wezterm'

-- function to get light/dark theme according os theme
function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    -- custom kanagawa in folder colors
    return "kanagawa-dark"
  else
    -- custom kanagawa in folder colors
    return "kanagawa-light"
  end
end

function is_night()
  if tonumber(os.date("%H")) >= 19 then
    return "kanagawa-dark"
  else
    return "kanagawa-light"
  end
end

-- this will hold the configuration.
local config = wezterm.config_builder()

-- check if on windows
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
  -- config.default_prog = { 'pwsh' }
  config.color_scheme = "kanagawa-dark"
  config.font = wezterm.font { family = 'Hack Nerd Font', weight = 'Regular' }
  config.font_size = 11
  config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
  -- config.hide_tab_bar_if_only_one_tab = true
else
  -- config.color_scheme = 'nord'
  -- config.color_scheme = 'iceberg-light'
  -- config.color_scheme = 'Kanagawa (Gogh)'
  -- config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
  -- config.color_scheme = is_night()
  config.enable_wayland = false
  config.color_scheme = "kanagawa-dark"
--   config.font = wezterm.font { family = 'Hack Nerd Font', weight = 'Regular' }
  config.font = wezterm.font_with_fallback {
    { family = 'UbuntuSansMono Nerd Font', weight = 'Regular' },
    { family = 'Hack Nerd Font', weight = 'Regular' },
  }
  config.font_size = 14
  -- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
  config.hide_tab_bar_if_only_one_tab = true
end

-- fonts settings
-- config.font_size = 11.2 -- je tam .2 kvoli lepsiemu renderovaniu
-- config.font_size = 11
config.warn_about_missing_glyphs=false
config.line_height = 1.0
-- config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- sounds
config.audible_bell="Disabled"

-- appearance
-- config.max_fps = 144
-- config.animation_fps = 1
config.window_close_confirmation = 'NeverPrompt'
config.initial_rows = 32
config.initial_cols = 96
config.window_padding = {
  left = "1cell",
  right = "1cell",
  top = "0.5cell",
  bottom = "0cell",
}

-- cursor
config.force_reverse_video_cursor = true
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- keybidings
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  { key = 'q', mods = 'LEADER|CTRL', action = wezterm.action.QuitApplication },
  { key = 'c', mods = 'CTRL', action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection', },
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard', },
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'PrimarySelection', },
}

-- and finally, return the configuration to wezterm
return config
