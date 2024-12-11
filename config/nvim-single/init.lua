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
  local g = vim.g

  -- File
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

  -- Completition
  opt.completeopt = { "menuone" , "noselect" } -- completion options
  opt.pumheight = 10 -- completion menu height
  opt.wildmenu = true  -- make tab completion for files/buffers act like bash

  -- Fold
  opt.foldenable = true -- folding allowed
  opt.foldlevel = 1 -- folding from lvl 1
  opt.foldmethod = "expr" -- folding method
  -- opt.foldexpr = "nvim_treesitter#foldexpr()" -- folding method use treesitter
  opt.foldcolumn = "1" -- folding column show
  -- opt.foldtext=[[getline(v:foldstart)]] -- folding - disable all chunk when folded
  opt.fillchars:append({
    eob = " ",
    fold = " ",
    foldopen = "",
    foldsep = " ",
    foldclose = ""
  })

  -- Indention
  local indent = 2
  opt.autoindent = true -- auto indentation
  opt.expandtab = true -- convert tabs to spaces (prefered for python)
  opt.shiftround = true -- use multiple of shiftwidth when indenting with "<" and ">"
  opt.shiftwidth = indent  -- spaces inserted for each indentation
  opt.smartindent = true -- make indenting smarter
  opt.softtabstop = indent -- when hitting <BS>, pretend like a tab is removed, even if spaces
  opt.tabstop = indent -- insert spaces for a tab

  -- Search
  opt.hlsearch = true -- search highlighting
  opt.ignorecase = true -- ignore case when searching
  opt.incsearch = true -- highlight while searching
  opt.smartcase = true -- intelligent case sensitivity when searching (if there is upper case, turn off case ignoring)
  opt.wildignore = opt.wildignore + { "*/node_modules/*", "*/.git/*", "*/vendor/*" }
  opt.wrapscan = true -- search the entire file repeatedly

  -- UI
  --opt.cmdheight = 0 -- command line height
  opt.cursorline = true -- highlight the current line
  opt.laststatus = 3 -- global status bar (sposobuje nefunkcnost resource lua.init)
  opt.number = true -- absolute line numbers
  --opt.relativenumber = true -- relative line numbers
  opt.signcolumn = "yes" -- symbol column width
  opt.list = true -- show some invisible characters (tabs...
  opt.listchars = { eol = "¬", tab = "› ", trail = "·", nbsp = '␣' } -- list characters

  -- Netrw File manager
  g.netrw_banner = 0 -- disable the banner at the top
  g.netrw_liststyle = 0 -- use a tree view for directories
  g.netrw_winsize = 30 -- set the width of the netrw window (in percent)
  g.netrw_sort_by = "name" -- sort files by name; can be 'name', 'time', 'size', etc.

  -- OS specific
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
  map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })
  map("n", "<C-w>", "<cmd>wq<cr>", { desc = "Save-Quit" })
  map("n", "<C-q>", "<cmd>q!<cr>", { desc = "Quit" })
  map("n", "<leader>x", "<cmd>w<cr><cmd>luafile %<cr><esc>", { desc = "Reload Lua" })

  -- Basic file system commands
  map("n", "<leader>fc", "<cmd>!touch<space>", { desc = "Create file" })
  map("n", "<leader>dc", "<cmd>!mkdir<space>", { desc = "Create directory" })
  map("n", "<leader>mv", "<cmd>!mv<space>%<space>", {desc = "Move"})

  -- Visual block mode - oznacovanie stlpcov
  map("n", "<A-v>", "<C-q>", { desc = "Visual block mode" })

  -- Clear search with <esc>
  map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "No highlight" })

  -- Windows
  map("n", "<leader>wv", "<C-w>v", { desc = "Vertical" })
  map("n", "<leader>wh", "<C-w>s", { desc = "Horizontal" })
  map("n", "<leader>w=", "<C-W>=", { desc = "Equal" })
  map("n", "<leader>wlh", "<cmd>windo wincmd K<cr>", { desc = "Horizontal layout" })
  map("n", "<leader>wlv", "<cmd>windo wincmd H<cr>", { desc = "Vertical layout" })

  map("n", "<C-Up>", "<C-w>k", { desc = "Go UP" })
  map("n", "<C-Down>", "<C-w>j", { desc = "Go DOWN" })
  map("n", "<C-Left>", "<C-w>h", { desc = "Go LEFT" })
  map("n", "<C-Right>", "<C-w>l", { desc = "Go RIGHT" })
  map("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "Resize UP" })
  map("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "Resize DOWN" })
  map("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Resize LEFT" })
  map("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize RIGHT" })
  map("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize RIGHT" })

  -- Buffers
  map("n", "<A-Right>", "<cmd>bnext<cr>", { desc = "Next buffer" })
  map("n", "<A-Left>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
  map("n", "<A-UP>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })
  map("n", "<A-Down>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })

  -- Indenting
  map("v", "<", "<gv", { desc = "Unindent line" })
  map("v", ">", ">gv", { desc = "Indent line" })

  -- Move lines
  map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text DOWN" })
  map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text UP" })
  map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move text DOWN" })
  map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move text UP" })
  map("v", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text UP" })
  map("v", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text DOWN" })
  map("x", "<A-j>", "<cmd>move '>+1<cr>gv-gv", { desc = "Move text UP" })
  map("x", "<A-k>", "<cmd>move '<-2<cr>gv-gv", { desc = "Move text DOWN" })

  -- Paste over currently selected text without yanking it
  map("v", "p", '"_dP', { desc = "Paste no yank" })
  map("n", "x", '"_x', { desc = "Delete character no yank" })

  -- Improved Terminal Mappings
  map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

  -- Mix
  map("n", "<A-a>", "<esc>ggVG<cr>", { desc = "Select all text" })
  map("n", "<BS>", "X", { desc = "TAB as X in NORMAL mode" })


  -- Netrw
  map("n", "<leader>e", "<cmd>Lex<cr>", { desc = "File manager" })
  -- Function to set up Netrw mappings


end

keymaps()




-- +--------------------------------------------------------------------------+
-- AUTOCOMMANDS
-- +--------------------------------------------------------------------------+
local function autocommands()
  -- highlight on yank
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
