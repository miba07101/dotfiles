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
-- opt.updatetime       = 100 -- speed up response time
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

-- {{{ [[ AUTOCOMANDS ]]
local mygroup = vim.api.nvim_create_augroup("vimi", { clear = true })

-- {{{ restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if vim.fn.line("'\"") >= 1 and vim.fn.line("'\"") <= vim.fn.line("$") and vim.fn.expand("&ft") ~= "commit" then
      vim.cmd('normal! g`"')
    end
  end,
  group = mygroup,
  desc = "restore cursor position",
})
-- }}}

-- {{{ show cursor line only in active window
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  pattern = "*",
  command = "set cursorline",
  group = mygroup,
  desc = "show cursorline in active window",
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  pattern = "*",
  command = "set nocursorline",
  group = mygroup,
  desc = "hide cursorline in inactive window",
})
-- }}}

-- {{{ don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", {
  command = [[set formatoptions-=cro]],
  group = mygroup,
  desc = "don't auto comment new line",
})
-- }}}

-- {{{ set fold markers for init.lua
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "init.lua",
  callback = function()
    vim.opt_local.foldmethod = "marker" -- use markers for init.lua
    vim.opt_local.foldexpr = "" -- disable foldexpr
    vim.opt_local.foldlevel = 0 -- start with all folds closed
  end,
  group = mygroup,
  desc = "init.lua folding",
})
-- }}}

-- {{{ unfold at open
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = { "*.py", "*.ipynb", "*.css", "*.scss", "*.html", "*.qmd", "*.md" },
  command = [[:normal! zR]], -- zR-open, zM-close folds
  group = mygroup,
  desc = "unfold",
})
-- }}}

-- {{{ conceal level = 1
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.md",
  command = [[:setlocal conceallevel=1]],
  group = mygroup,
  desc = "conceal level",
})
-- }}}

-- -- {{{ autoformat code on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = { "*.py", "*.json", "*.css", "*.scss" },
--   callback = function(args)
--     require("conform").format({ bufnr = args.buf })
--   end,
--   group = mygroup,
--   desc = "autoformat code on save",
-- })
-- -- }}}

-- -- {{{ auto linting
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
--   pattern = { "*" },
--   callback = function()
--     require("lint").try_lint()
--   end,
-- })
-- -- }}}

-- {{{ sass compilation on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.sass", "*.scss" },
  command = [[:silent exec "!sass --no-source-map %:p %:r.css"]],
  group = mygroup,
  desc = "sass compilation on save",
})
-- }}}

-- {{{ windows to close with "q"
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "toggleterm", "help", "startuptime", "qf", "lspinfo", "man" },
  command = [[nnoremap <buffer><silent> q :close<cr>]],
  group = mygroup,
  desc = "close windows with q",
})

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "man",
--   command = [[nnoremap <buffer><silent> q :quit<cr>]],
--   group = mygroup,
--   desc = "close man pages with q",
-- })
-- }}}

-- {{{ open terminal at same location as opened file
vim.api.nvim_create_autocmd("BufEnter", {
  command = [[silent! lcd %:p:h]],
  group = mygroup,
  desc = "open terminal in same location as opened file",
})
-- }}}

-- {{{ htmldjango - v treesitter instalovat jinja a jinja_inline (htmldjango netreba nepaci sa mi syntax highlight)
-- Function to select the filetype for HTML-based templates with Jinja
local function select_html_filetype()
    local n = 1
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    while n <= #lines and n < 100 do
        -- Check for Jinja tags like {{ ... }} or {% ... %}
        if lines[n]:match("{{.*}}") or lines[n]:match("{%%?%s*(end.*|extends|block|macro|set|if|for|include|trans)>") then
            vim.bo.filetype = "htmldjango"  -- Set filetype to htmldjango for Jinja content
            return
        end
        n = n + 1
    end
end

-- Autocommands to handle .html and related files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.html", "*.htm" },  -- Only for HTML files
    callback = select_html_filetype,   -- Check if it contains Jinja tags and assign the filetype
})
-- }}}

-- create a new Python notebook (Jupyter notebook){{{
-- https://github.com/benlubas/molten-nvim/blob/main/docs/Notebook-Setup.md
-- note: the metadata is needed for Jupytext to understand how to parse the notebook.
-- if you use another language than Python, you should change it in the template.

-- JSON template{{{
local default_notebook = [[
{
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": [""]
    }
  ],
  "metadata": {
    "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
    },
    "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
    }
  },
  "nbformat": 4,
  "nbformat_minor": 5
}
]]
--}}}

local function new_notebook(filename)-- {{{
  -- upravena povodna funkcia pomocou AI
  local path = filename .. ".ipynb"
  local file, err = io.open(path, "wb")  -- Use "wb" to ensure binary mode (no BOM)

  if not file then
    vim.api.nvim_err_writeln("Error: Could not open " .. path .. " for writing: " .. err)
    return
  end

  -- Ensure UTF-8 without BOM encoding
  file:write(default_notebook)
  file:close()

  -- Delay opening slightly to ensure Jupytext reads a valid file
  vim.defer_fn(function()
    vim.cmd("edit " .. path)
  end, 100)  -- 100ms delay
end-- }}}

vim.api.nvim_create_user_command('NewNotebook', function(opts)-- {{{
  new_notebook(opts.args)
end, {
  nargs = 1,
  complete = 'file'
})-- }}}

-- keymap for new Jupyter notebook creation
map("n", "<leader>pj", function() local file_name=vim.fn.input("Notebook name: ") if file_name ~= "" then vim.cmd("NewNotebook " .. file_name) end end, { desc = "jupyter notebook" })
--}}}

-- {{{ set typst filetype - quarto specific
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  pattern = "*.typ",
  command = "set filetype=typst",
  desc = "set filetype for typst files",
})
-- }}}

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

        -- {{{ [ Colorscheme ]
        { "rebelot/kanagawa.nvim",-- {{{
          -- enabled = false,
          priority = 1000,
          config = function()
            vim.cmd.colorscheme("kanagawa")
          end,
        },-- }}}
        -- }}}

        -- {{{ [ Mini.nvim collection ]
        { "echasnovski/mini.nvim",
        event = "VeryLazy",
        enabled = true,
        config = function()

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
            silent = true,
          })-- }}}

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
                -- Bracketed
                { mode = 'n', keys = '[' },
                { mode = 'n', keys = ']' },
              },
              clues = {
                -- Enhance this by adding descriptions for <Leader> mapping groups
                miniclue.gen_clues.builtin_completion(),
                miniclue.gen_clues.g(),
                miniclue.gen_clues.marks(),
                miniclue.gen_clues.registers(),
                -- miniclue.gen_clues.windows(),
                miniclue.gen_clues.z(),
                -- moje skratky - normal mode
                { mode = "n", keys = "<Leader>f", desc = "+Files" },
                { mode = "n", keys = "<Leader>s", desc = "+Search" },
                { mode = "n", keys = "<Leader>g", desc = "+Git" },
                { mode = "n", keys = "<Leader>w", desc = "+Window" },
                { mode = "n", keys = "<Leader>wl", desc = "+Layout" },
                { mode = "n", keys = "<Leader>/", desc = "+Grep" },
              }
            })-- }}}

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

            require('mini.icons').setup()

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
              custom_surroundings = {
                ['l'] = { output = { left = '[', right = ']()'}}
              }
            })-- }}}

          end,
        },
        -- }}}

  -- {{{ [ Snack.nvim collection ]
        {
          "folke/snacks.nvim",
          priority = 1000,
          lazy = false,
          -- enabled = false,
          opts = {
            styles = {-- {{{
            },-- }}}
            image = {-- {{{
              enabled = true,
              formats = {
                "png",
                "jpg",
                "jpeg",
                "gif",
                "bmp",
                "webp",
                "tiff",
                "heic",
                "avif",
                "mp4",
                "mov",
                "avi",
                "mkv",
                "webm",
                "pdf",
              },
              force = true,
            },-- }}}
            input = { enabled = true },
            lazygit = { enabled = true },
            notifier = { enabled = true },
            picker = { enabled = true,-- {{{
              sources = {
                explorer = {
                  -- your explorer picker configuration comes here
                  auto_close = false,
                  win = {
                    list = {
                      keys = {
                        ["<c-h>"] = "toggle_hidden",
                        ["<RIGHT>"] = "confirm",
                        ["<LEFT>"] = "explorer_close", -- close directory
                      },
                    },
                  },
                },
              },
              layout = { preset = "vscode", layout = { position = "bottom" } },
            },-- }}}
            quickfile = { enabled = true }, -- When doing nvim somefile.txt, it will render the file as quickly as possible, before loading your plugins
            rename = { enabled = true },
            scope = { enabled = false }, -- Scope detection based on treesitter or indent (alternative mini.indentscope)
            scroll = { enabled = false }, -- Smooth scrolling for Neovim. Properly handles scrolloff and mouse scrolling (alt mini.animate)
            statuscolumn = { enabled = false },
            terminal = {-- {{{
              enabled = true,
              win = {
                keys = {
                  term_normal = { "<ESC>", "<C-\\><C-n>", desc = "Exit terminal", expr = true, mode = "t" },
                  nav_h = { "<C-Left>", "<cmd>wincmd h<cr>", desc = "Go to Left Window", expr = true, mode = "t" },
                  nav_j = { "<C-Down>", "<cmd>wincmd j<cr>", desc = "Go to Lower Window", expr = true, mode = "t" },
                  nav_k = { "<C-Up>", "<cmd>wincmd k<cr>", desc = "Go to Upper Window", expr = true, mode = "t" },
                  nav_l = { "<C-Right>", "<cmd>wincmd l<cr>", desc = "Go to Right Window", expr = true, mode = "t" },
                  { "<c-\\>", mode = "t",  function()
                    vim.cmd("stopinsert")  -- Exits terminal mode safely
                    require("snacks").terminal()
                  end, desc = "Toggle Terminal" },
                },
              },
            },-- }}}
            words = { enabled = true },
          },
          keys = {
            { "<leader>si", function() require('snacks').image.hover() end, desc = "Image Preview" },
            { "]]", mode = { "n", "t" }, function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
            { "[[", mode = { "n", "t" }, function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
            { "<c-\\>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
            -- Top Pickers & Explorer
            { "<leader>e", function() Snacks.explorer({ layout = { preset = "sidebar", layout = { position = "left" } } }) end, desc = "File Explorer" },
            { "<leader>E", function() vim.cmd("lcd D:\\") Snacks.explorer.open({ layout = { preset = "sidebar", layout = { position = "left" } } }) end, desc = "File Explorer D drive" },
            { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
            { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
            -- find
            { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
            { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
            { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
            { "<leader>fp", function() Snacks.picker.projects() end, desc = "Find Projects" },
            { "<leader>fo", function() Snacks.picker.recent() end, desc = "Find Old/Recent" },
            { "<leader>fR", function() Snacks.rename.rename_file() end, desc = "File Rename" },
            -- git
            { "<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit" },
            { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
            { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
            { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
            { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
            { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
            { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
            { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
            -- Grep
            { "<leader>//", function() Snacks.picker.grep() end, desc = "Grep" },
            { "<leader>/l", function() Snacks.picker.lines() end, desc = "Grep Buffer Lines" },
            { "<leader>/b", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
            { "<leader>/w", function() Snacks.picker.grep_word() end, desc = "Grep Word or Selection", mode = { "n", "x" } },
            -- search
            { '<leader>s"', function() Snacks.picker.registers() end, desc = "Search Registers" },
            { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
            { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Search Autocmds" },
            { "<leader>s:", function() Snacks.picker.commands() end, desc = "Search Commands" },
            { "<leader>sC", function() Snacks.picker.command_history() end, desc = "Command History" },
            { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Search Diagnostics" },
            { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Search Buffer Diagnostics" },
            { "<leader>sh", function() Snacks.picker.help() end, desc = "Search Help Pages" },
            { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Search Highlights" },
            { "<leader>si", function() Snacks.picker.icons() end, desc = "Search Icons" },
            { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Search Jumps" },
            { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Search Keymaps" },
            { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Search Location List" },
            { "<leader>sm", function() Snacks.picker.marks() end, desc = "Search Marks" },
            { "<leader>sM", function() Snacks.picker.man() end, desc = "Search Man Pages" },
            { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
            { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Search Quickfix List" },
            { "<leader>sR", function() Snacks.picker.resume() end, desc = "Search Resume" },
            { "<leader>su", function() Snacks.picker.undo() end, desc = "Search Undo History" },
            { "<leader>sc", function() Snacks.picker.colorschemes() end, desc = "Search Colorschemes" },
            { "<leader>st", function() Snacks.picker.treesitter() end, desc = "Search Treesitter" },
            { "<leader>sN", function() Snacks.picker.notifications() end, desc = "Notification History" },
            -- LSP
            -- { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
            -- { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
            -- { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
            -- { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
            -- { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
            -- { "<leader>sss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
            -- { "<leader>ssS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
          },
        },
        -- }}}

      },-- }}}

    }) 
  -- }}}
