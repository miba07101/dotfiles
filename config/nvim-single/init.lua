--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--

-- {{{ [[ OPTIONS ]]
local opt = vim.opt
local g   = vim.g

-- File
-- opt.backup           = false -- create a backup file
opt.clipboard        = "unnamedplus" -- system clipboard
-- opt.hidden           = true -- switching from unsaved buffers
opt.iskeyword:remove("_") -- oddeli slova pri mazani, nebude brat ako jedno slovo
-- opt.scrolloff        = 5 -- how many lines are displayed on the upper and lower sides of the cursor
-- opt.showmode         = true -- display the current vim mode (no need)
-- opt.sidescrolloff    = 8 -- number of columns to keep at the sides of the cursor
-- opt.splitbelow       = true -- splitting window below
-- opt.splitright       = true -- splitting window right
opt.timeoutlen       = 400 -- time to wait for a mapped sequence to complete, default 1000
opt.updatetime       = 100 -- speed up response time
-- opt.wrap = false -- disable wrapping of lines longer than the width of window
-- opt.writebackup      = false -- create backups when writing files

-- Fold
opt.foldmethod = "marker" -- folding method

-- UI
opt.cmdheight        = 0 -- command line height
-- opt.cursorline       = true -- highlight the current line
-- opt.laststatus       = 3 -- global status bar (sposobuje nefunkcnost resource lua.init)
-- opt.number           = true -- absolute line numbers
-- opt.list             = true -- show some invisible characters (tabs...
-- opt.listchars        = { eol = "¬", tab = "› ", trail = "·", nbsp = "␣" } -- list characters

-- }}}

-- {{{ [[ KEYMAPS ]]

-- Wrapper for mapping custom keybindings
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Leader Key
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Save, Quit
map({ "n", "v", "i", "x" }, "<C-s>", "<cmd>w<cr>", { desc = "Save" })
map({ "n", "v", "i", "x" }, "<C-w>", "<cmd>wq<cr>", { desc = "Save-Quit" })
map({ "n", "v", "i", "x" }, "<C-q>", "<cmd>q!<cr>", { desc = "Quit" })
-- map("n", "<leader>x", "<cmd>w<cr><cmd>luafile %<cr><esc>", { desc = "Reload Lua" })

-- Windows
map("n", "<leader>wv", "<C-w>v", { desc = "Vertical" })
map("n", "<leader>wh", "<C-w>s", { desc = "Horizontal" })
map("n", "<leader>we", "<C-W>=", { desc = "Equal" })
map("n", "<leader>wx", "<cmd>close<cr>", { desc = "Close" })
map("n", "<leader>wlh", "<cmd>windo wincmd K<cr>", { desc = "Layout horizontal " })
map("n", "<leader>wlv", "<cmd>windo wincmd H<cr>", { desc = "Layout vertical " })

map("n", "<C-Up>", "<C-w>k", { desc = "Go Up" })
map("n", "<C-Down>", "<C-w>j", { desc = "Go Down" })
map("n", "<C-Left>", "<C-w>h", { desc = "Go Left" })
map("n", "<C-Right>", "<C-w>l", { desc = "Go Right" })
map("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "Resize Up" })
map("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "Resize Down" })
map("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Resize Left" })
map("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize Right" })

-- Buffers
map("n", "<A-Right>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<A-Left>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<A-UP>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })
map("n", "<A-Down>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })

-- Move in insert mode
map("i", "<C-h>", "<Left>", { desc = "Go Left" })
map("i", "<C-j>", "<Down>", { desc = "Go Down" })
map("i", "<C-k>", "<Up>", { desc = "Go Up" })
map("i", "<C-l>", "<Right>", { desc = "Go Right" })

-- Indenting
map("v", "<", "<gv", { desc = "Unindent line" })
map("v", ">", ">gv", { desc = "Indent line" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move text down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move text up" })
map("v", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text up" })
map("v", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text down" })
map("x", "<A-j>", "<cmd>move '>+1<cr>gv-gv", { desc = "Move text up" })
map("x", "<A-k>", "<cmd>move '<-2<cr>gv-gv", { desc = "Move text down" })

-- Better Paste
map("v", "p", '"_dP', { desc = "Paste no yank" })
map("n", "x", '"_x', { desc = "Delete character no yank" })

-- Vertical move and center
map("n", "<C-d>", "<C-d>zz", { desc = "Up and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Down and center" })

-- Close floating window, notification and clear search with ESC
local function close_floating_and_clear_search()
  -- Close floating windows
  for _, win in pairs(vim.api.nvim_list_wins()) do
    local win_config = vim.api.nvim_win_get_config(win)
    if win_config.relative ~= "" then
      vim.api.nvim_win_close(win, false)
    end
  end

  -- Dismiss nvim-notify notifications
  -- require("notify").dismiss({ silent = true, pending = true })

  -- Clear search highlights
  vim.cmd("nohlsearch")
end

map("n", "<Esc>", close_floating_and_clear_search, { desc = "Close floating windows, dismiss notifications, and clear search" })

-- Mix
map("n", "<BS>", "X", { desc = "TAB as X in normal mode" })
map("n", "<A-a>", "<esc>ggVG<cr>", { desc = "Select all text" })
map("n", "<A-v>", "<C-q>", { desc = "Visual block mode" })
map("n", "<A-+>", "<C-a>", { desc = "Increment number" })
map("n", "<A-->", "<C-x>", { desc = "Decrement number" })
-- map("n", "<leader>rw", ":%s/<c-r><c-w>//g<left><left>", { desc = "replace word" })
-- map("n", "<leader>r", "*``cgn", { desc = "replace word under cursor" })
-- }}}

-- {{{ [[ LAZY MANAGER ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"-- {{{
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  vim.opt.rtp:prepend(lazypath)-- }}}

  require("lazy").setup({

    performance = {-- {{{
      rtp = {
        -- disable some rtp plugins
        disabled_plugins = {
          "gzip",
          "matchit",
          "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },-- }}}

    spec = {-- {{{

      { "rebelot/kanagawa.nvim",-- {{{
        -- enabled = false,
        priority = 1000,
        config = function()
          vim.cmd.colorscheme("kanagawa")
        end,
      },-- }}}

      -- {{{ [ Mini.nvim collection ]
      { "echasnovski/mini.nvim",
      event = "VeryLazy",
      enabled = true,
      config = function()

        require("mini.basics").setup({-- {{{
          options = {
            basic = true,
            extra_ui = true,
            win_borders = "solid",
          },
          mappings = {
            basic = false,
            option_toggle_prefix = [[\]],
            windows = false,
            move_with_alt = false,
          },
          autocommands = {
            basic = true,
            relnum_in_visual_mode = false,
          },
        })-- }}}

        require('mini.extra').setup()

        require('mini.icons').setup()

        require('mini.ai').setup({-- {{{
          n_lines = 500,
          custom_textobjects = {
            -- Brackets and quotes
            ['('] = { '%b()', '^.().*().$' },
            ['['] = { '%b[]', '^.().*().$' },
            ['{'] = { '%b{}', '^.().*().$' },
            ['"'] = { '%b""', '^.().*().$' },
            ["'"] = { "%b''", '^.().*().$' },
            ['`'] = { '%b``', '^.().*().$' },

            -- Common programming patterns
            -- o = { -- Around function calls
              --   { '%b()', '^.-%s*().*()$' },
              -- },
              -- f = { -- Around function definitions
                --   { '^%s*function%s*[^%s(]+%s*%b()%s*{',         '}' },
                --   { '^%s*local%s+function%s*[^%s(]+%s*%b()%s*{', '}' },
                --   { '^%s*[^%s(]+%s*=%s*function%s*%b()%s*{',     '}' }, -- For variable functions
                -- },
                -- c = {                                                   -- Around class/module definitions
                  --   { '^%s*class%s+[^%s{]+%s*{',  '}' },
                  --   { '^%s*module%s+[^%s{]+%s*{', '}' },
                  -- },
                  -- m = { -- Around methods
                    --   { '^%s*[^%s(]+%s*%b()%s*{', '}' },
                    -- },
                    b = require("mini.ai").gen_spec.treesitter({ -- code block
                      a = { "@code_cell.outer", "@block.outer", "@conditional.outer", "@loop.outer" },
                      i = { "@code_cell.inner", "@block.inner", "@conditional.inner", "@loop.inner" },
                    }),
                    f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
                    c = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
                    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
                    d = { "%f[%d]%d+" }, -- digits
                    e = { -- Word with case
                      { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
                      "^().*()$",
                    },
                    u = require("mini.ai").gen_spec.function_call(), -- u for "Usage"
                    U = require("mini.ai").gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
                  },
                })-- }}}

                require("mini.align").setup()

                -- {{{ mini.comments
                local os_name = vim.loop.os_uname().sysname
                local mappings = (os_name == "Linux")
                and {
                  comment = "<C-/>",
                  comment_line = "<C-/>",
                  comment_visual = "<C-/>",
                  textobject = "<C-/>",
                }
                or {
                  comment = "<C-_>",
                  comment_line = "<C-_>",
                  comment_visual = "<C-_>",
                  textobject = "<C-_>",
                }

                require("mini.comment").setup({
                  options = {},
                  mappings = mappings,
                })-- }}}

                require("mini.pairs").setup({-- {{{
                  modes = { insert = true, command = true, terminal = false },
                  -- skip autopair when next character is one of these
                  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
                  -- skip autopair when the cursor is inside these treesitter nodes
                  skip_ts = { "string" },
                  -- skip autopair when next character is closing pair
                  -- and there are more closing pairs than opening pairs
                  skip_unbalanced = true,
                  -- better deal with markdown code blocks
                  markdown = true,
                  mappings = {
                    ['<'] = { action = 'open', pair = '<>', neigh_pattern = '[^\\].',   register = { cr = false } },
                    ['>'] = { action = 'close', pair = '<>', neigh_pattern = '[^\\].',   register = { cr = false } },
                  }
                })-- }}}

                require("mini.splitjoin").setup({-- {{{
                  mappings = {
                    toggle = 'gS',
                    split = 'gk',
                    join = 'gj',
                  },
                })-- }}}

                require("mini.surround").setup({-- {{{
                  -- - gsaiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
                  -- - gsd'   - [S]urround [D]elete [']quotes
                  -- - gsr)'  - [S]urround [R]eplace [)] [']
                  mappings = {
                    add = "gsa", -- Add surrounding in Normal and Visual modes
                    delete = "gsd", -- Delete surrounding
                    find = "gsf", -- Find surrounding (to the right)
                    find_left = "gsF", -- Find surrounding (to the left)
                    highlight = "gsh", -- Highlight surrounding
                    replace = "gsr", -- Replace surrounding
                    update_n_lines = "gsn", -- Update `n_lines`
                  },
                })-- }}}

                require('mini.pick').setup()

                local miniclue = require("mini.clue")-- {{{
                  miniclue.setup({
                    triggers = {
                      -- Leader triggers
                      { mode = "n", keys = "<Leader>" },
                      { mode = "x", keys = "<Leader>" },
                      -- Built-in completion
                      { mode = "i", keys = "<C-x>" },
                      -- `g` key
                      { mode = "n", keys = "g" },
                      { mode = "x", keys = "g" },
                      -- Marks
                      { mode = "n", keys = "'" },
                      { mode = "n", keys = "`" },
                      { mode = "x", keys = "'" },
                      { mode = "x", keys = "`" },
                      -- Registers
                      { mode = "n", keys = '"' },
                      { mode = "x", keys = '"' },
                      { mode = "i", keys = "<C-r>" },
                      { mode = "c", keys = "<C-r>" },
                      -- Window commands
                      -- { mode = 'n', keys = '<C-w>' },
                      -- `z` key
                      { mode = "n", keys = "z" },
                      { mode = "x", keys = "z" },
                      -- `\` toggle key
                      { mode = "n", keys = "\\" },
                      { mode = "x", keys = "\\" },
                    },
                    clues = {
                      -- Enhance this by adding descriptions for <Leader> mapping groups
                      miniclue.gen_clues.builtin_completion(),
                      miniclue.gen_clues.g(),
                      miniclue.gen_clues.marks(),
                      miniclue.gen_clues.registers(),
                      -- miniclue.gen_clues.windows(),
                      miniclue.gen_clues.z(),
                    }
                  })-- }}}

                end,
                keys = {
                  -- { "<leader>ff", mode = {"n", "v" }, function() MiniPick.builtin.files({ source = {items = vim.fn.readdir(".")} })  end, desc = "Find file in cwd", noremap = true, silent = true },
                  { "<leader>ff", mode = {"n", "v" }, function() MiniPick.start({ source = {items = vim.fn.readdir(vim.fn.expand("%:p:h"))} })  end, desc = "Find file in cwd", noremap = true, silent = true },
                  { "<leader>e", mode = {"n", "v" }, function() MiniExtra.pickers.explorer()  end, desc = "File Explorer", noremap = true, silent = true },
                },
              },
              -- }}}

    },-- }}}

  }) 
-- }}}
