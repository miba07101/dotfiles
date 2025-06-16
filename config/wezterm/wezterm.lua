local wezterm = require 'wezterm'
local act = wezterm.action

-- ─────────────────── Tab Title Formatting ───────────────────
-- Extract just the executable name from path
local function basename(path)
  return path:match("([^/\\]+)$") or path
end

wezterm.on('format-tab-title', function(tab, _, _, _, _, max_width)
  local pane = tab.active_pane
  local domain = pane.domain_name or ""

  -- Decide icon: Windows local → PowerShell icon; otherwise Linux icon
  local icon
  if wezterm.target_triple:find("windows") then
    icon = domain == "local" and "" or ""
  else
    icon = ""
  end

  -- Use the actual process that's running (e.g., nvim, bash, pwsh)
  local proc = basename(pane.foreground_process_name or "")
  local title = proc ~= "" and proc or domain

  local text = string.format(" %s   %s ", icon, title)
  return {
    { Text = wezterm.truncate_right(text, max_width) }
  }
end)

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
    cursor_bg = '#c8c093', cursor_fg = '#c8c093', cursor_border = '#c8c093',
    selection_bg='#2d4f67', selection_fg='#dcd7ba',
    ansi={'#1f1f28','#c34043','#76946a','#c0a36e','#7e9cd8','#957fb8','#6a9589','#dcd7ba'},
    brights={'#727169','#e82424','#98bb6c','#e6c384','#7fb4ca','#938aa9','#7aa89f','#fefefa'},
  },
  [light_scheme] = {
    foreground='#1f1f28', background='#fefefa',
    cursor_bg = '#363646', cursor_fg = '#fefefa', cursor_border = '#363646',
    selection_bg='#2d4f67', selection_fg='#fefefa',
    ansi = {'#1f1f28', '#c34043', '#76946a', '#c0a36e', '#7e9cd8', '#957fb8', '#6a9589', '#1f1f28',},
    brights = {'#727169', '#e82424', '#98bb6c', '#e6c384', '#7fb4ca', '#938aa9', '#7aa89f', '#1f1f28',},
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
  -- { key='c', mods='CTRL', action=act.CopyTo 'ClipboardAndPrimarySelection' },
  {
      key = 'c',
      mods = 'CTRL',
      action = wezterm.action_callback(function(window, pane)
        -- Check if there's selected text in the current pane
        local has_selection = window:get_selection_text_for_pane(pane) ~= ''
        if has_selection then
          -- Copy selected text and clear selection
          window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
          window:perform_action(act.ClearSelection, pane)
        else
          -- No selection: send a true Ctrl+C (SIGINT) to the child process
          window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
        end
      end),
    },
  { key='v', mods='CTRL', action=act.PasteFrom 'Clipboard' },
  { key='v', mods='CTRL', action=act.PasteFrom 'PrimarySelection' },
  { key='-', mods='LEADER', action=act.SplitVertical { domain='CurrentPaneDomain' } },
  { key='\\', mods='LEADER', action=act.SplitHorizontal { domain='CurrentPaneDomain' } },
  { key='w', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = false },},
  { key='1', mods='CTRL', action=act.SpawnTab { DomainName='local' } },
  { key='2', mods='CTRL', action=act.SpawnTab { DomainName='Tumbleweed' } },
  { key='x', mods='ALT', action=act.SpawnCommandInNewTab { args = { 'ticker' } } },
  { key='m', mods='CTRL', action=act.EmitEvent('toggle-color-scheme') },
}

return config
