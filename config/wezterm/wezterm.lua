-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Check if on windows
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
end

-- color scheme:
-- config.color_scheme = 'iceberg-light'
-- config.color_scheme = 'nord'
config.color_scheme = 'Kanagawa (Gogh)'
config.force_reverse_video_cursor = true

-- fonts
config.font = wezterm.font 'Hack Nerd Font'
config.font_size = 11.0
config.warn_about_missing_glyphs=false
config.line_height = 1.1

-- sounds
config.audible_bell="Disabled"

-- appearance
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'
config.initial_rows = 32
config.initial_cols = 96
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- keybidings
config.keys = {
  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
  },
  {
    key = 'v',
    mods = 'CTRL',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  {
    key = 'v',
    mods = 'CTRL',
    action = wezterm.action.PasteFrom 'PrimarySelection',
  },
}
-- and finally, return the configuration to wezterm
return config
