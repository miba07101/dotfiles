--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--

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
opt.matchpairs = { "(:)", "{:}", "[:]", "<:>" }
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
-- opt.background = "light"
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

-- {{{ Save, Quit
map({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "save" })
map({ "n", "i" }, "<C-w>", "<cmd>wq<cr>", { desc = "save-quit" })
map({ "n", "i" }, "<C-q>", "<cmd>q!<cr>", { desc = "quit" })
-- map("n", "<leader>x", "<cmd>w<cr><cmd>luafile %<cr><esc>", { desc = "Reload Lua" })
-- }}}

-- {{{ File System Commands
map("n", "<leader>k", ":!touch<space>", { desc = "Create file" })
-- map("n", "<leader>dc", "<cmd>!mkdir<space>", { desc = "Create directory" })
-- map("n", "<leader>mv", "<cmd>!mv<space>%<space>", { desc = "Move" })
-- }}}

-- {{{ Windows
map("n", "<leader>wv", "<C-w>v", { desc = "vertical" })
map("n", "<leader>wh", "<C-w>s", { desc = "horizontal" })
map("n", "<leader>we", "<C-W>=", { desc = "equal" })
map("n", "<leader>wx", "<cmd>close<cr>", { desc = "close" })
map("n", "<leader>wlh", "<cmd>windo wincmd K<cr>", { desc = "horizontal layout" })
map("n", "<leader>wlv", "<cmd>windo wincmd H<cr>", { desc = "vertical layout" })

map("n", "<C-Up>", "<C-w>k", { desc = "Go UP" })
map("n", "<C-Down>", "<C-w>j", { desc = "Go DOWN" })
map("n", "<C-Left>", "<C-w>h", { desc = "Go LEFT" })
map("n", "<C-Right>", "<C-w>l", { desc = "Go RIGHT" })
map("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "Resize UP" })
map("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "Resize DOWN" })
map("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Resize LEFT" })
map("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize RIGHT" })
map("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize RIGHT" })
-- }}}

-- {{{ Buffers
map("n", "<A-Right>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<A-Left>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<A-UP>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })
map("n", "<A-Down>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })
-- }}}

-- {{{ Indenting
map("v", "<", "<gv", { desc = "Unindent line" })
map("v", ">", ">gv", { desc = "Indent line" })
-- }}}

-- {{{ Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text DOWN" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text UP" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move text DOWN" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move text UP" })
map("v", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text UP" })
map("v", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text DOWN" })
map("x", "<A-j>", "<cmd>move '>+1<cr>gv-gv", { desc = "Move text UP" })
map("x", "<A-k>", "<cmd>move '<-2<cr>gv-gv", { desc = "Move text DOWN" })
-- }}}

-- {{{ Better Paste
map("v", "p", '"_dP', { desc = "Paste no yank" })
map("n", "x", '"_x', { desc = "Delete character no yank" })
-- }}}

-- {{{ Vertical move and center
map("n", "<C-d>", "<C-d>zz", { desc = "up and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "down and center" })
-- }}}

-- {{{ Increment/decrement numbers
map("n", "<leader>+", "<C-a>", { desc = "increment" })
map("n", "<leader>-", "<C-x>", { desc = "decrement" })
-- }}}

-- {{{ Replace word under cursor
map("n", "<leader>r", "*``cgn", { desc = "replace word" })
-- }}}

-- {{{ Explicitly yank to system clipboard (highlighted and entire row)
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "yank to clipboard" })
-- }}}

-- {{{ Close floating window with ESC
local function close_floating()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end
map("n", "<Esc>", function()
  close_floating()
end, { desc = "Close with ESC" })
-- }}}

-- {{{ Terminal
map("n", "<C-`>", "<cmd>horizontal terminal<cr>", { desc = "terminal" })
map("t", "<C-`>", "exit<cr>", { desc = "exit terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- }}}

-- {{{ Mix
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "No highlight" })
map("n", "<A-a>", "<esc>ggVG<cr>", { desc = "Select all text" })
map("n", "<BS>", "X", { desc = "TAB as X in NORMAL mode" })
map("n", "<A-v>", "<C-q>", { desc = "Visual block mode" })
map("n", "<leader>rw", ":%s/<c-r><c-w>//g<left><left>", { desc = "Replace word" })
-- }}}

-- {{{ NeoVim
map("n", "<leader>vn", "<cmd>set relativenumber!<cr>", { desc = "Numbers toggle" })
map("n", "<leader>vl", "<cmd>IBLToggle<cr>", { desc = "Blankline toggle" })
map("n", "<leader>vh", "<cmd>HighlightColors Toggle<cr>", { desc = "Highlight-colors toggle" })
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
-- }}}

-- {{{ File Manager
map("n", "<leader>e", "<cmd>Neotree toggle %:p:h<cr>", { desc = "File manager" })
-- map("n", "<leader>eb", "<cmd>Neotree buffers<cr>", { desc = "Buffers manager" })
-- }}}

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
-- }}}

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
-- }}}

-- {{{ Python
map("n", "<leader>pe", "<cmd>lua require('swenv.api').pick_venv()<cr>", { desc = "pick venvs" })
-- }}}

-- {{{ Lazy
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })
-- }}}

-- {{{ Telescope
map("n", "<leader>fx", "<cmd>Telescope<cr>", { desc = "telescope" })
-- map("n", "<leader>fe", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", { desc = "file browser" })
-- map("n", "<leader>fn", "<cmd>Telescope notify<cr>", { desc = "notifications" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "files" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<cr>", { desc = "words" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "recent files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "buffers" })
map("n", "<leader>fc", "<cmd>Telescope colorscheme<cr>", { desc = "colorscheme" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "diagnostics" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "tags" })
-- }}}

-- {{{ Quarto
map("n", "<leader>qa", "<cmd>QuartoActivate<cr>", { desc = "activate" })
map("n", "<leader>qp", "<cmd>lua require'quarto'.quartoPreview()<cr>", { desc = "preview" })
map("n", "<leader>qq", "<cmd>lua require'quarto'.quartoClosePreview()<cr>", { desc = "quit" })
map("n", "<leader>qh", "<cmd>QuartoHelp<cr>", { desc = "help" })
-- vim-table-mode
map("n", "<leader>qt", "<cmd>TableModeToggle<cr><cr>", { desc = "table mode" })
-- align columns in markdown table
-- https://heitorpb.github.io/bla/format-tables-in-vim/
map("v", "<leader>qt", ":!column -t -s '|' -o '|'<CR><CR>", { desc = "align table" })
-- }}}

-- {{{ Otter (for quarto completion)
map("n", "<leader>qod", "<cmd>lua require('otter').ask_definition()<cr>", { desc = "definition" })
map("n", "<leader>qoh", "<cmd>lua require('otter').ask_hover()<cr>", { desc = "hover" })
map("n", "<leader>qor", "<cmd>lua require('otter').ask_references()<cr>", { desc = "references" })
map("n", "<leader>qon", "<cmd>lua require('otter').ask_rename()<cr>", { desc = "rename" })
map("n", "<leader>qof", "<cmd>lua require('otter').ask_format()<cr>", { desc = "format" })
-- }}}

-- {{{ Obsidian
map("n", "<leader>ol", "<cmd>lua require('obsidian').util.gf_passthrough()<cr>", { desc = "wiki links" })
map("n", "<leader>ob", "<cmd>lua require('obsidian').util.toggle_checkbox()<cr>", { desc = "toggle checkbox" })
map("n", "<leader>oo", ":cd ${OneDrive_DIR}/Dokumenty/zPoznamky/Obsidian/<cr>", { desc = "open vault" })
map(
  "n",
  "<leader>ot",
  ":ObsidianTemplate t-nvim-note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>",
  { desc = "note teplate" }
)
-- map("n", "<leader>of", ":s/\\(# \\)[^-]*_/\\1/ | s/-/ /g<cr>", { desc = "strip date - must have cursor on title" })
map(
  "n",
  "<leader>os",
  "<cmd>lua require('telescope.builtin').find_files({ search_dirs = { vim.fn.expand('$OneDrive_DIR') .. '/Dokumenty/zPoznamky/Obsidian/' } })<cr>",
  { desc = "search in vault" }
)
map(
  "n",
  "<leader>ow",
  "<cmd>lua require('telescope.builtin').live_grep({ search_dirs = { vim.fn.expand('$OneDrive_DIR') .. '/Dokumenty/zPoznamky/Obsidian/' } })<cr>",
  { desc = "search in vault" }
)
-- map("n", "<leader>os", ":Telescope find_files search_dirs={\"/home/vimi/OneDrive/Dokumenty/zPoznamky/Obsidian/\"}<cr>", { desc = "search in vault" })
-- map("n", "<leader>ow", ":Telescope live_grep search_dirs={\"/home/vimi/OneDrive/Dokumenty/zPoznamky/Obsidian/\"}<cr>", { desc = "search in notes" })
-- for review workflow
map("n", "<leader>od", ":!rm '%:p'<cr>:bd<cr>", { desc = "delete note" })
-- }}}

-- {{{ Markdown
map("n", "<leader>mp", "<cmd>RenderMarkdownToggle<cr><cr>", { desc = "markdown preview" })
-- )))

-- End [[ KEYMAPS ]] }}}

-- [[ KEYMAPS ]] }}}

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

  -- {{{ [ UI ]
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "MunifTanjim/nui.nvim" },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },
  -- }}}

  -- {{{ [ Colorscheme ]

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
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  -- }}}

  -- {{{ Adwaita
  {
    "Mofiqul/adwaita.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("adwaita")
    end,
  },
  -- }}}

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

  -- }}}

  -- {{{ [ Treesitter ]
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

  -- {{{ [ LSP ]
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

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      -- local capabilities = require("cmp_nvim_lsp").default_capabilities()
      -- local on_attach = function(client, bufnr)
      --   -- sem zadat on_attach funkcie doplnkov
      -- end

      require("mason-lspconfig").setup_handlers({
        function(server)
          local server_opts = servers[server] or {}
          -- server_opts.capabilities = capabilities
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
  -- }}}

  -- {{{ [ Autocompletition ]

  -- -- {{{ supermaven - ai autocompletition
  -- {
  --   "supermaven-inc/supermaven-nvim",
  --   config = function()
  --     require("supermaven-nvim").setup({
  --       keymaps = {
  --         accept_suggestion = "<Tab>",
  --         clear_suggestion = "<A-n>",
  --         accept_word = "<A-m>",
  --       },
  --       ignore_filetypes = { cpp = true }, -- or { "cpp", }
  --       color = {
  --         suggestion_color = "#717C7C",
  --         cterm = 244,
  --       },
  --       log_level = "info", -- set to "off" to disable logging completely
  --       disable_inline_completion = true, -- disables inline completion for use with cmp
  --       disable_keymaps = false, -- disables built in keymaps for more manual control
  --     })
  --   end,
  -- },
  -- -- }}}

  -- -- {{{ cmp
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {
  --     "hrsh7th/cmp-buffer",
  --     "hrsh7th/cmp-path",
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-nvim-lsp-signature-help",
  --     -- codeium
  --     -- "jcdickinson/codeium.nvim",
  --     -- sorting
  --     "lukas-reineke/cmp-under-comparator",
  --     -- snippets
  --     "L3MON4D3/LuaSnip",
  --     "saadparwaiz1/cmp_luasnip",
  --     "rafamadriz/friendly-snippets",
  --     -- icons
  --     "onsails/lspkind.nvim",
  --     -- bootstrap
  --     "Jezda1337/cmp_bootstrap",
  --   },
  --   config = function()
  --     local cmp = require("cmp")
  --     local luasnip = require("luasnip")
  --     local lspkind = require("lspkind")
  --
  --     local has_words_before = function()
  --       unpack = unpack or table.unpack
  --       local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  --       return col ~= 0
  --         and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  --     end
  --
  --     -- luasnip nacita 'snippets' z friendly-snippets
  --     require("luasnip.loaders.from_vscode").lazy_load()
  --     require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
  --
  --     -- bootstrap
  --     require("bootstrap-cmp.config"):setup({
  --       file_types = { "jinja.html", "html" },
  --       url = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
  --     })
  --
  --     -- codeium
  --     -- after install run ":Codeium Auth" and insert tokken from web
  --     -- require("codeium").setup({})
  --
  --     cmp.setup({
  --       -- enabled = function()
  --       --   -- disable completion in comments
  --       --   if require"cmp.config.context".in_treesitter_capture("comment")==true
  --       -- or require"cmp.config.context".in_syntax_group("Comment") then
  --       --     return false
  --       --   else
  --       --     return true
  --       --   end
  --       -- end,
  --       enabled = true,
  --       snippet = {
  --         expand = function(args)
  --           -- for luasnip
  --           require("luasnip").lsp_expand(args.body)
  --         end,
  --       },
  --       mapping = cmp.mapping.preset.insert({
  --         -- ak to odkomentujem, tak mi nebude robit selkciu v ponuke
  --         -- ["<Up>"] = cmp.config.disable,
  --         -- ["<Down>"] = cmp.config.disable,
  --         ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
  --         ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
  --         ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
  --         ["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
  --         -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
  --         ["<C-y>"] = cmp.config.disable,
  --         -- Accept currently selected item. Set `select` to `false`
  --         -- to only confirm explicitly selected items.
  --         ["<CR>"] = cmp.mapping.confirm({ select = false }),
  --         ["<Tab>"] = cmp.mapping(function(fallback)
  --           if cmp.visible() then
  --             cmp.select_next_item()
  --             -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
  --             -- they way you will only jump inside the snippet region
  --           elseif luasnip.expand_or_jumpable() then
  --             luasnip.expand_or_jump()
  --           elseif has_words_before() then
  --             cmp.complete()
  --           else
  --             fallback()
  --           end
  --         end, { "i", "s" }),
  --         ["<S-Tab>"] = cmp.mapping(function(fallback)
  --           if cmp.visible() then
  --             cmp.select_prev_item()
  --           elseif luasnip.jumpable(-1) then
  --             luasnip.jump(-1)
  --           else
  --             fallback()
  --           end
  --         end, { "i", "s" }),
  --       }),
  --       formatting = {
  --         format = function(entry,item)
  --           local color_item = require("nvim-highlight-colors").format(entry, { kind = item.kind })
  --           item = lspkind.cmp_format({
  --             mode = "symbol_text",
  --             ellipsis_char = "...",
  --             -- symbol_map = { Codeium = "" },
  --             symbol_map = { Supermaven = "" },
  --             menu = {
  --               buffer = "[buf]",
  --               -- codeium = "[cod]",
  --               luasnip = "[snip]",
  --               nvim_lsp = "[lsp]",
  --               bootstrap = "[boot]",
  --               -- otter = "[otter]",
  --             },
  --           })(entry, item)
  --           if color_item.abbr_hl_group then
  --             item.kind_hl_group = color_item.abbr_hl_group
  --             item.kind = color_item.abbr
  --           end
  --           return item
  --         end
  --       },
  --       sources = {
  --         { name = "buffer" },
  --         { name = "path" },
  --         -- { name = "codeium" },
  --         { name = "supermaven" },
  --         { name = "luasnip" },
  --         { name = "nvim_lsp" },
  --         { name = "nvim_lsp_signature_help" },
  --         -- { name = "bootstrap" },
  --         -- { name = "otter" },
  --       },
  --       sorting = {
  --         comparators = {
  --           cmp.config.compare.offset,
  --           cmp.config.compare.exact,
  --           cmp.config.compare.score,
  --           require("cmp-under-comparator").under,
  --           cmp.config.compare.kind,
  --           cmp.config.compare.sort_text,
  --           cmp.config.compare.length,
  --           cmp.config.compare.order,
  --         },
  --       },
  --       confirm_opts = {
  --         behavior = cmp.ConfirmBehavior.Replace,
  --         select = false,
  --       },
  --       window = {
  --         completion = cmp.config.window.bordered({
  --           -- farby pre winhighlight su definovane v kanagawa teme
  --           winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
  --           scrollbar = true,
  --         }),
  --         documentation = cmp.config.window.bordered({
  --           -- farby pre winhighlight su definovane v kanagawa teme
  --           winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
  --         }),
  --       },
  --       view = {
  --         entries = "custom",
  --       },
  --       experimental = {
  --         -- doplna text pri pisani, trochu otravne
  --         -- ghost_text = true,
  --         -- ghost_text = {hlgroup = "Comment"}
  --       },
  --     })
  --   end,
  -- },
  -- -- }}}

  -- {{{ blink
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "v0.*",
    opts = {
      keymap = {
        preset = "super-tab",
        ["<CR>"] = { "accept", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "normal",
      },
      completion = {
        menu = {
          draw = {
            columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'source_name', 'kind', gap = 1 }},
          }
        }
      },
      signature = { enabled = true },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
    opts_extend = { "sources.default" }
  },
  -- }}}

  -- }}}

  -- {{{ [ Statusline ]
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      -- Define a custom theme
      local function vscode_theme()
        local colors = {
          red = "#e74d23",
          orange = "#FF8800",
          yellow = "#ffc233",
          green = "#427b00",
          blue = "#007ACD",
          purple = "#67217A",
          black = "#16161D",
          white = "#FFFFFF",
          grey = "#727169",
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
        local venv = require("swenv.api").get_current_venv()
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
        return recording ~= "" and "󰻃 " .. recording or ""
      end

      -- Lualine setup
      require("lualine").setup({
        options = {
          section_separators = "",
          component_separators = "",
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
          lualine_c = {},
          lualine_x = {},
          -- lualine_y = { { python_env, icon = "" } },
          lualine_y = { { python_env, icon = "" } },
          lualine_z = {
            { lsp_server_icon },
            {
              "diagnostics",
              colored = false,
              symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
            },
            { "%l:%c %p%%/%L" },
          },
        },
        tabline = {
          lualine_b = {
            {
              "buffers",
              buffers_color = {
                active = { fg = "#FF8800" },
              },
              filetype_names = { alpha = "", TelescopePrompt = "", lazy = "", fzf = "" },
            },
          },
        },
      })

      -- Auto-refresh for macro recording status
      vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
        callback = function()
          local delay = vim.fn.reg_recording() == "" and 50 or 0
          vim.defer_fn(function()
            require("lualine").refresh({ place = { "statusline" } })
          end, delay)
        end,
      })
    end,
  },
  -- }}}

  -- {{{ [ File Manager ]
  {
    "nvim-neo-tree/neo-tree.nvim",
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
  -- }}}

  -- {{{ [ Telescope ]
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
          extensions = {},
        },
      })
      -- require("telescope").load_extension("file_browser")
    end,
  },
  -- }}}

  -- {{{ [ Mini.nvim collection ]
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.comment").setup({
        mappings = {
          comment = "",
          comment_line = "<C-/>",
          comment_visual = "<C-/>",
          textobject = "",
        },
      })
      require("mini.notify").setup()
      require("mini.surround").setup()
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.pairs").setup()

      local miniclue = require("mini.clue")
      miniclue.setup({
        window = {
          -- Floating window config
          config = {},

          -- Delay before showing clue window
          delay = 500,

          -- Keys to scroll inside the clue window
          scroll_down = "<C-d>",
          scroll_up = "<C-u>",
        },
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
          { mode = "n", keys = "<Leader>d", desc = "+Diagnostic" },
          { mode = "n", keys = "<Leader>f", desc = "+Telescope" },
          { mode = "n", keys = "<Leader>l", desc = "+Lsp" },
          { mode = "n", keys = "<Leader>o", desc = "+Obsidian" },
          { mode = "n", keys = "<Leader>p", desc = "+Python" },
          { mode = "n", keys = "<Leader>q", desc = "+Quarto" },
          { mode = "n", keys = "<Leader>qo", desc = "+Otter" },
          { mode = "n", keys = "<Leader>v", desc = "+Vim/Neovim" },
          { mode = "n", keys = "<Leader>w", desc = "+Window" },
          { mode = "n", keys = "<Leader>wl", desc = "+Layout" },
          -- moje skratky - visual mode
          { mode = "v", keys = "<Leader>q", desc = "+Quarto" },
        },
      })
    end,
  },
  -- }}}

  -- {{{ [ Python ]

  -- {{{ Swenv - change python environments
  {
    "AckslD/swenv.nvim",
    event = "FileType python",
    opts = {
      get_venvs = function(venvs_path)
        return require("swenv.api").get_venvs(venvs_path)
      end,
      venvs_path = vim.fn.expand("$VENV_HOME"), -- zadat cestu k envs skrz premennu definovanu v .zshrc, resp. powershell
      post_set_venv = function()
        vim.cmd(":LspRestart<cr>")
      end,
    }
  },
  -- }}}

  -- {{{ Jinja template syntax
  { "lepture/vim-jinja", event = "VeryLazy" },
  -- }}}

  -- }}}

  -- {{{ [ Notes ]
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
  -- }}}

  -- {{{ Markdown
  {
    "MeanderingProgrammer/markdown.nvim",
    lazy = true,
    ft = "markdown",
    name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("render-markdown").setup({})
    end,
  },
  -- }}}

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
  -- }}}

  -- {{{ Vim-table-mode
  {
    "dhruvasagar/vim-table-mode",
    lazy = true,
    ft = { "markdown", "quarto" },
  },
  -- }}}

  -- }}}

  -- {{{ [ Quarto, Jupyterlab ]

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
  -- }}}

  -- {{{ Molten
  (function()
    if os_type == "linux" then
      return {
        "benlubas/molten-nvim",
        ft = { "quarto" },
        dependencies = { "3rd/image.nvim" },
        init = function()
          vim.g.molten_image_provider = "image.nvim"
          vim.g.molten_output_win_max_height = 20
          vim.g.molten_virt_text_output = true
          vim.g.molten_wrap_output = true
          vim.g.molten_auto_open_output = false
        end,
      }
    end
  end)(),
  -- }}}

  -- {{{ Image.nvim
  (function()
    if os_type == "linux" then
      return {
        "3rd/image.nvim",
        enabled = true,
        dev = false,
        ft = { "markdown", "quarto", "vimwiki" },
        dependencies = {
          {
            "vhyrro/luarocks.nvim",
            priority = 1001, -- this plugin needs to run before anything else
            opts = {
              rocks = { "magick" },
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

          local image = require("image")
          image.setup({
            backend = "kitty",
            integrations = {
              markdown = {
                enabled = true,
                only_render_image_at_cursor = true,
                filetypes = { "markdown", "vimwiki", "quarto" },
              },
            },
            editor_only_render_when_focused = false,
            window_overlap_clear_enabled = true,
            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "scrollview" },
            max_width = 100, --nil,
            max_height = 12, --nil,
            max_height_window_percentage = math.huge, --30,
            max_width_window_percentage = math.huge, --nil,
            kitty_method = "normal",
          })
        end,
      }
    end
  end)(),
  -- }}}

  -- }}}

  -- {{{ [ Mix ]

  -- {{{ Colorizer
  {
    -- "norcalli/nvim-colorizer.lua",
    -- event = { "BufReadPre", "BufNewFile" },
    -- config = function()
    --   require("colorizer").setup()
    -- end,
  },
  -- }}}

  -- {{{ Maximize window
  { "szw/vim-maximizer" },
  -- }}}

  -- {{{ Nvim-highlight-colors
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  -- }}}

  -- }}}
})
-- }}}

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
