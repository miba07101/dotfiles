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
  config.color_scheme = 'nord'
else
  -- colorscheme
  -- config.color_scheme = 'iceberg-light'
  -- config.color_scheme = 'Kanagawa (Gogh)'
  config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
  -- config.color_scheme = is_night()
end

-- fonts
config.font = wezterm.font 'Hack Nerd Font'
-- config.font = wezterm.font 'CaskaydiaCove Nerd Font'
config.font_size = 11.0
config.warn_about_missing_glyphs=false
config.line_height = 1.1

-- sounds
config.audible_bell="Disabled"

-- appearance
config.enable_wayland = false
config.window_decorations = "TITLE | RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'
config.initial_rows = 32
config.initial_cols = 96
config.window_padding = {
  -- left = 0,
  -- right = 0,
  -- top = 0,
  bottom = 0,
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
