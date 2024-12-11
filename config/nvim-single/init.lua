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
-- OPTIONS
-- +--------------------------------------------------------------------------+

local function options()
  local opt = vim.opt

  -- file
  opt.backup = false -- create a backup file
  opt.clipboard = "unnamedplus" -- system clipboard
  opt.concealcursor = "" -- conceal cursor disable
  opt.conceallevel = 0 -- conceal level disable
  opt.fileencoding = "utf-8" -- character encoding
  opt.filetype = "plugin" -- plugin loading of file types
  opt.hidden = true -- switching from unsaved buffers
  opt.inccommand = 'split' -- preview substitutions live, as you type
  opt.iskeyword:remove("_") -- oddeli slova pri mazani, nebude brat ako jedno slovo
  opt.matchtime = 2 -- duration of showmatch, default 5
  opt.mouse = "a" -- mouse
  opt.scrolloff = 5 -- how many lines are displayed on the upper and lower sides of the cursor
  opt.showmode = true -- display the current vim mode (no need)
  opt.sidescrolloff = 8 -- number of columns to keep at the sides of the cursor
  opt.splitbelow = true -- splitting window below
  opt.splitright = true -- splitting window right
  opt.swapfile = false -- create a swap file
  opt.syntax = "on"
  opt.termguicolors = true -- terminal supports more colors
  opt.timeoutlen = 300 -- time to wait for a mapped sequence to complete, default 1000
  opt.updatetime = 100 -- speed up response time
  opt.whichwrap:append("<,>,[,],h,l") -- keys allowed to move to the previous/next line when the beginning/end of line is reached
  opt.wrap = false -- disable wrapping of lines longer than the width of window
  opt.writebackup = false -- create backups when writing files

  -- completition
  opt.completeopt = { "menuone" , "noselect" } -- completion options
  opt.pumheight = 10 -- completion menu height
  opt.wildmenu = true  -- make tab completion for files/buffers act like bash

  -- fold
  opt.foldenable = true -- folding allowed
  opt.foldlevel = 1 -- folding from lvl 1
  opt.foldmethod = "expr" -- folding method
  -- opt.foldexpr = "nvim_treesitter#foldexpr()" -- folding method use treesitter
  opt.foldcolumn = "1" -- folding column show
  -- opt.foldtext=[[getline(v:foldstart)]]        -- Folding - disable all chunk when folded
  opt.fillchars:append({
      eob = " ",
      fold = " ",
      foldopen = "",
      foldsep = " ",
      foldclose = ""
      })

  -- indention
  local indent = 2
  opt.autoindent = true -- auto indentation
  opt.expandtab = true -- convert tabs to spaces (prefered for python)
  opt.shiftround = true -- use multiple of shiftwidth when indenting with "<" and ">"
  opt.shiftwidth = indent  -- spaces inserted for each indentation
  opt.smartindent = true -- make indenting smarter
  opt.softtabstop = indent -- when hitting <BS>, pretend like a tab is removed, even if spaces
  opt.tabstop = indent -- insert spaces for a tab

  -- search
  opt.hlsearch = true -- search highlighting
  opt.ignorecase = true -- ignore case when searching
  opt.incsearch = true -- highlight while searching
  opt.smartcase = true -- intelligent case sensitivity when searching (if there is upper case, turn off case ignoring)
  opt.wildignore = opt.wildignore + { "*/node_modules/*", "*/.git/*", "*/vendor/*" }
  opt.wrapscan = true -- search the entire file repeatedly

  -- ui
  --opt.cmdheight = 0 -- command line height
  opt.cursorline = true -- highlight the current line
  --opt.laststatus = 3 -- global status bar (sposobuje nefunkcnost resource lua.init)
  opt.number = true -- absolute line numbers
  opt.numberwidth = 1 -- number column width, default is 4
  --opt.relativenumber = true -- relative line numbers
  opt.signcolumn = "yes" -- symbol column width
  opt.list = true -- show some invisible characters (tabs...
  opt.listchars = { eol = "¬", tab = "› ", trail = "·" } -- list characters

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
-- AUTOCOMMANDS
-- +--------------------------------------------------------------------------+
local function autocommands()
  -- [[highlight on yank]]
  vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
      vim.highlight.on_yank({
          higroup = "incsearch",
          timeout = 300,
          })
      end,
      group = mygroup,
      desc = "Highlight yanked text",
      })
end

autocommands()

-- +--------------------------------------------------------------------------+
-- LAZY MANAGER
-- +--------------------------------------------------------------------------+
