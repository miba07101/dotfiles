local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
	return
end

-- Custom theme
local vscode_theme = function()
  local colors = {
    red       = "#e74d23",
    dred      = "#a13518",
    orange    = "#FF8800",
    dorange   = "#b25f00",
    yellow    = "#ffc233",
    dyellow   = "#b28723",
    -- green    = "#76946A",
    green     = "#427b00",
    dgreen    = "#2e5600",
    blue      = "#007ACD",
    dblue     = "#00558f",
    purple    = "#67217A",
    dpurple   = "#481755",
    black     = "#16161D",
    -- white     = "#DCD7BA",
    white     = "#FFFFFF",
    grey      = "#727169",
}
return {
  normal = {
    a = {bg = colors.purple, fg = colors.white},
  },
  insert = {
    a = {bg = colors.blue, fg = colors.white},
  },
  visual = {
    a = {bg = colors.green, fg = colors.white},
  },
  replace = {
    a = {bg = colors.orange, fg = colors.white},
  },
  command = {
    a = {bg = colors.red, fg = colors.white},
  },
  inactive = {
    a = {bg = colors.black, fg = colors.grey},
  },
}
end

-- Lsp server name
local lsp_server = function()
  local msg = ""
  -- local icon = ""
  local icon = "力"
  local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
  local clients = vim.lsp.get_active_clients()
  if next(clients) == nil then
    return msg
  end
  for _, client in ipairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
      -- return client.name
      return icon
    end
  end
  return msg
end

-- Python environments plugin - swenv.lua
local function python_venvs()
  local msg = ""
  local venv = require('swenv.api').get_current_venv()
  if venv then
    return string.format(venv.name)
  else
    return msg
  end
end

-- Buffers counting
local function get_buffers()
  -- local icon = "•"
  local icon = "+"
  local file_icon = ""
  local buffer_count = 0
  local unsaved_buffers = 0
  for _, bufnr in pairs(vim.fn.getbufinfo({bufloaded = true})) do
    if bufnr.name ~= "" then
      buffer_count = buffer_count + 1
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buf, 'modified') then
      unsaved_buffers = unsaved_buffers + 1
    end
  end
  local result = string.format('%s [%d:%d%s]', file_icon, buffer_count, unsaved_buffers, icon)
  return result
end

-- Show macro recording status
local function show_macro_recording()
    local recording_register = vim.fn.reg_recording()
    if recording_register == "" then
        return ""
    else
        return "壘" .. recording_register
    end
end

-- Conditions
local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 90
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

-- Lualine setup
lualine.setup({
  options = {
    section_separators = '',
    component_separators = '',
    disabled_filetypes = {
      statusline = { "alpha", "TelescopePrompt" },
      winbar = {},
    },
    theme = vscode_theme(),
  },
  sections = {
    lualine_a = {
      { "filetype", colored = false, icon_only = true },
      -- { "filename", path = 4, symbols = { modified = "[•]", readonly = "[-]"} },
      { "filename", path = 4, symbols = { modified = "[+]", readonly = "[-]"} },
      { get_buffers },
    },
    lualine_b = {
      {
                "macro-recording",
                fmt = show_macro_recording,
            },
    },
    lualine_c = {
      -- { "branch", icon = "" },
      -- { "diff",
      --   colored = false,
      --   symbols = { added = " ", modified = " ", removed = " " },
      --   -- symbols = { added = " ", modified = "柳 ", removed = " " },
      --   -- cond = conditions.hide_in_width,
      -- },
    },
    lualine_x = {},
    lualine_y = {
      { python_venvs, icon = "" }
    },
    lualine_z = {
      { lsp_server },
      { "diagnostics",
        colored = false,
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
      },
      { "location" },
      { "progress" },
    },
  },
  tabline = {
    lualine_b = {
      {"buffers",
        buffers_color = {
          active = {bg = "#1F1F28", fg = "#DCD7BA"},
          inactive = {bg = "#1F1F28", fg = "#727169"},
        },
        filetype_names = {
          alpha = '',
          TelescopePrompt = '',
          lazy = '',
          fzf = '',
        },
      }
    },
  }

})

-- in-built refresh function to force an update when I enter or exit recording a macro
vim.api.nvim_create_autocmd("RecordingEnter", {
    callback = function()
        lualine.refresh({
            place = { "statusline" },
        })
    end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = function()
        -- This is going to seem really weird!
        -- Instead of just calling refresh we need to wait a moment because of the nature of
        -- `vim.fn.reg_recording`. If we tell lualine to refresh right now it actually will
        -- still show a recording occuring because `vim.fn.reg_recording` hasn't emptied yet.
        -- So what we need to do is wait a tiny amount of time (in this instance 50 ms) to
        -- ensure `vim.fn.reg_recording` is purged before asking lualine to refresh.
        local timer = vim.loop.new_timer()
        timer:start(
            50,
            0,
            vim.schedule_wrap(function()
                lualine.refresh({
                    place = { "statusline" },
                })
            end)
        )
    end,
})
