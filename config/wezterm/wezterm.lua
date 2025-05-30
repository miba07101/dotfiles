-- pull in the wezterm API
local wezterm = require 'wezterm'

-- customize tab titles with icons and domain names
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local domain = tab.active_pane.domain_name or ''
  local icon = ''
  local display_name = domain

  if domain == 'local' then
    icon = ''
    display_name = 'PowerShell'
  elseif domain:find('Tumbleweed') then
    icon = ''
  else
    icon = ''
  end

  return {
    { Text = string.format(' %s    %s ', icon, display_name) },
  }
end)


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

config.color_schemes = {
  ["kanagawa-dark"] = {
    foreground = "#dcd7ba",
    background = "#1f1f28",
    cursor_bg = "#c8c093",
    cursor_border = "#c8c093",
    cursor_fg = "#1f1f28",
    selection_bg = "#2d4f67",
    selection_fg = "#c8c093",
    ansi = {"#090618", "#c34043", "#76946a", "#c0a36e", "#7e9cd8", "#957fb8", "#6a9589", "#c8c093"},
    brights = {"#727169", "#e82424", "#98bb6c", "#e6c384", "#7fb4ca", "#938aa9", "#7aa89f", "#dcd7ba"},
  },
  ["kanagawa-light"] = {
    foreground = "#6B7089",
    background = "#F2ECBC",
    cursor_bg = "#6B7089",
    cursor_border = "#6B7089",
    cursor_fg = "#F2ECBC",
    selection_bg = "#DCD7BA",
    selection_fg = "#1F1F28",
    ansi = {"#1F1F28", "#C34043", "#76946A", "#C0A36E", "#7E9CD8", "#957FB8", "#6A9589", "#DCD7BA"},
    brights = {"#727169", "#E82424", "#98BB6C", "#E6C384", "#7FB4CA", "#938AA9", "#7AA89F", "#DCD7BA"},
  },
}

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

-- local scheme = wezterm.color.load_scheme('C:/Users/vimi/.config/wezterm/colors/kanagawa-dark.toml')
local scheme = config.color_schemes["kanagawa-dark"]
config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = scheme.background,
      fg_color = scheme.foreground,
    },
  },
}

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

config.wsl_domains = {
  {
    name = "Tumbleweed",
    distribution = "openSUSE-Tumbleweed",
  },
}

-- keybidings
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- { key = 'q', mods = 'LEADER', action = wezterm.action.QuitApplication },
  { key = 'c',  mods = 'CTRL',   action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection', },
  { key = 'v',  mods = 'CTRL',   action = wezterm.action.PasteFrom 'Clipboard',                 },
  { key = 'v',  mods = 'CTRL',   action = wezterm.action.PasteFrom 'PrimarySelection',          },
  { key = '-',  mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }},
  { key = '\\', mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }},
  { key = '1',  mods = 'CTRL', action = wezterm.action.SpawnTab { DomainName = 'local' }},
  { key = '2',  mods = 'CTRL', action = wezterm.action.SpawnTab { DomainName = 'Tumbleweed' }},
  { key = 'x',  mods = 'ALT', action = wezterm.action.SpawnCommandInNewTab { args = {'ticker'} }},
}

-- and finally, return the configuration to wezterm
return config
