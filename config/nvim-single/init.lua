--https://github.com/benfrain/neovim/blob/main/lua/options.lua
--https://github.com/YanivZalach/Vim_Config_NO_PLUGINS/blob/main/.vimrc
--https://github.com/NormTurtle/Windots/blob/main/vi/init.lua
--https://github.com/ntk148v/neovim-config/blob/master/lua/options.lua
--https://github.com/sodabyte/minimal-nvim/blob/main/lua/config/options.lua
-- Determine the operating system
local function detect_os_type()
  local os_name = vim.loop.os_uname().sysname
  local os_type 

  if os_name == "Windows_NT" then
    os_type = "windows"
  elseif os_name == "Linux" then
    local is_wsl = vim.fn.has("wsl") == 1 -- Check if it's WSL
    if is_wsl then
      os_type = "wsl"	
    else
      os_type = "linux"
    end
  else
    os_type = os_name
  end

  return os_type
end

local os_type = detect_os_type()

print("detected os: " .. detect_os_type())

-- +--------------------------------------------------------------------------+
-- KEYMAPS
-- +--------------------------------------------------------------------------+

local function keymaps()
  -- Wrapper for mapping custom keybindings
  local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
      options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
  end

  -- Space as leader key
  map("", "<Space>", "<Nop>")
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Save, Quit, Reload
  map("n", "<C-s>", ":w<cr>", { desc = "Save" })
  map("n", "W", ":wq<cr>", { desc = "Save-Quit" })
  map("n", "Q", ":q!<cr>", { desc = "Quit" })
  map("n", "<leader>x", ":w<cr>:luafile %<cr>", { desc = "Reload Lua" })
end

keymaps()

-- +--------------------------------------------------------------------------+
-- OPTIONS
-- +--------------------------------------------------------------------------+

local function options()
  local opt = vim.opt

  -- search
  opt.hlsearch = true                          -- Allow search highlighting
  opt.ignorecase = true                        -- Ignore case when searching
  opt.incsearch = true                         -- Highlight while searching
  opt.smartcase = true                         -- Intelligent case sensitivity when searching (if there is upper case, turn off case ignoring)
  opt.wildignore = opt.wildignore + { "*/node_modules/*", "*/.git/*", "*/vendor/*" }
  opt.wildmenu = true   -- make tab completion for files/buffers act like bash

  -- indention
  local indent = 2
  opt.autoindent = true -- auto indentation
  opt.smartindent = true -- make indenting smarter
  opt.shiftround = true    -- use multiple of shiftwidth when indenting with "<" and ">"
  opt.expandtab = true -- convert tabs to spaces (prefered for python)
  opt.shiftwidth = indent  -- spaces inserted for each indentation
  opt.tabstop = indent -- insert spaces for a tab
  opt.softtabstop = indent -- when hitting <BS>, pretend like a tab is removed, even if spaces
  opt.list = true
  opt.listchars = { eol = "¬", tab = "› " }

  -- file
  opt.backup = false                           -- Whether to create a backup file
  opt.clipboard = "unnamedplus" -- Use the system clipboard
  opt.mouse = "a" -- Allow the use of the mouse
  opt.fileencoding = "utf-8"                   -- Set the character encoding of the file where the current buffer is located
  opt.filetype = "plugin"                      -- Allow plugin loading of file types
  --opt.hidden = true                            -- Allow switching from unsaved buffers

  -- ui
  --opt.cmdheight = 0                            -- Set command line height
  opt.number = true -- Allow absolute line numbers
  --opt.relativenumber = true                    -- Allow relative line numbers
  opt.cursorline = true                        -- Highlight the current line
  opt.laststatus = 3                           -- Enable global status bar

  -- completition
  opt.completeopt = { "menuone" , "noselect" } -- Set completion options

  -- fold
  opt.foldenable = true                        -- Folding allowed
  opt.foldlevel = 1                            -- Folding from lvl 1
  opt.foldmethod = "expr"                      -- Folding method
  opt.foldexpr = "nvim_treesitter#foldexpr()"  -- Folding method use treesitter
  -- opt.foldcolumn = "1"                      -- Folding column show
  opt.foldtext=[[getline(v:foldstart)]]        -- Folding - disable all chunk when folded
  opt.fillchars:append({
      eob = " ",
      fold = " ",
      foldopen = "",
      foldsep = " ",
      foldclose = ""
      })

opt.conceallevel = 0                         -- Conceal level disable
opt.concealcursor = ""                       -- Conceal cursor disable
opt.iskeyword:remove("_")                       -- Oddeli slova pri mazani, nebude brat ako jedno slovo
opt.matchtime = 2                            -- Default is 5, set the duration of showmatch
opt.numberwidth = 1                          -- Set the width of the number column, default is 4
opt.pumheight = 10                           -- Set the height of the completion menu
opt.scrolloff = 5                            -- Set how many lines are always displayed on the upper and lower sides of the cursor
opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,globals"    -- Set options for saving sessions
opt.showmode = false                         -- Allows to display the current vim mode (no need)
opt.sidescrolloff = 8                        -- Number of columns to keep at the sides of the cursor
opt.signcolumn = "yes:1"                     -- Set the width of the symbol column, if not set, it will cause an exception when displaying the icon
opt.splitbelow = true                        -- Splitting a new window below the current one
opt.splitright = true                        -- Splitting a new window at the right of the current one
opt.swapfile = false                         -- Whether to create a swap file
opt.syntax = "on"
opt.termguicolors = true                     -- Terminal supports more colors
opt.timeoutlen = 300                         -- Set timeout
opt.updatetime = 100                         -- Speed up response time
-- opt.whichwrap:append("<,>,[,],h,l")         -- keys allowed to move to the previous/next line when the beginning/end of line is reached
opt.wrap = false                             -- Disable wrapping of lines longer than the width of window
opt.wrapscan = true                          -- Allows to search the entire file repeatedly (continuation of the search after the last result will return to the first result)
opt.writebackup = false                      -- Whether to create backups when writing files

  -- nastavenia kurzoru
  if os_type == "wsl" then
    opt.guicursor = {"n-v-c:block,i-ci-ve:bar-blinkwait200-blinkoff150-blinkon150"}  -- Cursor help: guicursor
    opt.shell = "/bin/bash"
  elseif os_type == "linux" then
    opt.shell = "/bin/zsh"
  elseif os_type == "windows" then
    opt.shell = "pwsh.exe"
    opt.shellcmdflag = "-NoLogo"
    opt.shellquote = ""
    opt.shellxquote = ""
  else
    opt.shell = "/bin/zsh"
  end

end

options()

