local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
	return
end

-- Color table
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
  black     = "#1F1F28",
  white     = "#ffffff",
  grey      = "#54546D",
}

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

-- Config
local config = {
  options = {
    -- Disable sections and component separators
    component_separators = '',
    section_separators = '',
    disabled_filetypes = { "alpha", "dashboard", "neo-tree", "Outline", "Telescope" },
    theme = {
      normal = {
        c = { bg = colors.purple, fg = colors.white }
      },
      insert = {
        c = {bg = colors.blue, fg = colors.white }
      },
      visual = {
        c = { bg = colors.green, fg = colors.white }
      },
      replace = {
        c = { bg = colors.orange, fg = colors.white }
      },
      command = {
        c = { bg = colors.red, fg = colors.white}
      },
      inactive = {
        c = { bg = colors.grey, fg = colors.white }
      }
    },
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

-- Filetype
ins_left { "filetype", icon_only = true, colored = false,
  color = function()
    -- auto change color according to neovims mode
    local mode_color = {
      n = colors.dpurple,
      i = colors.dblue,
      v = colors.dgreen,
      [''] = colors.dgreen,
      V = colors.dgreen,
      c = colors.dred,
      no = colors.dpurple,
      R = colors.dorange,
      Rv = colors.dorange,
      cv = colors.dpurple,
      ce = colors.dpurple,
      ['!'] = colors.dpurple,
      t = colors.dpurple,
    }
    return { bg = mode_color[vim.fn.mode()] }
  end,
  cond = conditions.buffer_not_empty
}

-- Mode
ins_left {
  "mode",
  color = function()
    -- auto change color according to neovims mode
    local mode_color = {
      n = colors.dpurple,
      i = colors.dblue,
      v = colors.dgreen,
      [''] = colors.dgreen,
      V = colors.dgreen,
      c = colors.dred,
      no = colors.dpurple,
      R = colors.dorange,
      Rv = colors.dorange,
      cv = colors.dpurple,
      ce = colors.dpurple,
      ['!'] = colors.dpurple,
      t = colors.dpurple,
    }
    return { bg = mode_color[vim.fn.mode()] }
  end
}

-- Diagnostic
ins_left {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = { error = " ", warn = " ", info = " " },
  colored = false,
  always_visible = false
}

-- Filename
ins_left { "filename", path = 3, cond = ( conditions.buffer_not_empty and conditions.hide_in_width )}
-- ins_left { "filename", path = 3, cond = conditions.hide_in_width }

-- Insert mid section. You can make any number of sections in neovim :)
-- for lualine it's any number greater then 2
ins_left {
  function()
    return "%="
  end,
}

-- Add components to right sections
-- Location
ins_right { "location" }

-- ShiftWidth
ins_right { '(vim.bo.expandtab and "●" or "⇥ ") .. " " .. vim.bo.shiftwidth' }

ins_right {
  -- Lsp server name .
  function()
    local msg = "-"
    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
  end,
  icon = " ",
}

-- Fileformat, Encoding, Filesize, Progress
ins_right { "fileformat", fmt = string.upper, icons_enabled = true, cond = conditions.hide_in_width }
ins_right { "encoding", fmt = string.upper, cond = conditions.hide_in_width }
-- ins_right { "filesize", cond = conditions.buffer_not_empty }
ins_right { "progress" }

-- Git
ins_right { "branch", icon = "" }

ins_right {
  "diff",
  symbols = { added = " ", modified = "柳 ", removed = " " },
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.orange },
    removed = { fg = colors.red },
  },
  cond = conditions.hide_in_width,
}

-- Now don't forget to initialize lualine
lualine.setup(config)
