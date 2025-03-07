local opt = vim.opt
local is_wsl = vim.fn.has("wsl")
local hostname = vim.fn.hostname()

opt.backup = false                           -- Whether to create a backup file
opt.clipboard = "unnamedplus"                -- Use the system clipboard
opt.cmdheight = 0                            -- Set command line height
opt.completeopt = { "menuone" , "noselect" } -- Set completion options
opt.conceallevel = 0                         -- Conceal level disable
opt.concealcursor = ""                       -- Conceal cursor disable
opt.cursorline = true                        -- Highlight the current line
opt.expandtab = true                         -- Convert tabs to spaces
opt.fillchars:append({
  eob = " ",
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = ""
})
opt.fileencoding = "utf-8"                   -- Set the character encoding of the file where the current buffer is located
opt.filetype = "plugin"                      -- Allow plugin loading of file types
opt.foldenable = true                        -- Folding allowed
opt.foldlevel = 1                            -- Folding from lvl 1
opt.foldmethod = "expr"                      -- Folding method
opt.foldexpr = "nvim_treesitter#foldexpr()"  -- Folding method use treesitter
-- opt.foldcolumn = "1"                      -- Folding column show
opt.foldtext=[[getline(v:foldstart)]]        -- Folding - disable all chunk when folded
opt.hidden = true                            -- Allow switching from unsaved buffers
opt.hlsearch = true                          -- Allow search highlighting
opt.ignorecase = true                        -- Ignore case when searching
opt.incsearch = true                         -- Highlight while searching
opt.iskeyword:remove("_")                       -- Oddeli slova pri mazani, nebude brat ako jedno slovo
opt.laststatus = 3                           -- Enable global status bar
opt.list = false                              -- Allow padding with special characters
-- opt.listchars = { eol = "¬", tab = "› " }
opt.matchtime = 2                            -- Default is 5, set the duration of showmatch
opt.mouse = "a"                              -- Allow the use of the mouse
opt.number = true                            -- Allow absolute line numbers
opt.relativenumber = true                    -- Allow relative line numbers
opt.numberwidth = 1                          -- Set the width of the number column, default is 4
opt.pumheight = 10                           -- Set the height of the completion menu
opt.scrolloff = 5                            -- Set how many lines are always displayed on the upper and lower sides of the cursor
opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,globals"    -- Set options for saving sessions
opt.shiftwidth = 2                           -- Number of space inserted for indentation
opt.showmode = false                         -- Allows to display the current vim mode (no need)
opt.sidescrolloff = 8                        -- Number of columns to keep at the sides of the cursor
opt.signcolumn = "yes:1"                     -- Set the width of the symbol column, if not set, it will cause an exception when displaying the icon
opt.smartcase = true                         -- Intelligent case sensitivity when searching (if there is upper case, turn off case ignoring)
-- opt.smartindent = false                       -- Set smart indent
-- opt.autoindent = true
opt.splitbelow = true                        -- Splitting a new window below the current one
opt.splitright = true                        -- Splitting a new window at the right of the current one
opt.swapfile = false                         -- Whether to create a swap file
opt.syntax = "on"
opt.tabstop = 2                              -- Number of space in a tab
opt.termguicolors = true                     -- Terminal supports more colors
opt.timeoutlen = 300                         -- Set timeout
opt.updatetime = 100                         -- Speed up response time
-- opt.whichwrap:append("<,>,[,],h,l")         -- keys allowed to move to the previous/next line when the beginning/end of line is reached
opt.wrap = false                             -- Disable wrapping of lines longer than the width of window
opt.wrapscan = true                          -- Allows to search the entire file repeatedly (continuation of the search after the last result will return to the first result)
opt.writebackup = false                      -- Whether to create backups when writing files

local builtin_plugins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "matchit",
    "netrw",
    "netrwFileHandlers",
    "netrwPlugin",
    "netrwSettings",
    "rrhelper",
    "spellfile_plugin",
    "tar",
    "tarPlugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
  }

for i = 1, #builtin_plugins do
  vim.g['loaded_' .. builtin_plugins[i]] = true
end

-- point neovim to python virtualenv as default
-- zatial nefunguje
vim.g.python3_host_prog=vim.fn.expand("~/python-venv/nvim-venv/bin/python3")

-- nastavenia pre WSL a klasicky linuxW
if (is_wsl == 1 and hostname == "vimi-jonsbo") then
  opt.guicursor = {"n-v-c:block,i-ci-ve:bar-blinkwait200-blinkoff150-blinkon150"}  -- Cursor help: guicursor
  opt.shell = "/bin/bash"
elseif
  is_wsl == 1 then
  opt.shell = "/bin/bash"
else
  opt.shell = "/bin/zsh"
end
