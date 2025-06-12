local wezterm = require 'wezterm'
local act = wezterm.action

-- ─────────────────── Tab Title Formatting ───────────────────
local function format_tab(tab, _, _, _, _, max_width)
  local domain = tab.active_pane.domain_name or ''
  local icon = ({
    ["local"] = '',
    ["Tumbleweed"] = '',
  })[domain] or ''
  local name = (domain == 'local' and 'PowerShell') or domain

  return {
    { Text = wezterm.truncate_right(
        (' %s    %s '):format(icon, name),
        max_width
      )
    }
  }
end

wezterm.on('format-tab-title', format_tab)

-- ─────────────────── Color Schemes & Toggle ───────────────────
local dark_scheme  = 'kanagawa-dark'
local light_scheme = 'kanagawa-light'

wezterm.on('toggle-color-scheme', function(window, _pane)
  local o = window:get_config_overrides() or {}
  o.color_scheme = (o.color_scheme == light_scheme)
    and dark_scheme or light_scheme
  window:set_config_overrides(o)
end)

-- ─────────────────── Configuration Builder ───────────────────
local config = wezterm.config_builder()

-- Define your schemes inline
config.color_schemes = {
  [dark_scheme] = {
    foreground='#dcd7ba', background='#1f1f28',
    cursor_bg='#c8c093', cursor_fg='#1f1f28',
    selection_bg='#2d4f67', selection_fg='#c8c093',
    ansi={'#090618','#c34043','#76946a','#c0a36e','#7e9cd8','#957fb8','#6a9589','#c8c093'},
    brights={'#727169','#e82424','#98bb6c','#e6c384','#7fb4ca','#938aa9','#7aa89f','#dcd7ba'},
  },
  [light_scheme] = {
    foreground='#6B7089', background='#F2ECBC',
    cursor_bg='#6B7089', cursor_fg='#F2ECBC',
    selection_bg='#DCD7BA', selection_fg='#1F1F28',
    ansi={'#1F1F28','#C34043','#76946A','#C0A36E','#7E9CD8','#957FB8','#6A9589','#DCD7BA'},
    brights={'#727169','#E82424','#98BB6C','#E6C384','#7FB4CA','#938AA9','#7AA89F','#DCD7BA'},
  },
}

config.color_scheme = dark_scheme
config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = config.color_schemes[dark_scheme].background,
      fg_color = config.color_schemes[dark_scheme].foreground,
    },
  },
}

-- ─────────────────── Platform-Specific Settings ───────────────────
if wezterm.target_triple:find 'windows' then
  config.default_prog = { 'pwsh.exe', '-NoLogo' }
  config.font = wezterm.font('Hack Nerd Font', {weight='Regular'})
  config.font_size = 11
  config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
else
  config.enable_wayland = false
  config.font = wezterm.font_with_fallback {
    { family = 'UbuntuSansMono Nerd Font', weight = 'Regular' },
    { family = 'Hack Nerd Font', weight = 'Regular' },
  }
  config.font_size = 14
  config.hide_tab_bar_if_only_one_tab = true
end

-- ─────────────────── UI / Behavior Tweaks ───────────────────
config.warn_about_missing_glyphs = false
config.line_height = 1.0
config.audible_bell = 'Disabled'
config.window_close_confirmation = 'NeverPrompt'
config.initial_rows, config.initial_cols = 32, 110
config.window_padding = { left='1cell', right='1cell', top='0.5cell', bottom='0cell' }
config.force_reverse_video_cursor = true
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- ─────────────────── WSL Domains ───────────────────
config.wsl_domains = {
  { name = 'Tumbleweed', distribution = 'openSUSE-Tumbleweed' },
}

-- ─────────────────── Keybindings ───────────────────
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  { key='c', mods='CTRL', action=act.CopyTo 'ClipboardAndPrimarySelection' },
  { key='v', mods='CTRL', action=act.PasteFrom 'Clipboard' },
  { key='v', mods='CTRL', action=act.PasteFrom 'PrimarySelection' },
  { key='-', mods='LEADER', action=act.SplitVertical { domain='CurrentPaneDomain' } },
  { key='\\', mods='LEADER', action=act.SplitHorizontal { domain='CurrentPaneDomain' } },
  { key='1', mods='CTRL', action=act.SpawnTab { DomainName='local' } },
  { key='2', mods='CTRL', action=act.SpawnTab { DomainName='Tumbleweed' } },
  { key='x', mods='ALT', action=act.SpawnCommandInNewTab { args = { 'ticker' } } },
  { key='m', mods='CTRL', action=act.EmitEvent('toggle-color-scheme') },
}

return config
