--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--

-- {{{ [[ DETECT OS ]]
function _G.DetectOsType()-- {{{
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
end-- }}}

local os_type = DetectOsType()
local os_username = os.getenv("USERNAME") or os.getenv("USER")
local py_venvs_path = os.getenv("VENV_HOME")
local onedrive_path = os.getenv("OneDrive_DIR")

function _G.PythonInterpreter()-- {{{
  -- Get the path of the active virtual environment
  local venv = os.getenv("VIRTUAL_ENV")
  -- Get the current venv from swenv.nvim or fallback to default Python
  -- local venv = require("swenv.api").get_current_venv()
  -- print(vim.inspect(venv.path))
  if venv then
    if os_type == "windows" then
      return venv .. "\\Scripts\\python.exe" -- For Windows
    else
      return venv .. "/bin/python" -- For Linux/macOS
    end
  else
    if os_type == "windows" then
      return "python" -- For Windows
    else
      return "python3" -- For Linux/macOS
    end
  end
end-- }}}

function _G.ObsidianPath()-- {{{
  return os_username == "mech" and "~\\Sync\\Obsidian/"
    or vim.fn.expand(onedrive_path .. "Dokumenty/zPoznamky/Obsidian/")
end-- }}}

function _G.ObsidianNewNote(use_template, template, folder)-- {{{
  local obsidian_path = ObsidianPath()
  local note_name = vim.fn.input("Enter note name without .md: ")
  if note_name == "" then return print("Note name cannot be empty!") end

  local new_note_path = string.format("%s%s/%s.md", obsidian_path, folder or "inbox", note_name)
  vim.cmd("edit " .. new_note_path)

  if use_template then
    local templates = { basic = "t-nvim-note.md", person = "t-person.md" }
    vim.cmd(templates[template] and "ObsidianTemplate " .. templates[template] or "echo 'Invalid template name'")
  end
end-- }}}

-- }}}

-- {{{ [[ OPTIONS ]]
local opt = vim.opt
local g = vim.g

-- {{{ File
opt.backup = false -- create a backup file
opt.clipboard = "unnamedplus" -- system clipboard
-- opt.concealcursor = "" -- conceal cursor disable
-- opt.conceallevel = 1 -- conceal level disable
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
  -- opt.shell = "pwsh.exe"
  -- opt.shellcmdflag = "-NoLogo"
  -- opt.shellquote = ""
  -- opt.shellxquote = ""
  opt.shell = "pwsh.exe"
  opt.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;$PSStyle.Formatting.Error = '';$PSStyle.Formatting.ErrorAccent = '';$PSStyle.Formatting.Warning = '';$PSStyle.OutputRendering = 'PlainText';"
  opt.shellredir = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
  opt.shellpipe = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
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

-- }}}

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
map({ "n", "v", "i", "x" }, "<C-s>", "<cmd>w<cr>", { desc = "save" })
map({ "n", "v", "i", "x" }, "<C-w>", "<cmd>wq<cr>", { desc = "save-quit" })
map({ "n", "v", "i", "x" }, "<C-q>", "<cmd>q!<cr>", { desc = "quit" })
-- map("n", "<leader>x", "<cmd>w<cr><cmd>luafile %<cr><esc>", { desc = "Reload Lua" })
-- }}}

-- {{{ Windows
map("n", "<leader>wv", "<C-w>v", { desc = "vertical" })
map("n", "<leader>wh", "<C-w>s", { desc = "horizontal" })
map("n", "<leader>we", "<C-W>=", { desc = "equal" })
map("n", "<leader>wx", "<cmd>close<cr>", { desc = "close" })
map("n", "<leader>wlh", "<cmd>windo wincmd K<cr>", { desc = "horizontal layout" })
map("n", "<leader>wlv", "<cmd>windo wincmd H<cr>", { desc = "vertical layout" })

map("n", "<C-Up>", "<C-w>k", { desc = "go up" })
map("n", "<C-Down>", "<C-w>j", { desc = "go down" })
map("n", "<C-Left>", "<C-w>h", { desc = "go left" })
map("n", "<C-Right>", "<C-w>l", { desc = "go right" })
map("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "resize up" })
map("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "resize down" })
map("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "resize left" })
map("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "resize right" })
-- }}}

-- {{{ Buffers
map("n", "<A-Right>", "<cmd>bnext<cr>", { desc = "next buffer" })
map("n", "<A-Left>", "<cmd>bprevious<cr>", { desc = "previous buffer" })
map("n", "<A-UP>", "<cmd>bp<bar>bd#<cr>", { desc = "quit buffer" })
map("n", "<A-Down>", "<cmd>bp<bar>bd#<cr>", { desc = "quit buffer" })
-- }}}

-- {{{ Indenting
map("v", "<", "<gv", { desc = "unindent line" })
map("v", ">", ">gv", { desc = "indent line" })
-- }}}

-- {{{ Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "move text down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "move text up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "move text down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "move text up" })
map("v", "<A-j>", "<cmd>m .+1<cr>==", { desc = "move text up" })
map("v", "<A-k>", "<cmd>m .-2<cr>==", { desc = "move text down" })
map("x", "<A-j>", "<cmd>move '>+1<cr>gv-gv", { desc = "move text up" })
map("x", "<A-k>", "<cmd>move '<-2<cr>gv-gv", { desc = "move text down" })
-- }}}

-- {{{ Better Paste
map("v", "p", '"_dP', { desc = "paste no yank" })
map("n", "x", '"_x', { desc = "delete character no yank" })
-- }}}

-- {{{ Vertical move and center
map("n", "<C-d>", "<C-d>zz", { desc = "up and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "down and center" })
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
end, { desc = "close with ESC" })
-- }}}

-- {{{ Terminal
map("t", "<Esc>", "<C-\\><C-n>", { desc = "exit terminal" })
map("t", "<C-Up>", "<cmd>wincmd k<cr>", { desc = "up from terminal" })
map("t", "<C-Down>", "<cmd>wincmd j<cr>", { desc = "down from terminal" })
map("t", "<C-Left>", "<cmd>wincmd h<cr>", { desc = "left from terminal" })
map("t", "<C-Right>", "<cmd>wincmd l<cr>", { desc = "right from terminal" })
-- }}}

-- {{{ Mix
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "no highlight" })
map("n", "<BS>", "X", { desc = "TAB as X in normal mode" })
map("n", "<A-a>", "<esc>ggVG<cr>", { desc = "select all text" })
map("n", "<A-v>", "<C-q>", { desc = "visual block mode" })
map("n", "<A-+>", "<C-a>", { desc = "increment number" })
map("n", "<A-->", "<C-x>", { desc = "decrement number" })
-- map("n", "<leader>rw", ":%s/<c-r><c-w>//g<left><left>", { desc = "replace word" })
-- map("n", "<leader>r", "*``cgn", { desc = "replace word under cursor" })
-- }}}

-- {{{ Lazy
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })
-- }}}

-- {{{ NeoVim toggles
map("n", "<leader>vn", "<cmd>set relativenumber!<cr>", { desc = "numbers toggle" })
map("n", "<leader>vb", "<cmd>let &bg=(&bg == 'dark' ? 'light' : 'dark' )<CR>", { desc = "background toggle" })

local function conceal_toggle_option(option, true_val, false_val)
  vim.o[option] = vim.o[option] == true_val and false_val or true_val
end
map("n", "<leader>vc", function() conceal_toggle_option("conceallevel", 0, 1) end, { desc = "toggle conceal level" })
map("n", "<leader>vk", function() conceal_toggle_option("concealcursor", "n", "") end, { desc = "toggle conceal cursor" })
-- }}}

-- {{{ LSP
map("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "code action" })
map("n", "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "definition" })
map("n", "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "declaration" })
map("n", "<leader>lf", function()require("conform").format({ async = true, lsp_fallback = true })end, { desc = "formatting" })
map("n", "<leader>li", "<cmd>lua vim.lsp.buf.implementation()<cr>", { desc = "implementation" })
map("n", "<leader>lI", "<cmd>LspInfo<cr>", { desc = "info" })
map("n", "<leader>lk", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "hoover" })
map("n", "<leader>lr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "references" })
map("n", "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "rename" })
map("n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "signature help" })
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

-- End [[ KEYMAPS ]] }}}

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

require("lazy").setup(
  -- f-cia pre spravne fungovanie instalacnych f-cii pre molten a image.nvim,
  -- aby ich instalovalo len na linuxe
  vim.tbl_filter(function(plugin)
    return plugin ~= nil -- zabezpeci, aby instalovalo len "validne" pluginy
  end, {

      -- {{{ [ UI ]

      { "nvim-lua/plenary.nvim",-- {{{
        -- enabled = false,
        event = "VeryLazy",
      },-- }}}

      { "nvim-tree/nvim-web-devicons",-- {{{
        -- enabled = false,
        event = "VeryLazy",
      },-- }}}

      { "MunifTanjim/nui.nvim",-- {{{
        -- enabled = false,
        event = "VeryLazy",
      },-- }}}

      { "stevearc/dressing.nvim",-- {{{
        -- enabled = false,
        event = "VeryLazy",
        opts = {},
      },-- }}}

      { "j-hui/fidget.nvim",-- {{{
        enabled = false,
        event = "VeryLazy",
        opts = {}
      },-- }}}

      { "folke/noice.nvim",-- {{{
        -- enabled = false,
        event = "VeryLazy",
        dependencies = {-- {{{
          "MunifTanjim/nui.nvim",
          "rcarriga/nvim-notify", -- If not available, we use `mini` as the fallback
        },-- }}}
        opts = {-- {{{
          lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
              ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
              ["vim.lsp.util.stylize_markdown"] = true,
              ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
            },
          },
        },-- }}}
      },-- }}}

      -- }}}

      -- {{{ [ Colorscheme ]

      { "rebelot/kanagawa.nvim",-- {{{
        -- enabled = false,
        priority = 1000,
        config = function()
          require("kanagawa").setup({-- {{{
            colors = {-- {{{
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
            },-- }}}
            overrides = function(colors)-- {{{
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
                -- neo-tree
                NeoTreeNormal = { bg = theme.ui.bg_m1 },
                NeoTreeNormalNC = { bg = theme.ui.bg_m1 },
              }
            end,-- }}}
          })-- }}}
          vim.cmd.colorscheme("kanagawa")
        end,
      },-- }}}

      { "Mofiqul/adwaita.nvim",-- {{{
        enabled = false,
        lazy = false,
        priority = 1000,
        config = function()
          vim.cmd.colorscheme("adwaita")
        end,
      },-- }}}

      { "Mofiqul/vscode.nvim",-- {{{
        enabled = false,
        priority = 1000,
        config = function()-- {{{
          local c = require("vscode.colors").get_colors()
          require("vscode").setup({
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
          vim.cmd.colorscheme("vscode")
        end,-- }}}
      },-- }}}

      -- }}}

      -- {{{ [ Treesitter ]
      {
        "nvim-treesitter/nvim-treesitter",
        -- enabled = false,
        version = false,
        build = ":TSUpdate",
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        dependencies = {-- {{{
          "windwp/nvim-ts-autotag",
        },-- }}}
        main = "nvim-treesitter.configs",
        opts = {-- {{{
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
            "latex",
            "regex",
          },
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
          autotag = { enable = true },
        },-- }}}
      },
      -- }}}

      -- {{{ [ LSP ]
      {
        "neovim/nvim-lspconfig",
        -- enabled = false,
        dependencies = {-- {{{
          -- LSP
          "williamboman/mason.nvim",
          "williamboman/mason-lspconfig.nvim",
          "WhoIsSethDaniel/mason-tool-installer.nvim",
          -- Formatting
          "stevearc/conform.nvim",
          -- Linting
          "mfussenegger/nvim-lint",
        },-- }}}
        config = function()-- {{{
          -- {{{ LSP Servers
          require("mason").setup()
          local servers = {
            bashls = {-- {{{
              filetypes = { "zsh", "bash", "sh" },
            },-- }}}
            cssls = {},
            jsonls = {},
            emmet_ls = {-- {{{
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
            },-- }}}
            lua_ls = {-- {{{
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
            },-- }}}
            -- pyright = {-- {{{
            --   root_dir = function(fname)
            --     return vim.fn.fnamemodify(fname, ":p:h")  -- Automatically set the root to the current file's directory
            --   end,
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
            -- },-- }}}
            basedpyright = {-- {{{
              root_dir = function(fname)
                return vim.fn.fnamemodify(fname, ":p:h")  -- Automatically set the root to the current file's directory
              end,
              settings = {
                python = {
                  analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    useLibraryCodeForTypes = true,
                  },
                },
              },
            },-- }}}
            marksman = {-- {{{
              filetypes = {
                "markdown",
                "quarto",
              },
            },-- }}}
            tinymist = {-- {{{
              filetypes = {
                "typst",
              },
            },-- }}}
          }

          -- Auto install servers
          require("mason-lspconfig").setup({
            ensure_installed = vim.tbl_keys(servers),
            automatic_installation = true,
          })

          -- local capabilities = require("blink.cmp").get_lsp_capabilities()
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
              -- source = "always",
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
              -- python = { "isort", "black" },
              python = { "black" },
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
        end,-- }}}
      },
      -- }}}

      -- {{{ [ Autocompletition ]

      { "supermaven-inc/supermaven-nvim",-- {{{
        enabled = false,
        config = function()-- {{{
          require("supermaven-nvim").setup({
            keymaps = {
              accept_suggestion = "<Tab>",
              clear_suggestion = "<A-n>",
              accept_word = "<A-m>",
            },
            ignore_filetypes = { cpp = true }, -- or { "cpp", }
            color = {
              suggestion_color = "#717C7C",
              cterm = 244,
            },
            log_level = "info", -- set to "off" to disable logging completely
            disable_inline_completion = true, -- disables inline completion for use with cmp
            disable_keymaps = false, -- disables built in keymaps for more manual control
          })
        end,-- }}}
      },-- }}}

      { "hrsh7th/nvim-cmp",-- {{{
        -- enabled = false,
        dependencies = {-- {{{
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
        },-- }}}
        config = function()-- {{{
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

          cmp.setup({-- {{{
            enabled = function()-- {{{
              -- disable completion in comments
              if require"cmp.config.context".in_treesitter_capture("comment")==true
                or require"cmp.config.context".in_syntax_group("Comment") then
                return false
              else
                return true
              end
            end,
            -- enabled = true,}}}
            snippet = {-- {{{
              expand = function(args)
                -- for luasnip
                require("luasnip").lsp_expand(args.body)
              end,
            },-- }}}
            mapping = cmp.mapping.preset.insert({-- {{{
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
            }),-- }}}
            formatting = {-- {{{
              format = function(entry,item)
                local color_item = require("nvim-highlight-colors").format(entry, { kind = item.kind })
                item = lspkind.cmp_format({
                  mode = "symbol_text",
                  ellipsis_char = "...",
                  -- symbol_map = { Codeium = "" },
                  -- symbol_map = { Supermaven = "" },
                  menu = {
                    buffer = "[buf]",
                    -- codeium = "[cod]",
                    luasnip = "[snip]",
                    nvim_lsp = "[lsp]",
                    bootstrap = "[boot]",
                    -- otter = "[otter]", -- nie je uz nutne
                  },
                })(entry, item)
                if color_item.abbr_hl_group then
                  item.kind_hl_group = color_item.abbr_hl_group
                  item.kind = color_item.abbr
                end
                return item
              end
            },-- }}}
            sources = {-- {{{
              { name = "buffer" },
              { name = "path" },
              -- { name = "codeium" },
              -- { name = "supermaven" },
              { name = "luasnip" },
              { name = "nvim_lsp" },
              { name = "nvim_lsp_signature_help" },
              { name = "bootstrap" },
              -- { name = "otter" }, -- nie je uz nutne
              { name = "render-markdown" },
            },-- }}}
            sorting = {-- {{{
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
            },-- }}}
            confirm_opts = {-- {{{
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            },-- }}}
            window = {-- {{{
              completion = cmp.config.window.bordered({
                -- farby pre winhighlight su definovane v kanagawa teme
                winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                scrollbar = true,
              }),
              documentation = cmp.config.window.bordered({
                -- farby pre winhighlight su definovane v kanagawa teme
                winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
              }),
            },-- }}}
            view = {-- {{{
              entries = "custom",
            },-- }}}
            experimental = {-- {{{
              -- doplna text pri pisani, trochu otravne
              -- ghost_text = true,
              -- ghost_text = {hlgroup = "Comment"}
            },-- }}}
          })-- }}}
        end,-- }}}
      },-- }}}

      { "saghen/blink.cmp",-- {{{
        enabled = false,
        dependencies = "rafamadriz/friendly-snippets",
        version = "v0.*",
        opts = {-- {{{
          keymap = {-- {{{
            preset = "super-tab",
            ["<CR>"] = { "accept", "fallback" },
          },-- }}}
          appearance = {-- {{{
            use_nvim_cmp_as_default = false,
            nerd_font_variant = "normal",
          },-- }}}
          completion = {-- {{{
            menu = {
              draw = {
                columns = {
                  { "kind_icon" },
                  { "label", "label_description", gap = 1 },
                  { "source_name", "kind", gap = 1 },
                },
              },
            },
          },-- }}}
          signature = { enabled = true },
          sources = {-- {{{
            default = { "lsp", "path", "snippets", "buffer" },
            providers = {
              markdown = {
                name = 'RenderMarkdown',
                module = 'render-markdown.integ.blink',
                fallbacks = { 'lsp' },
              },
            },
          },-- }}}
        },-- }}}
        opts_extend = { "sources.default" },
      },-- }}}

      -- }}}

      -- {{{ [ Statusline ]
      {
        "nvim-lualine/lualine.nvim",
        -- enabled = false,
        event = "VeryLazy",
        config = function()
          local function vscode_theme()-- {{{
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
          end-- }}}

          local function lsp_server_icon()-- {{{
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
          end-- }}}

          local function python_env()-- {{{
            local venv = require("swenv.api").get_current_venv()
            if venv and venv.name then
              return venv.name:match("([^/]+)$") or ""
            end
            return ""
          end-- }}}

          local function buffer_counts()-- {{{
            local loaded_buffers = #vim.tbl_filter(function(buf)
              return vim.fn.buflisted(buf) ~= 0
            end, vim.api.nvim_list_bufs())
            local modified_buffers = #vim.tbl_filter(function(buf)
              return vim.bo[buf].modified
            end, vim.api.nvim_list_bufs())
            return string.format("󰈔 [%d:%d+]", loaded_buffers, modified_buffers)
          end-- }}}

          local function macro_recording()-- {{{
            local recording = vim.fn.reg_recording()
            return recording ~= "" and "󰻃 " .. recording or ""
          end-- }}}

          require("lualine").setup({-- {{{
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
          })-- }}}

          vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {-- {{{
            callback = function()
              local delay = vim.fn.reg_recording() == "" and 50 or 0
              vim.defer_fn(function()
                require("lualine").refresh({ place = { "statusline" } })
              end, delay)
            end,
            desc = "Auto-refresh for macro recording status",
          })-- }}}
        end,
      },
      -- }}}

      -- {{{ [ File Manager ]

      { "nvim-neo-tree/neo-tree.nvim",-- {{{
        -- enabled = false,
        dependencies = {-- {{{
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
          "MunifTanjim/nui.nvim",
          -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        },-- }}}
        opts = {-- {{{
          close_if_last_window = true,
          filesystem = {
            follow_current_file = { enabled = true },
          },
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
        },-- }}}
        keys = {-- {{{
          { "<leader>e", mode = {"n", "v" }, "<cmd>Neotree toggle %:p:h<cr>", desc = "Neo-tree", noremap = true, silent = true },
          { "<leader>E", mode = {"n", "v" }, "<cmd>Neotree filesystem reveal D:\\<cr>", desc = "Neo-tree D drive", noremap = true, silent = true },
        }-- }}}
      },-- }}}

      { "mikavilpas/yazi.nvim",-- {{{
        -- enabled = false,
        -- event = "VeryLazy",
        opts = {-- {{{
          open_for_directories = false,
          floating_window_scaling_factor = 0.7,
          yazi_floating_window_border = "single",
          keymaps = {
            show_help = "?",
          },
        },-- }}}
        keys = {-- {{{
          { "<leader>-", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "yazi", noremap = true, silent = true },
        },-- }}}
      },-- }}}

      -- }}}

      -- {{{ [ Telescope ]
      {
        "nvim-telescope/telescope.nvim",
        -- enabled = false,
        config = function()-- {{{
          local actions = require("telescope.actions")
          require("telescope").setup({-- {{{
            pickers = {
              colorscheme = {
                enable_preview = true,
              },
            },
            defaults = {
              layout_strategy = "vertical",
                -- layout_config = {
                --   preview_height = 0.55,
                --   width = 0.85,
                --   height = 0.85,
              -- },
              extensions = {},
            },
          })-- }}}
          -- require("telescope").load_extension("file_browser")
        end,-- }}}
        keys = {-- {{{
          { "<leader>fx", mode = "n", "<cmd>Telescope<cr>", desc = "telescope", noremap = true, silent = true },
          { "<leader>fn", mode = "n", "<cmd>Telescope notify<cr>", desc = "notifications", noremap = true, silent = true },
          { "<leader>ff", mode = "n", "<cmd>Telescope find_files<cr>", desc = "files", noremap = true, silent = true },
          { "<leader>fw", mode = "n", "<cmd>Telescope live_grep<cr>", desc = "words", noremap = true, silent = true },
          { "<leader>fo", mode = "n", "<cmd>Telescope oldfiles<cr>", desc = "recent files", noremap = true, silent = true },
          { "<leader>fb", mode = "n", "<cmd>Telescope buffers<cr>", desc = "buffers", noremap = true, silent = true },
          { "<leader>fc", mode = "n", "<cmd>Telescope colorscheme<cr>", desc = "colorscheme", noremap = true, silent = true },
          { "<leader>fd", mode = "n", "<cmd>Telescope diagnostics<cr>", desc = "diagnostics", noremap = true, silent = true },
          { "<leader>fh", mode = "n", "<cmd>Telescope help_tags<cr>", desc = "help tags", noremap = true, silent = true },
          { "<leader>fk", mode = "n", "<cmd>Telescope keymaps<cr>", desc = "keymaps", noremap = true, silent = true },
          -- { "<leader>fe", mode = "n", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = "file browser", noremap = true, silent = true },
        },-- }}}
      },
      -- }}}

      -- {{{ [ Mini.nvim collection ]
      {
        "echasnovski/mini.nvim",
        enabled = true,
        config = function()
          -- {{{ mini.comment
          local mappings_config = (os_type == "linux")
          and {
            comment = "",
            comment_line = "<C-/>",
            comment_visual = "<C-/>",
            textobject = "",
          }
          or {
            comment = "",
            comment_line = "<C-_>",
            comment_visual = "<C-_>",
            textobject = "",
          }

          require("mini.comment").setup({
            mappings = mappings_config,
          })
          -- }}}

          -- -- {{{ mini.notify
          -- require("mini.notify").setup()
          -- -- }}}

          -- {{{ mini.surround
          require("mini.surround").setup()
          -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
          -- - sd'   - [S]urround [D]elete [']quotes
          -- - sr)'  - [S]urround [R]eplace [)] [']
          -- }}}

          -- {{{ mini.pairs
          require("mini.pairs").setup()
          -- }}}

          -- {{{ mini.ai
          require('mini.ai').setup()
          -- }}}

          -- {{{ mini.clue
          local miniclue = require("mini.clue")
          miniclue.setup({
            window = {-- {{{
              config = {}, -- Floating window config
              delay = 500, -- Delay before showing clue window
              -- Keys to scroll inside the clue window
              scroll_down = "<C-d>",
              scroll_up = "<C-u>",
            },-- }}}
            triggers = {-- {{{
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
            },-- }}}
            clues = {-- {{{
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
              { mode = "n", keys = "<Leader>m", desc = "+Markdown" },
              { mode = "n", keys = "<Leader>o", desc = "+Obsidian" },
              { mode = "n", keys = "<Leader>on", desc = "+Notes" },
              { mode = "n", keys = "<Leader>ol", desc = "+Links" },
              { mode = "n", keys = "<Leader>p", desc = "+Python" },
              { mode = "n", keys = "<Leader>r", desc = "+REPL" },
              { mode = "n", keys = "<Leader>t", desc = "+Terminal" },
              { mode = "n", keys = "<Leader>q", desc = "+Quarto" },
              { mode = "n", keys = "<Leader>v", desc = "+Vim/Neovim" },
              { mode = "n", keys = "<Leader>w", desc = "+Window" },
              { mode = "n", keys = "<Leader>wl", desc = "+Layout" },
              -- moje skratky - visual mode
              { mode = "x", keys = "<Leader>m", desc = "+Markdown" },
              { mode = "x", keys = "<Leader>o", desc = "+Obsidian" },
              { mode = "x", keys = "<Leader>ol", desc = "+Links" },
              { mode = "x", keys = "<Leader>r", desc = "+REPL" },
              { mode = "x", keys = "<Leader>t", desc = "+Terminal" },
            },-- }}}
          })
          -- }}}
        end,
      },
      -- }}}

      -- {{{ [ Notes ]

      { "epwalsh/obsidian.nvim",-- {{{
        -- enabled = false,
        version = "*", -- recommended, use latest release instead of latest commit
        lazy = true,
        ft = "markdown",
        dependencies = {-- {{{
          "nvim-lua/plenary.nvim",
        },-- }}}
        opts = {-- {{{
          ui = { enable = false }, -- vypnute ui pre doplnok render-markdown
          disable_frontmatter = true,
          workspaces = {
            {
              name = "Obsidian",
              path = ObsidianPath() -- definovane v [[ DETECT OS ]]
            },
          },
          notes_subdir = "inbox",
          new_notes_location = "inbox",
          templates = {
            subdir = "templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M:%S",
          },
          completion = {
            nvim_cmp = true,
            min_chars = 2,
          },
          note_id_func = function(title)
            title = title or "Untitled"
            local sanitized_title = title:gsub(" ", "-") -- Replace spaces with underscores for file names
            return sanitized_title -- Return the sanitized title as the file name
          end,
          attachments = {
            img_folder = "images",
          },
        },-- }}}
        keys = {-- {{{
          { "<leader>onn", mode = "n", function()ObsidianNewNote(false)end, desc = "new note", noremap = true, silent = true },
          { "<leader>onb", mode = "n", function()ObsidianNewNote(true, "basic")end, desc = "new note template basic", noremap = true, silent = true },
          { "<leader>onp", mode = "n", function()ObsidianNewNote(true, "person")end, desc = "new note template person", noremap = true, silent = true },
          { "<leader>ot", mode = "n", ":ObsidianTemplate<cr>", desc = "template pick", noremap = true, silent = true },
          { "<leader>oi", mode = "n", ":ObsidianPasteImg<cr>", desc = "image paste", noremap = true, silent = true },
          { "<leader>oc", mode = "n", ":ObsidianToggleCheckbox<cr>", desc = "checkbox toggle", noremap = true, silent = true },
          { "<leader>oq", mode = "n", ":ObsidianQuickSwitch<cr>", desc = "switch note", noremap = true, silent = true },
          { "<leader>olf", mode = "n", ":ObsidianFollowLink<cr>", desc = "link follow", noremap = true, silent = true },
          { "<leader>olb", mode = "n", ":ObsidianBacklinks<cr>", desc = "backlinks", noremap = true, silent = true },
          { "<leader>oll", mode = "n", ":ObsidianLinks<cr>", desc = "link pick", noremap = true, silent = true },
          { "<leader>oT", mode = "n", ":ObsidianTags<cr>", desc = "tags", noremap = true, silent = true },
          { "<leader>oD", mode = "n", ":lua local f=vim.fn.expand('%:p'); if vim.fn.confirm('Delete '..f..'?', '&Yes\\n&No') == 1 then os.remove(f); vim.cmd('bd!'); end<cr>", desc = "delete note", noremap = true, silent = true },
          { "<leader>os", mode = "n", function()require('telescope.builtin').find_files({ search_dirs = { ObsidianPath() } })end, desc = "search note", noremap = true, silent = true },
          { "<leader>oe", mode = {"v", "x"}, ":ObsidianExtractNote<cr>", desc = "extract text", noremap = true, silent = true },
          { "<leader>ol", mode = {"v", "x"}, ":ObsidianLinkNew<cr>", desc = "link new", noremap = true, silent = true },
        },-- }}}
      },-- }}}

      { "MeanderingProgrammer/render-markdown.nvim",-- {{{
        -- enabled = false,
        ft = { "markdown", "quarto" },
        dependencies = {-- {{{
          "nvim-treesitter/nvim-treesitter",
          "nvim-tree/nvim-web-devicons"
        },-- }}}
        init = function()-- {{{
          local colors = {
            {bg = "#43242B", fg = "#C34043"},
            {bg = "#49443C", fg = "#DCA561"},
            {bg = "#2B3328", fg = "#76946A"},
            {bg = "#252535", fg = "#938AA9"},
            {bg = "#252535", fg = "#658594"},
            {bg = "#252535", fg = "#717C7C"},
          }
          -- Heading colors (when not hovered over), extends through the entire line
          for i, color in ipairs(colors) do
            vim.cmd(string.format([[highlight Headline%dBg guifg=%s guibg=%s]], i, color.fg, color.bg))
          end
          for i, color in ipairs(colors) do
            vim.cmd(string.format([[highlight Headline%dFg cterm=bold gui=bold guifg=%s]], i, color.bg))
          end
        end,-- }}}
        opts = {-- {{{
          -- log_level = 'debug',
          heading = {-- {{{
            -- icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
            icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
            backgrounds = {
              "Headline1Bg",
              "Headline2Bg",
              "Headline3Bg",
              "Headline4Bg",
              "Headline5Bg",
              "Headline6Bg",
            },
            foregrounds = {
              "Headline1Fg",
              "Headline2Fg",
              "Headline3Fg",
              "Headline4Fg",
              "Headline5Fg",
              "Headline6Fg",
            },
          },-- }}}
          latex = {-- {{{
            -- enabled = true,
            enabled = (function()
              if os_type == "windows" and os_username == "mech" then
                return false
              else
                return true
              end
            end)(),
            converter = "latex2text",
            highlight = 'RenderMarkdownMath',
            top_pad = 0,
            bottom_pad = 0,
          },-- }}}
        },-- }}}
        keys = {-- {{{
          { "<leader>mp", mode = { "n" }, "<cmd>RenderMarkdown toggle<cr><cr>", desc = "preview toggle", noremap = true, silent = true },
          { "<leader>mi", mode = { "n" }, "<cmd>RenderMarkdown expand<cr><cr>", desc = "increase conceal", noremap = true, silent = true },
          { "<leader>md", mode = { "n" }, "<cmd>RenderMarkdown contract<cr><cr>", desc = "decrease conceal", noremap = true, silent = true },
          -- align columns in markdown table
          -- https://heitorpb.github.io/bla/format-tables-in-vim/
          { "<leader>mT", mode = { "v" }, ":! tr -s ' ' | column -t -s '|' -o '|'<cr>", desc = "align table only linux", noremap = true, silent = true },
          -- https://lazybea.rs/posts/markdown-tables-and-neovim
          { "<leader>mt", mode = { "v" }, ":!pandoc -t markdown-simple_tables<cr>", desc = "align table using pandoc", noremap = true, silent = true },
        },-- }}}
      },-- }}}

      { "Kicamon/markdown-table-mode.nvim",-- {{{
        -- enabled = false,
        lazy = true,
        ft = { "markdown", "quarto" },
        opts = {},
      },-- }}}

      -- }}}

      -- {{{ [ Python ]

      { "AckslD/swenv.nvim",-- {{{
        -- enabled = false,
        opts = {-- {{{
          get_venvs = function(venvs_path)
            return require("swenv.api").get_venvs(venvs_path)
          end,
          venvs_path = py_venvs_path, -- py_venvs_path, premennu definovanu v [[ DETECT OS]]
          post_set_venv = function()
            vim.cmd(":LspRestart")
          end,
        },-- }}}
        keys = {
          { "<leader>pe", mode = { "n" }, "<cmd>lua require('swenv.api').pick_venv()<cr>", desc = "python venvs", noremap = true, silent = true },
        },
      },-- }}}

      { "lepture/vim-jinja",-- {{{
        -- enabled = false,
        ft = { "jinja.html", "html" },
      },-- }}}

      -- }}}

      -- {{{ [ Quarto, Jupyterlab ]

      { "quarto-dev/quarto-nvim",-- {{{
        -- enabled = false,
        ft = { "quarto" },
        dev = false,
        opts = {-- {{{
          lspFeatures = {
            languages = { "python", "bash", "lua", "html", "javascript" },
          },
        },-- }}}
        dependencies = {-- {{{
          {
            "jmbuhr/otter.nvim",
            ft = { "quarto", "markdown" },
            dev = false,
            config = function()
              -- autocommand to call "otter.activate()"{{{
              vim.api.nvim_create_autocmd("FileType", {
                pattern = { "quarto", "markdown" },
                callback = function()
                  require('otter').activate()
                end,
              })-- }}}
            end,
          },
        },-- }}}
        keys = {-- {{{
          { "<leader>qa", mode = { "n" }, "<cmd>QuartoActivate<cr>", desc = "quarto activate", noremap = true, silent = true },
          { "<leader>qp", mode = { "n" }, "<cmd>lua require'quarto'.quartoPreview()<cr>", desc = "quarto preview", noremap = true, silent = true },
          { "<leader>qq", mode = { "n" }, "<cmd>lua require'quarto'.quartoClosePreview()<cr>", desc = "quarto quit", noremap = true, silent = true },
          { "<leader>qh", mode = { "n" }, "<cmd>QuartoHelp<cr>", desc = "quarto help", noremap = true, silent = true },
        },-- }}}
      },-- }}}

      -- {{{ Molten
      (function()
        if os_type == "linux" then
          return {
            "benlubas/molten-nvim",
            -- enabled = false,
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
        return {
          "benlubas/molten-nvim",
          -- enabled = false,
          ft = { "quarto" },
          init = function()
            vim.g.python3_host_prog = PythonInterpreter()
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_output_win_max_height = 20
            vim.g.molten_virt_text_output = true
            vim.g.molten_wrap_output = true
            vim.g.molten_auto_open_output = false
          end,
        }
      end)(),
      -- }}}

      -- {{{ Image.nvim
      (function()
        if os_type == "linux" then
          return {-- {{{
            "3rd/image.nvim",
            -- enabled = false,
            dev = false,
            ft = { "markdown", "quarto", "vimwiki" },
            dependencies = {-- {{{
              {
                "vhyrro/luarocks.nvim",
                priority = 1001, -- this plugin needs to run before anything else
                opts = {
                  rocks = { "magick" },
                },
              },
            },-- }}}
            config = function()-- {{{
              local image = require("image")
              -- Requirements
              -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
              -- check for dependencies with `:checkhealth kickstart`
              -- needs:
              -- sudo apt install imagemagick
              -- sudo apt install libmagickwand-dev
              -- sudo apt install liblua5.1-0-dev
              -- sudo apt installl luajit
              image.setup({-- {{{
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
              })-- }}}
            end,-- }}}
          }-- }}}
        end
        return nil
      end)(),
      -- }}}

      -- }}}

      -- {{{ [ REPL Iron.nvim ]
      {
        "hkupty/iron.nvim",
        -- enabled = false,
        ft = { "python", "markdown", "quarto"},
        config = function()-- {{{
          local iron = require("iron.core")
          local view = require("iron.view")

          iron.setup({-- {{{
            highlight = {
              italic = true
            },
            ignore_blank_lines = true,
            keymaps = {},
            config = {
              highlight_last = "IronLastSent",
              repl_definition = {
                python = {
                  command = { PythonInterpreter() }, -- function in detect os - dynamically resolve python interpreter
                  -- format = require("iron.fts.common").bracketed_paste_python,
                  -- block_deviders = { "# %%", "#%%" }, -- not working properly
                },
                markdown = {
                  command = { "ipython", "--no-autoindent" },
                  -- block_deviders = { "```python", "```" }, -- not working properly
                },
                quarto = {
                  command = { "ipython", "--no-autoindent" },
                },
              },
              repl_open_cmd = view.split("30%"), -- open repl in a split window (30% height)
            },
          })-- }}}

          -- {{{ block chunk code sending function - moja pretoze default nefunguje ako ma
          _G.SendFencedCode = function()
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            local row = cursor_pos[1] - 1  -- lua uses 0-based indexing
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

            -- determine file type and set appropriate block delimiters
            local filetype = vim.bo.filetype
            local start_pattern, end_pattern

            if filetype == "python" then
              -- python uses "# %%"
              start_pattern = "^# %%"
              end_pattern = "^# %%"
            elseif filetype == "markdown" then
              -- markdown/quarto uses "```python" and "```"
              start_pattern = "^```python"
              end_pattern = "^```"
            elseif filetype == "quarto" then
              start_pattern = "^```{python}"
              end_pattern = "^```"
            else
              print("Unsupported file type for code block detection!")
              return
            end

            -- find the start and end of the fenced code block
            local start_row, end_row
            for i = row, 0, -1 do
              if lines[i]:match(start_pattern) then
                start_row = i
                break
              end
            end

            for i = row + 1, #lines do
              if lines[i]:match(end_pattern) then
                end_row = i
                break
              end
            end

            if not start_row or not end_row then
              print("No fenced code block found!")
              return
            end

            -- extract the code inside the block
            local code = {}
            for i = start_row + 1, end_row - 1 do
              local line = lines[i]:gsub("%s+$", "")  -- remove trailing whitespace
              if line ~= "" then  -- skip blank lines
                table.insert(code, line)
              end
            end

            if #code == 0 then
              print("Code block is empty!")
              return
            end

            -- send code to repl
            require("iron.core").send(nil, code)
          end
          -- }}}

        end,-- }}}
        keys = {-- {{{
          { "<leader>rs", mode = { "n" }, "<cmd>IronRepl<cr>", desc = "repl start", noremap = true, silent = true },
          { "<leader>rq", mode = { "n" }, "<cmd>lua require('iron.core').close_repl()<cr>", desc = "repl quit", noremap = true, silent = true },
          { "<leader>rl", mode = { "n" }, "<cmd>lua require('iron.core').send_line()<cr>", desc = "send line", noremap = true, silent = true },
          { "<leader>rf", mode = { "n" }, "<cmd>lua require('iron.core').send_file()<cr>", desc = "send file", noremap = true, silent = true },
          { "<leader>rb", mode = { "n" }, "<cmd>lua SendFencedCode()<cr>", desc = "send block", noremap = true, silent = true },
          { "<leader>rl", mode = { "v" }, "<cmd>lua require('iron.core').visual_send()<cr>", desc = "send lines", noremap = true, silent = true },
        },-- }}}
      },
      -- }}}

      -- {{{ [ Mix ]

      { "szw/vim-maximizer",-- {{{
        -- enabled = false,
        keys = {-- {{{
          { "<leader>wm", mode = {"n", "v"}, "<cmd>MaximizerToggle<cr>", desc = "maximize", noremap = true, silent = true },
        },-- }}}
      },-- }}}

      { "brenoprata10/nvim-highlight-colors",-- {{{
        -- enabled = false,
        opts = {},
        keys = {-- {{{
          { "<leader>vh", mode = "n", "<cmd>HighlightColors Toggle<cr>", desc = "highlight-colors toggle", noremap = true, silent = true },
        },-- }}}
      },-- }}}

      -- }}}

      -- {{{ [ Terminal ]

      { "akinsho/toggleterm.nvim",-- {{{
        -- enabled = false,
        opts = {-- {{{
          size = function(term)
            if term.direction == "horizontal" then
              return 25
            elseif term.direction == "vertical" then
              return vim.o.columns * 0.4
            end
          end,
        },-- }}}
        config = function(_,opts)-- {{{
          require("toggleterm").setup(opts)
          local Terminal = require("toggleterm.terminal").Terminal

          function _G.PythonTerminal()-- {{{
            local python = Terminal:new({
              direction = "horizontal",
              cmd = PythonInterpreter(),
              hidden = true,
            })
            python:toggle()
          end-- }}}

          function _G.IpythonTerminal()-- {{{
            local ipython = Terminal:new({
              direction = "horizontal",
              cmd = "ipython --no-autoindent",
              hidden = true,
            })
            ipython:toggle()
          end-- }}}

          function _G.Ranger()-- {{{
            local Path = require("plenary.path")
            local path = vim.fn.tempname()
            local ranger = Terminal:new({
              direction = "float",
              cmd = ('ranger --choosefiles "%s"'):format(path),
              close_on_exit = true,
              on_close = function()
                Data = Path:new(path):read()
                vim.schedule(function()
                  vim.cmd("edit" .. Data)
                end)
              end,
            })
            ranger:toggle()
          end-- }}}

          function _G.Yazi()-- {{{
            local Path = require("plenary.path")
            local path = vim.fn.tempname()
            local yazi = Terminal:new({
              direction = "float",
              cmd = ('yazi'):format(path),
              close_on_exit = true,
              on_close = function()
                Data = Path:new(path):read()
                vim.schedule(function()
                  vim.cmd("edit" .. Data)
                end)
              end,
            })
            yazi:toggle()
          end-- }}}

          function _G.LiveServer()-- {{{
            local web = Terminal:new({
              direction = "horizontal",
              cmd = "live-server .",
            })
            web:toggle()
          end-- }}}

          function _G.LazyGit()-- {{{
            local lazygit = Terminal:new({
              direction = "float",
              cmd = "lazygit",
              dir = "git_dir",
              hidden = true,
            })
            lazygit:toggle()
          end-- }}}

        end,-- }}}
        keys = {-- {{{
          { "<leader>tt", mode = { "n" }, "<cmd>ToggleTerm<cr>", desc = "new terminal", noremap = true, silent = true },
          { "<leader>tf", mode = { "n" }, "<cmd>ToggleTerm direction=float<cr>", desc = "terminal float", noremap = true, silent = true },
          { "<leader>tp", mode = { "n" }, "<cmd>lua PythonTerminal()<cr>", desc = "python terminal", noremap = true, silent = true },
          { "<leader>ti", mode = { "n" }, "<cmd>lua IpythonTerminal()<cr>", desc = "ipython terminal", noremap = true, silent = true },
          { "<leader>tr", mode = { "n" }, "<cmd>lua Ranger()<cr>", desc = "ranger", noremap = true, silent = true },
          { "<leader>ty", mode = { "n" }, "<cmd>lua Yazi()<cr>", desc = "yazi", noremap = true, silent = true },
          { "<leader>tw", mode = { "n" }, "<cmd>lua LiveServer()<cr>", desc = "web live server", noremap = true, silent = true },
          { "<leader>tg", mode = { "n" }, "<cmd>lua LazyGit()<cr>", desc = "lazygit", noremap = true, silent = true },
          { "<leader>tl", mode = { "n" }, "<cmd>ToggleTermSendCurrentLine<cr>", desc = "send line", noremap = true, silent = true },
          { "<leader>tl", mode = { "v" }, "<cmd>ToggleTermSendVisualLines<cr>", desc = "send lines", noremap = true, silent = true },
        },-- }}}
      },-- }}}

      -- }}}

    })
) -- ukoncuje require("lazy").setup(
-- }}}

-- {{{ [[ AUTOCOMANDS ]]

local mygroup = vim.api.nvim_create_augroup("vimrc", { clear = true })

-- {{{ highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 300,
    })
  end,
  group = mygroup,
  desc = "highlight yanked text",
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
  pattern = { "*.py", "*.css", "*.scss", "*.html", "*.qmd", "*.md" },
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

-- {{{ autoformat code on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py", "*.json", "*.css", "*.scss" },
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
  group = mygroup,
  desc = "autoformat code on save",
})
-- }}}

-- {{{ auto linting
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  pattern = { "*" },
  callback = function()
    require("lint").try_lint()
  end,
})
-- }}}

-- {{{ sass compilation on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.sass", "*.scss" },
  command = [[:silent exec "!sass --no-source-map %:p %:r.css"]],
  group = mygroup,
  desc = "sass compilation on save",
})
-- }}}

-- {{{ shiftwidth setup
-- vim.api.nvim_create_autocmd("filetype", {
--   pattern = { "c", "cpp", "py", "java", "cs" },
--   callback = function()
--     vim.bo.shiftwidth = 4
--   end,
--   group = mygroup,
--   desc = "set shiftwidth to 4 in these filetypes",
-- })
-- }}}

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

-- {{{ check if we need to reload the file when it changed
vim.api.nvim_create_autocmd("FocusGained", {
  command = [[:checktime]],
  group = mygroup,
  desc = "update file when there are changes",
})
-- }}}

-- {{{ windows to close with "q"
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "toggleterm", "help", "startuptime", "qf", "lspinfo" },
  command = [[nnoremap <buffer><silent> q :close<cr>]],
  group = mygroup,
  desc = "close windows with q",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "man",
  command = [[nnoremap <buffer><silent> q :quit<cr>]],
  group = mygroup,
  desc = "close man pages with q",
})
-- }}}

-- {{{ don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", {
  command = [[set formatoptions-=cro]],
  group = mygroup,
  desc = "don't auto comment new line",
})
-- }}}

-- {{{ open help on right side
-- vim.api.nvim_create_autocmd("BufEnter", {
--   command = [[if &buftype == 'help' | wincmd l | endif]],
--   group = mygroup,
--   desc = "help on right side",
-- })
-- }}}

-- {{{ open terminal at same location as opened file
vim.api.nvim_create_autocmd("BufEnter", {
  command = [[silent! lcd %:p:h]],
  group = mygroup,
  desc = "open terminal in same location as opened file",
})
-- }}}

-- {{{ terminal options
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.cmd("startinsert!")
  end,
  group = mygroup,
  desc = "terminal options",
})
-- }}}

-- {{{ remove trailling whitespace (medzeru na konci) when save file
vim.api.nvim_create_autocmd("BufWritePre", {
  command = [[%s/\s\+$//e]],
  group = mygroup,
  desc = "remove tarilling whitespace",
})
-- }}}

-- {{{ resize vim windows when overall window size changes
vim.api.nvim_create_autocmd("VimResized", {
  command = [[wincmd =]],
  group = mygroup,
  desc = "resize windows to equal",
})
-- }}}

-- {{{ python
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = [[nnoremap <buffer> <M-p> :w<cr>:terminal python3 "%"<cr>]],
  group = mygroup,
  desc = "open file in python terminal",
})

vim.api.nvim_create_autocmd("filetype", {
  pattern = "python",
  command = [[setlocal colorcolumn=80]],
  group = mygroup,
  desc = "set colorcolumn for python files",
})
-- }}}

-- {{{ set typst filetype - quarto specific
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
  pattern = "*.typ",
  command = "set filetype=typst",
  desc = "set filetype for typst files",
})
-- }}}

-- {{{ telescope on start
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argv(0) == "" then
      require("telescope.builtin").oldfiles()
    end
  end,
  group = mygroup,
  desc = "start telescope on start",
})
-- }}}

-- }}}
