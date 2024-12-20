--https://github.com/benfrain/neovim/blob/main/lua/options.lua
--https://github.com/YanivZalach/Vim_Config_NO_PLUGINS/blob/main/.vimrc
--https://github.com/NormTurtle/Windots/blob/main/vi/init.lua
--https://github.com/ntk148v/neovim-config/blob/master/lua/options.lua
--https://github.com/sodabyte/minimal-nvim/blob/main/lua/config/options.lua

-- {{{ [[ DETECT OS ]]
local function detect_os_type()
  local os_username = os.getenv("USERNAME") or os.getenv("USER")
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

  return os_type, os_username
end

local os_type, os_username = detect_os_type()

-- print("detected os: " .. os_type)
-- print("detected username: " .. os_username)
-- }}}

-- {{{ [[ OPTIONS ]]
local opt = vim.opt
local g = vim.g

-- {{{ File
opt.backup = false -- create a backup file
opt.clipboard = "unnamedplus" -- system clipboard
opt.concealcursor = "" -- conceal cursor disable
opt.conceallevel = 0 -- conceal level disable
opt.fileencoding = "utf-8" -- character encoding
opt.filetype = "plugin" -- plugin loading of file types
opt.hidden = true -- switching from unsaved buffers
opt.inccommand = "split" -- preview substitutions live, as you type
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
opt.timeoutlen = 400 -- time to wait for a mapped sequence to complete, default 1000
opt.updatetime = 100 -- speed up response time
opt.whichwrap:append("<,>,[,],h,l") -- keys allowed to move to the previous/next line when the beginning/end of line is reached
opt.wrap = false -- disable wrapping of lines longer than the width of window
opt.writebackup = false -- create backups when writing files
opt.modifiable = true
-- End File }}}

-- {{{ Completition
opt.completeopt = { "menuone", "noselect" } -- completion options
opt.pumheight = 10 -- completion menu height
opt.wildmenu = true -- make tab completion for files/buffers act like bash
-- End Completition }}}

-- {{{ Fold
opt.foldenable = true -- folding allowed
opt.foldlevel = 1 -- folding from lvl 1
opt.foldmethod = "expr" -- folding method
opt.foldexpr = "nvim_treesitter#foldexpr()" -- folding method use treesitter
opt.foldcolumn = "1" -- folding column show
--opt.foldtext=[[getline(v:foldstart)]] -- folding - disable all chunk when folded
opt.fillchars:append({
  eob = " ",
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = "",
})
-- End Fold }}}

-- {{{ Indention
local indent = 2
opt.autoindent = true -- auto indentation
opt.expandtab = true -- convert tabs to spaces (prefered for python)
opt.shiftround = true -- use multiple of shiftwidth when indenting with "<" and ">"
opt.shiftwidth = indent -- spaces inserted for each indentation
opt.smartindent = true -- make indenting smarter
opt.softtabstop = indent -- when hitting <BS>, pretend like a tab is removed, even if spaces
opt.tabstop = indent -- insert spaces for a tab
-- End Indention }}}

-- {{{ Search
opt.hlsearch = true -- search highlighting
opt.ignorecase = true -- ignore case when searching
opt.incsearch = true -- highlight while searching
opt.smartcase = true -- intelligent case sensitivity when searching (if there is upper case, turn off case ignoring)
opt.wildignore = opt.wildignore + { "*/node_modules/*", "*/.git/*", "*/vendor/*" }
opt.wrapscan = true -- search the entire file repeatedly
-- End Search }}}

-- {{{ UI
opt.cmdheight = 0 -- command line height
opt.cursorline = true -- highlight the current line
opt.laststatus = 3 -- global status bar (sposobuje nefunkcnost resource lua.init)
opt.number = true -- absolute line numbers
--opt.relativenumber = true -- relative line numbers
opt.signcolumn = "yes" -- symbol column width
opt.list = true -- show some invisible characters (tabs...
opt.listchars = { eol = "¬", tab = "› ", trail = "·", nbsp = "␣" } -- list characters
opt.background = "light"
-- End UI }}}

-- {{{ Netrw File Manager
--g.netrw_banner = 0 -- disable the banner at the top
--g.netrw_liststyle = 0 -- use a tree view for directories
--g.netrw_winsize = 30 -- set the width of the netrw window (in percent)
--g.netrw_sort_by = "name" -- sort files by name; can be 'name', 'time', 'size', etc.
-- End Netrw File Manager }}}

-- {{{ OS Cursor, Shell
if os_type == "wsl" then
  opt.guicursor = { "n-v-c:block,i-ci-ve:bar-blinkwait200-blinkoff150-blinkon150" } -- Cursor help: guicursor
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
-- End OS Cursor, Shell }}}

-- {{{ Background
local function set_background()
  -- Try to detect terminal background color if possible
  local term_bg = os.getenv("COLORTERM") -- Example: "truecolor" for modern terminals

  -- Default to 'dark' if no theme detection is available
  local background

  -- Detect based on terminal or system theme
  if term_bg then
    -- If terminal background hints are available (not always reliable)
    background = term_bg:find("light") and "light" or "dark"
  end

  -- Apply the background setting
  vim.opt.background = background
  print("Background set to: " .. background)
end

set_background()
-- Background }}}

-- {{{ Disable Built-in Plugins
local disable_builtin_plugins = {
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

for i = 1, #disable_builtin_plugins do
  vim.g["loaded_" .. disable_builtin_plugins[i]] = true
end
-- End Disable Built-in Plugins }}}

-- End [[ OPTIONS ]] }}}

-- {{{ [[ KEYMAPS ]]

-- {{{ Wrapper for mapping custom keybindings
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
-- End Wrapper }}}

-- {{{ Leader Key
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- End Leader Key }}}

-- {{{ Save, Quit, Reload
map({"n","i"}, "<C-s>", "<cmd>w<cr>", { desc = "Save" })
map({"n","i"}, "<C-w>", "<cmd>wq<cr>", { desc = "Save-Quit" })
map({"n","i"}, "<C-q>", "<cmd>q!<cr>", { desc = "Quit" })
map("n", "<leader>x", "<cmd>w<cr><cmd>luafile %<cr><esc>", { desc = "Reload Lua" })
-- End Save, Quit, Reload }}}

-- {{{ File System Commands
map("n", "<leader>fc", "<cmd>!touch<space>", { desc = "Create file" })
map("n", "<leader>dc", "<cmd>!mkdir<space>", { desc = "Create directory" })
map("n", "<leader>mv", "<cmd>!mv<space>%<space>", { desc = "Move" })
-- End File System Commands }}}

-- {{{ Windows
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
-- End Windows }}}

-- {{{ Buffers
map("n", "<A-Right>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<A-Left>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<A-UP>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })
map("n", "<A-Down>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })
-- End Buffers }}}

-- {{{ Indenting
map("v", "<", "<gv", { desc = "Unindent line" })
map("v", ">", ">gv", { desc = "Indent line" })
-- End Indenting }}}

-- {{{ Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text DOWN" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text UP" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move text DOWN" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move text UP" })
map("v", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text UP" })
map("v", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text DOWN" })
map("x", "<A-j>", "<cmd>move '>+1<cr>gv-gv", { desc = "Move text UP" })
map("x", "<A-k>", "<cmd>move '<-2<cr>gv-gv", { desc = "Move text DOWN" })
-- End Move Lines }}}

-- {{{ Better Paste
map("v", "p", '"_dP', { desc = "Paste no yank" })
map("n", "x", '"_x', { desc = "Delete character no yank" })
-- End Better Paste }}}

-- {{{ Terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- End Terminal }}}

-- {{{ Mix
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "No highlight" })
map("n", "<A-a>", "<esc>ggVG<cr>", { desc = "Select all text" })
map("n", "<BS>", "X", { desc = "TAB as X in NORMAL mode" })
map("n", "<A-v>", "<C-q>", { desc = "Visual block mode" })
-- End Mix }}}

-- {{{ NeoVim
map("n", "<leader>vn", "<cmd>set relativenumber!<cr>", { desc = "Numbers toggle" })
map("n", "<leader>vl", "<cmd>IBLToggle<cr>", { desc = "Blankline toggle" })
map("n", "<leader>vb", "<cmd>let &bg=(&bg == 'dark' ? 'light' : 'dark' )<CR>", { desc = "Background toggle" })
map("n", "<leader>vc", function()
  if vim.o.conceallevel > 0 then
    vim.o.conceallevel = 0
  else
    vim.o.conceallevel = 1
  end
end, { desc = "Conceal level toggle" })
map("n", "<leader>vk", function()
  if vim.o.concealcursor == "n" then
    vim.o.concealcursor = ""
  else
    vim.o.concealcursor = "n"
  end
end, { desc = "Conceal cursor toggle" })
-- End NeoVim }}}

-- {{{ File Manager
map("n", "<leader>e", "<cmd>Neotree toggle %:p:h<cr>", { desc = "File manager" })
map("n", "<leader>eb", "<cmd>Neotree buffers<cr>", { desc = "Buffers manager" })
-- File Manager}}}

-- {{{ LSP
map("n", "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Definition" })
map("n", "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "Declaration" })
map("n", "<leader>lk", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "Hoover" })
map("n", "<leader>lI", "<cmd>lua vim.lsp.buf.implementation()<cr>", { desc = "Implementation" })
map("n", "<leader>lr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "References" })
map("n", "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<leader>lf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Formatting" })
map("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code action" })
map("n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "Signature help" })
map("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "Server info" })
-- End LSP }}}

-- {{{ Diagnostic
-- enable / disable diagnostic
local diagnostics_active = true
local toggle_diagnostics = function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable()
  else
    vim.diagnostic.enable(false)
  end
end

map("n", "<leader>dd", toggle_diagnostics, { desc = "diagnostic toggle" })
map("n", "<leader>dn", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", { desc = "next" })
map("n", "<leader>dp", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", { desc = "prev" })
map("n", "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", { desc = "loc list" })
map("n", "<leader>df", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "open float" })
map("n", "<leader>dt", "<cmd>windo diffthis<CR>", { desc = "differ this" })
map("n", "<leader>do", "<cmd>diffoff!<CR>", { desc = "differ off" })
map("n", "<leader>du", "<cmd>diffupdate<CR>", { desc = "differ update" })
-- End Diagnostic }}}

-- {{{ Python
map("n", "<leader>pe", "<cmd>lua require('swenv.api').pick_venv()<cr>", { desc = "pick venvs" })
-- Python }}}

-- End [[ KEYMAPS ]] }}}

-- {{{ [[ AUTOCOMANDS ]]
local mygroup = vim.api.nvim_create_augroup("vimrc", { clear = true })

-- {{{ Highlight on Yank
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
-- End Highlight on Yank }}}

-- {{{ Set Fold Markers for init.lua
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "init.lua",
  callback = function()
    vim.opt_local.foldmethod = "marker" -- Use markers for init.lua
    vim.opt_local.foldexpr = "" -- Disable foldexpr
    vim.opt_local.foldlevel = 0 -- Start with all folds closed
  end,
  group = mygroup,
  desc = "init.lua folding",
})
-- End Set Fold Markers for init.lua }}}

-- {{{ Unfold at open
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = { "*.py", "*.css", "*.scss", "*.html", "*.qmd", "*.md" },
  command = [[:normal zR]], -- zR-open, zM-close folds
  group = mygroup,
  desc = "Unfold",
})
-- End Unfold at open }}}

-- {{{ Conceal level = 1
-- vim.api.nvim_create_autocmd("BufRead", {
--   pattern = "*.md",
--   command = [[:setlocal conceallevel=1]],
--   group = mygroup,
--   desc = "Conceal level",
-- })
-- End Conceal level = 1 }}}

-- {{{ Autoformat code on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py", "*.json", "*.css", "*.scss" },
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
  group = mygroup,
  desc = "Autoformat code on save",
})
-- End Autoformat code on save }}}

-- {{{ Auto linting
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  pattern = { "*" },
  callback = function()
    require("lint").try_lint()
  end,
})
-- End Auto linting }}}

-- {{{ Sass compilation on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.sass", "*.scss" },
  command = [[:silent exec "!sass --no-source-map %:p %:r.css"]],
  group = mygroup,
  desc = "SASS compilation on save",
})
-- End Sass compilation on save }}}

-- {{{ Shiftwidth setup
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "c", "cpp", "py", "java", "cs" },
--   callback = function()
--     vim.bo.shiftwidth = 4
--   end,
--   group = mygroup,
--   desc = "Set shiftwidth to 4 in these filetypes",
-- })
-- End Shiftwidth setup }}}

-- {{{ Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if vim.fn.line("'\"") >= 1 and vim.fn.line("'\"") <= vim.fn.line("$") and vim.fn.expand("&ft") ~= "commit" then
      vim.cmd('normal! g`"')
    end
  end,
  group = mygroup,
  desc = "Restore cursor position",
})
-- End Restore cursor position }}}

-- {{{ Show cursor line only in active window
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  pattern = "*",
  command = "set cursorline",
  group = mygroup,
  desc = "Show cursorline in active window",
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  pattern = "*",
  command = "set nocursorline",
  group = mygroup,
  desc = "Hide cursorline in inactive window",
})
-- End Show cursor line only in active window }}}

-- {{{ Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd("FocusGained", {
  command = [[:checktime]],
  group = mygroup,
  desc = "Update file when there are changes",
})
-- End Check if we need to reload the file when it changed }}}

-- {{{ Windows to close with "q"
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "toggleterm", "help", "startuptime", "qf", "lspinfo" },
  command = [[nnoremap <buffer><silent> q :close<CR>]],
  group = mygroup,
  desc = "Close windows with Q",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "man",
  command = [[nnoremap <buffer><silent> q :quit<CR>]],
  group = mygroup,
  desc = "Close man pages with Q",
})
-- End Windows to close with "q" }}}

-- {{{ Don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", {
  command = [[set formatoptions-=cro]],
  group = mygroup,
  desc = "Don't auto comment new line",
})
-- End Don't auto comment new line }}}

-- {{{ Open HELP on right side
-- vim.api.nvim_create_autocmd("BufEnter", {
--   command = [[if &buftype == 'help' | wincmd L | endif]],
--   group = mygroup,
--   desc = "Help on right side",
-- })
-- End Open HELP on right side }}}

-- {{{ Open terminal at same location as opened file
vim.api.nvim_create_autocmd("BufEnter", {
  command = [[silent! lcd %:p:h]],
  group = mygroup,
  desc = "Open terminal in same location as opened file",
})
-- End Open terminal at same location as opened file }}}

-- {{{ Terminal options
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.cmd("startinsert!")
  end,
  group = mygroup,
  desc = "Terminal Options",
})
-- End Terminal options }}}

-- {{{ Remove trailling whitespace (medzeru na konci) when SAVE file
vim.api.nvim_create_autocmd("BufWritePre", {
  command = [[%s/\s\+$//e]],
  group = mygroup,
  desc = "Remove tarilling whitespace",
})
-- End Remove trailling whitespace (medzeru na konci) when SAVE file }}}

-- {{{ Resize vim windows when overall window size changes
vim.api.nvim_create_autocmd("VimResized", {
  command = [[wincmd =]],
  group = mygroup,
  desc = "Resize windows to equal",
})
-- End Resize vim windows when overall window size changes }}}

-- {{{ PYTHON
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = [[nnoremap <buffer> <M-p> :w<CR>:terminal python3 "%"<CR>]],
  group = mygroup,
  desc = "Open file in python terminal",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = [[setlocal colorcolumn=80]],
  group = mygroup,
  desc = "Set colorcolumn for python files",
})
-- End PYTHON }}}

-- {{{ Set TYPST filetype - Quarto specific
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  pattern = "*.typ",
  command = "set filetype=typst",
  desc = "Set filetype for typst files",
})
-- End Set TYPST filetype - Quarto specific }}}

-- {{{ Telescope on start
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argv(0) == "" then
      require("telescope.builtin").oldfiles()
    end
  end,
  group = mygroup,
  desc = "Start Telescope on start",
})
-- End Telescope on start }}}

-- End [[ AUTOCOMMANDS ]] }}}

-- {{{ [[ LAZY MANAGER ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- {{{ UI
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "MunifTanjim/nui.nvim" },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },
  -- UI }}}

  -- {{{ Colorscheme

  -- {{{ Kanagawa
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        colors = {
          palette = {
            fujiWhite = "#FEFEFA",
            -- lotusWhite0 = "#d5cea3",
            -- lotusWhite1 = "#dcd5ac",
            -- lotusWhite2 = "#e5ddb0",
            -- lotusWhite3 = "#f2ecbc",
            -- lotusWhite4 = "#e7dba0",
            -- lotusWhite5 = "#e4d794",

            -- lotusWhite0 = "#DCD7BA",
            -- lotusWhite1 = "#DCD7BA",
            -- lotusWhite2 = "#DCD7BA",
            -- lotusWhite3 = "#FEFEFA",
            -- lotusWhite4 = "#EDEBDA",
            -- lotusWhite5 = "#EDEBDA",

            -- https://coolors.co/gradient-palette/fefefa-edebda?number=3
            lotusWhite0 = "#EDEBDA",
            lotusWhite1 = "#EDEBDA",
            lotusWhite2 = "#EDEBDA",
            lotusWhite3 = "#FEFEFA", -- baby powder white shade
            lotusWhite4 = "#F6F5EA",
            lotusWhite5 = "#F6F5EA",
          },
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            -- change cmd popup menu colors
            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_m1 },
            -- PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2, italic = true },
            PmenuSel = { fg = colors.palette.surimiOrange, bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
            FloatBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
            -- change cmp items colors
            CmpItemKindVariable = { fg = colors.palette.crystalBlue, bg = "NONE" },
            CmpItemKindInterface = { fg = colors.palette.crystalBlue, bg = "NONE" },
            CmpItemKindFunction = { fg = colors.palette.oniViolet, bg = "NONE" },
            CmpItemKindMethod = { fg = colors.palette.oniViolet, bg = "NONE" },
            -- borderless telescope
            TelescopeTitle = { fg = theme.ui.special, bold = true },
            TelescopePromptNormal = { bg = theme.ui.bg_p1 },
            TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
            TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
            TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
            TelescopePreviewNormal = { bg = theme.ui.bg_dim },
            TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
          }
        end,
      })
      vim.cmd.colorscheme ("kanagawa")
    end,
  },
  -- Kanagawa }}}

  -- {{{ Adwaita
  {
    "Mofiqul/adwaita.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("adwaita")
    end,
  },
  -- Adwaita }}}

  -- {{{ VsCode
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      local c = require("vscode.colors").get_colors()
      require("vscode").setup({
        -- Enable italic comment
        italic_comments = true,
        -- Override colors (see ./lua/vscode/colors.lua)
        color_overrides = {
          -- vscLineNumber = '#4EFCFE',
        },

        -- Override highlight groups (see ./lua/vscode/theme.lua)
        group_overrides = {
          -- this supports the same val table as vim.api.nvim_set_hl
          -- use colors from this colorscheme by requiring vscode.colors!
          -- Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
        },
      })
      -- vim.cmd.colorscheme("vscode")
    end,
  },
  -- VsCode }}}

  -- Colorscheme }}}

  -- {{{ Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "python",
        "bash",
        "lua",
        "html",
        "css",
        "scss",
        "htmldjango",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
        "yaml",
        "typst",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
    },
  },
  -- }}}

  -- {{{ LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- LSP
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      -- Formatting
      "stevearc/conform.nvim",
      -- Linting
      "mfussenegger/nvim-lint",
      -- Status updates for LSP (optional)
      --{ "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- {{{ LSP Servers
      require("mason").setup()
      local servers = {
        bashls = {
          filetypes = { "zsh", "bash", "sh" },
        },
        cssls = {},
        jsonls = {},
        emmet_ls = {
          filetypes = {
            "html",
            "htmldjango",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less",
            "javascript",
            "typescript",
          },
          init_options = {
            html = {
              options = {
                -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L26
                ["bem.enabled"] = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.stdpath("config") .. "/lua"] = true,
                },
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
        -- pyright = {
        --   settings = {
        --     python = {
        --       analysis = {
        --         autoImportCompletions = true,
        --         typeCheckingMode = "off",
        --         autoSearchPaths = true,
        --         diagnosticMode = "workspace",
        --         useLibraryCodeForTypes = true,
        --       },
        --     },
        --   },
        -- },
        basedpyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        marksman = {
          filetypes = {
            "markdown",
            "quarto",
          },
        },
        tinymist = {
          filetypes = {
            "typst",
          },
        },
      }

      -- Auto install servers
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      -- local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- local on_attach = function(client, bufnr)
      --   -- sem zadat on_attach funkcie doplnkov
      -- end

      require("mason-lspconfig").setup_handlers({
        function(server)
          local server_opts = servers[server] or {}
          --server_opts.capabilities = capabilities
          --server_opts.on_attach = on_attach
          require("lspconfig")[server].setup(server_opts)
        end,
      })
      -- End LSP Servers }}}

      -- {{{ LSP Diagnostic
      -- See :help vim.diagnostic.config()
      vim.diagnostic.config({
        virtual_text = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- See :help sign_define()
      local sign = function(opts)
        vim.fn.sign_define(opts.name, {
          texthl = opts.name,
          text = opts.text,
          numhl = "",
        })
      end

      sign({ name = "DiagnosticSignError", text = "" })
      sign({ name = "DiagnosticSignWarn", text = "" })
      sign({ name = "DiagnosticSignHint", text = "󰌵" })
      sign({ name = "DiagnosticSignInfo", text = "" })

      -- Hover float window configuration
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

      -- Signature help window configuration
      vim.lsp.handlers["textDocument/signatureHelp"] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
      -- End LSP Diagnostic }}}

      -- {{{ LSP Linters/Formaters
      -- Auto install
      require("mason-tool-installer").setup({
        ensure_installed = {
          "beautysh", -- bash formater
          "prettier", -- prettier formatter
          "stylua", -- lua formatter
          "isort", -- python formatter
          "black", -- python formatter
          "shellcheck", -- bash linter
          "pylint", -- python linter
          "flake8", -- python linter
          "eslint_d", -- js linter
          "djlint", -- django linter
          "tree-sitter-cli", -- treesitter latex integration
        },
      })

      -- Formatting
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          bash = { "beautysh" },
          javascript = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          lua = { "stylua" },
          python = { "isort", "black" },
        },
      })

      -- Linting
      local lint = require("lint")

      lint.linters_by_ft = {
        bash = { "shellcheck" },
        javascript = { "eslint_d" },
        python = { "flake8" },
      }
      -- End LSP Linters/Formaters }}}
    end,
  },
  -- END LSP }}}

  -- {{{ Autocompletition
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      -- codeium
      -- "jcdickinson/codeium.nvim",
      -- sorting
      "lukas-reineke/cmp-under-comparator",
      -- snippets
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      -- icons
      "onsails/lspkind.nvim",
      -- bootstrap
      "Jezda1337/cmp_bootstrap",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      -- luasnip nacita 'snippets' z friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })

      -- bootstrap
      require("bootstrap-cmp.config"):setup({
        file_types = { "jinja.html", "html" },
        url = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
      })

      -- codeium
      -- after install run ":Codeium Auth" and insert tokken from web
      -- require("codeium").setup({})

      cmp.setup({
        -- enabled = function()
        --   -- disable completion in comments
        --   if require"cmp.config.context".in_treesitter_capture("comment")==true
        -- or require"cmp.config.context".in_syntax_group("Comment") then
        --     return false
        --   else
        --     return true
        --   end
        -- end,
        enabled = true,
        snippet = {
          expand = function(args)
            -- for luasnip
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- ak to odkomentujem, tak mi nebude robit selkciu v ponuke
          -- ["<Up>"] = cmp.config.disable,
          -- ["<Down>"] = cmp.config.disable,
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
          -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
          ["<C-y>"] = cmp.config.disable,
          -- Accept currently selected item. Set `select` to `false`
          -- to only confirm explicitly selected items.
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
              -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
              -- they way you will only jump inside the snippet region
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            ellipsis_char = "...",
            -- symbol_map = { Codeium = "" },
            menu = {
              buffer = "[buf]",
              -- codeium = "[cod]",
              luasnip = "[snip]",
              nvim_lsp = "[lsp]",
              bootstrap = "[boot]",
              -- otter = "[otter]",
            },
          }),
        },
        sources = {
          { name = "buffer" },
          { name = "path" },
          -- { name = "codeium" },
          { name = "luasnip" },
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          -- { name = "bootstrap" },
          -- { name = "otter" },
        },
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            require("cmp-under-comparator").under,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp.config.window.bordered({
            -- farby pre winhighlight su definovane v kanagawa teme
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
            scrollbar = true,
          }),
          documentation = cmp.config.window.bordered({
            -- farby pre winhighlight su definovane v kanagawa teme
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          }),
        },
        view = {
          entries = "custom",
        },
        experimental = {
          -- doplna text pri pisani, trochu otravne
          -- ghost_text = true,
          -- ghost_text = {hlgroup = "Comment"}
        },
      })
    end,
  },
  -- Autocompletition }}}

  -- {{{ Statusline
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      -- Define a custom theme
      local function vscode_theme()
        local colors = {
          red = "#e74d23", orange = "#FF8800", yellow = "#ffc233", green = "#427b00",
          blue = "#007ACD", purple = "#67217A", black = "#16161D", white = "#FFFFFF",
          grey = "#727169"
        }
        return {
          normal = { a = { bg = colors.purple, fg = colors.white } },
          insert = { a = { bg = colors.blue, fg = colors.white } },
          visual = { a = { bg = colors.green, fg = colors.white } },
          replace = { a = { bg = colors.orange, fg = colors.white } },
          command = { a = { bg = colors.red, fg = colors.white } },
          inactive = { a = { bg = colors.black, fg = colors.grey } },
        }
      end

      -- LSP server icon
      local function lsp_server_icon()
        local buf_ft = vim.bo.filetype
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if client.supports_method("textDocument/documentSymbol") then
            local supported_filetypes = client.config.filetypes or {}
            if vim.tbl_contains(supported_filetypes, buf_ft) then
              return ""
            end
          end
        end
        return ""
      end

      -- Python environment
      local function python_env()
        local venv = require('swenv.api').get_current_venv()
        if venv and venv.name then
          return venv.name:match("([^/]+)$") or ""
        end
        return ""
      end

      -- Buffer counts
      local function buffer_counts()
        local loaded_buffers = #vim.tbl_filter(function(buf)
          return vim.fn.buflisted(buf) ~= 0
        end, vim.api.nvim_list_bufs())
        local modified_buffers = #vim.tbl_filter(function(buf)
          return vim.bo[buf].modified
        end, vim.api.nvim_list_bufs())
        return string.format("󰈔 [%d:%d+]", loaded_buffers, modified_buffers)
      end

      -- Macro recording status
      local function macro_recording()
        local recording = vim.fn.reg_recording()
        return recording ~= "" and "󰻃" .. recording or ""
      end

      -- Lualine setup
      require('lualine').setup({
        options = {
          section_separators = '',
          component_separators = '',
          disabled_filetypes = { statusline = { "alpha", "TelescopePrompt" } },
          theme = vscode_theme(),
        },
        sections = {
          lualine_a = {
            { "filetype", colored = false, icon_only = true },
            { "filename", path = 4, symbols = { modified = "[+]", readonly = "[-]" } },
            { buffer_counts },
          },
          lualine_b = { { macro_recording } },
          lualine_c = { },
          lualine_x = {},
          -- lualine_y = { { python_env, icon = "" } },
          lualine_y = { { python_env, icon = "" } },
          lualine_z = {
            { lsp_server_icon },
            { "diagnostics", colored = false, symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " } },
            { "%l:%c %p%%/%L" },
          },
        },
        tabline = {
          lualine_b = {
            { "buffers",
              buffers_color = {
                active = { fg = "#FF8800" },
              },
              filetype_names = { alpha = '', TelescopePrompt = '', lazy = '', fzf = '' } },
          },
        },
      })

      -- Auto-refresh for macro recording status
      vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
        callback = function()
          local delay = vim.fn.reg_recording() == "" and 50 or 0
          vim.defer_fn(function() require('lualine').refresh({ place = { "statusline" } }) end, delay)
        end,
      })

    end,
  },
  -- Statusline }}}

  -- {{{ File Manager
  { "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    opts = {
      close_if_last_window = true,
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
      },
      window = {
        position = "left",
        width = 30,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ["<cr>"] = "open",
          ["<RIGHT>"] = "open",
          ["C"] = "close_node",
          ["<LEFT>"] = "close_node",
          ["<c-h>"] = "toggle_hidden",
          ["<bs>"] = "navigate_up",
          ["<c-LEFT>"] = "navigate_up",
        },
      },
    },
  },
  -- File Manger }}}

  -- {{{ Telescope
  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        pickers = {
          colorscheme = {
            enable_preview = true,
          },
        },
        defaults = {
          extensions = {
          },
        },
      })
      -- require("telescope").load_extension("file_browser")
    end,
  },
  -- Telescope }}}

  -- {{{ Mini.nvim collection
  {
    "echasnovski/mini.nvim",
    config = function()

      require('mini.comment').setup({
        mappings = {
          comment = '',
          comment_line = '<C-/>',
          comment_visual = '<C-/>',
          textobject = '',
        },
      })
      require('mini.notify').setup()
      require('mini.surround').setup()
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.pairs').setup()
    end,
  },
  -- Mini.nvim collection }}}

  -- {{{ Python

  -- {{{ Swenv - change python environments
  {
    "AckslD/swenv.nvim",
    config = function()
      local venvs_path
      if os_type == "windows" then
        venvs_path = vim.fn.expand("C:/Users/" .. os_username .. "/python-venv") -- Path for Windows
      elseif os_type == "linux" then
        venvs_path = vim.fn.expand("~/.py-venv")
      elseif os_type == "wsl" then
        venvs_path = vim.fn.expand("/mnt/c/Users/" .. os_username .. "/python-venv") -- Path for WSL
      else
        venvs_path = vim.fn.expand("~/.py-venv") -- Default fallback
      end
      require("swenv").setup({
        get_venvs = function(venvs_path)
          return require("swenv.api").get_venvs(venvs_path)
        end,
        -- venvs_path = vim.fn.expand("~/.py-venv"), -- zadat cestu k envs
        venvs_path = venvs_path,
        post_set_venv = function()
          vim.cmd(":LspRestart<cr>")
        end,
      })
    end,
  },
  -- Swenv - change python environments }}}

  -- {{{ Jinja template syntax
  { "lepture/vim-jinja", event = { "BufReadPre", "BufNewFile" } },
  -- Jinja template syntax }}}

  -- Python }}}

  -- {{{ Notes
  -- {{{ Obsidian
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "Obsidian",
          path = vim.fn.expand("$OneDrive_DIR") .. "Dokumenty/zPoznamky/Obsidian/",
        },
      },
      notes_subdir = "inbox",
      new_notes_location = "notes_subdir",
      disable_frontmatter = true,
      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M:%S",
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
    },
  },
  -- Obsidian }}}

  -- {{{ Markdown
  {
    'MeanderingProgrammer/markdown.nvim',
    name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('render-markdown').setup({})
    end,
  },
  -- Markdown }}}

  -- {{{ Markdown highlight headings and code blocks
  {
    "lukas-reineke/headlines.nvim",
    enabled = true,
    lazy = true,
    ft = { "markdown", "quarto" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("headlines").setup({
        quarto = {
          query = vim.treesitter.query.parse(
            "markdown",
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = "CodeBlock",
          treesitter_language = "markdown",
        },
        markdown = {
          query = vim.treesitter.query.parse(
            "markdown",
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = "CodeBlock",
        },
      })
    end,
  },
  -- Markdown highlight headings and code blocks }}}

  -- {{{ Vim-table-mode
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "quarto" },
  },
  -- Vim-table-mode }}}

  -- Notes }}}

  -- {{{ Quarto, Jupyterlab

  -- {{{ Quarto
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dev = false,
    opts = {
      lspFeatures = {
        languages = { "python", "bash", "lua", "html", "javascript" },
      },
      -- codeRunner = {
      --   enabled = true,
      --   default_method = 'slime',
      -- },
    },
    dependencies = {
      {
        -- for language features in code cells
        -- added as a nvim-cmp source
        "jmbuhr/otter.nvim",
        dev = false,
        opts = {},
      },
      {
        -- Slime
        -- send code from python/r/qmd documets to a terminal or REPL
        -- like ipython, R, bash
        -- "jpalardy/vim-slime"
      },
    },
  },
  -- Quarto }}}

  -- {{{ Molten
  {
    "benlubas/molten-nvim",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_virt_text_output = true
      vim.g.molten_wrap_output = true
      vim.g.molten_auto_open_output = false
    end,
  },
  -- Molten }}}

  -- {{{ Image.nvim
  {
    '3rd/image.nvim',
    enabled = true,
    dev = false,
    ft = { 'markdown', 'quarto', 'vimwiki' },
    dependencies = {
      {
        'vhyrro/luarocks.nvim',
        priority = 1001, -- this plugin needs to run before anything else
        opts = {
          rocks = { 'magick' },
        },
      },
    },
    config = function()
      -- Requirements
      -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
      -- check for dependencies with `:checkhealth kickstart`
      -- needs:
      -- sudo apt install imagemagick
      -- sudo apt install libmagickwand-dev
      -- sudo apt install liblua5.1-0-dev
      -- sudo apt installl luajit

      local image = require 'image'
      image.setup {
        backend = 'kitty',
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            filetypes = { 'markdown', 'vimwiki', 'quarto' },
          },
        },
        editor_only_render_when_focused = false,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview' },
        max_width = 100, --nil,
        max_height = 12, --nil,
        max_height_window_percentage = math.huge, --30,
        max_width_window_percentage = math.huge, --nil,
        kitty_method = 'normal',
      }
    end,
  },
  -- Image.nvim }}}

  -- Quarto, Jupyterlab }}}

  -- {{{ Mix

  -- {{{ Colorizer
  {
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup()
    end,
  },
  -- Colorizer }}}

  -- {{{ Maximize window
  { "szw/vim-maximizer" },
  -- Maximize window }}}

  -- Mix }}}

})
-- }}}
