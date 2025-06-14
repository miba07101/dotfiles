local dashboard_header = [[
██╗   ██╗██╗███╗   ███╗██╗██╗   ██╗██╗███╗   ███╗
██║   ██║██║████╗ ████║██║██║   ██║██║████╗ ████║
██║   ██║██║██╔████╔██║██║██║   ██║██║██╔████╔██║
╚██╗ ██╔╝██║██║╚██╔╝██║██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ╚████╔╝ ██║██║ ╚═╝ ██║██║ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

-- {{{ [[ UTILS ]]

function _G.DetectOsType() -- {{{
  -- Detect OS Type
  local os_name = vim.loop.os_uname().sysname
  local os_type = (os_name == "Windows_NT" and "windows")
    or (os_name == "Linux" and (vim.fn.has("wsl") == 1 and "wsl" or "linux"))
    or os_name

  -- Environment Variables
  local home = os.getenv("HOME") or os.getenv("USERPROFILE")
  local username = os.getenv("USERNAME") or os.getenv("USER")
  local venv_home = os.getenv("VENV_HOME") or (home .. "/.py-venv")
  local nvim_venv = venv_home .. "/base-venv"
  local debugpy_path = vim.fn.stdpath("data") .. "\\mason\\packages\\debugpy\\venv\\Scripts\\python.exe"
  local venv = os.getenv("VIRTUAL_ENV") -- Moved here for reuse

  -- Function to determine Python interpreter
  local function PythonInterpreter()
    return venv and (os_type == "windows" and (venv .. "\\Scripts\\python.exe") or (venv .. "/bin/python")) or "python3"
  end

  -- -- Function to initialize Molten.nvim
  -- local function MoltenInitialize()
  --   if venv then
  --     vim.cmd("MoltenInit " .. (venv:match("[^/\\]+$") or "python3"))
  --   else
  --     vim.notify("No virtual environment. Please activate one.", vim.log.levels.INFO)
  --   end
  -- end

  -- Function to get Obsidian path
  local function ObsidianPath()
    local tilda = vim.fn.expand("~")
    return username == "mech" and (tilda .. "\\Obsidian/")
      or vim.fn.expand((os.getenv("OneDrive_DIR") or "") .. "Dokumenty/zPoznamky/Obsidian/")
  end

  -- -- Function to create a new Obsidian note
  -- local function ObsidianNewNote(use_template, template, folder)
  --   -- local note_name = vim.fn.input("Enter note name without .md: ")
  --   -- if note_name == "" then return print("Note name cannot be empty!") end
  --
  --   vim.ui.input({ prompt = "Enter note name without .md: " }, function(note_name)
  --     if not note_name or note_name == "" then
  --       print("Note name cannot be empty!")
  --       return
  --     end
  --
  --     local new_note_path = string.format("%s%s/%s.md", ObsidianPath(), folder or "inbox", note_name)
  --     vim.cmd("edit " .. new_note_path)
  --
  --     if use_template then
  --       local templates = { basic = "t-nvim-note.md", person = "t-person.md" }
  --       vim.cmd(templates[template] and "ObsidianTemplate " .. templates[template] or "echo 'Invalid template name'")
  --     end
  --   end)
  -- end

  return {
    os_type = os_type,
    username = username,
    venv_home = venv_home,
    nvim_venv = nvim_venv,
    debugpy_path = debugpy_path,
    PythonInterpreter = PythonInterpreter,
    SupportedTerminal= SupportedTerminal,
    is_supported_terminal = is_supported_terminal,
    ObsidianPath = ObsidianPath,
    -- MoltenInitialize = MoltenInitialize,
    -- ObsidianNewNote = ObsidianNewNote,
  }
end

-- Initialize Environment
_G.osvar = DetectOsType()

-- Usage Example:
-- osvar.ObsidianPath()
-- osvar.ObsidianNewNote(true, "basic", "inbox")
-- }}}

-- f. pre mini.ai selekciu blokov kodu oddelenych "% ##" v python/jupyter suboroch{{{
local function python_code_cell(ai_type)
  if vim.bo.filetype ~= "python" then
    return nil
  end

  local function getline_trimmed(lnum)
    return vim.trim(vim.fn.getline(lnum))
  end

  local cursor_line = vim.fn.line(".")
  local bufnr = vim.api.nvim_get_current_buf()
  local total_lines = vim.api.nvim_buf_line_count(bufnr)

  -- Find start
  local start_line = nil
  for i = cursor_line, 1, -1 do
    if getline_trimmed(i):find("^# %%%%") then
      start_line = i
      break
    end
  end
  if not start_line then
    return
  end

  -- Find end
  local end_line = nil
  for i = start_line + 1, total_lines do
    if getline_trimmed(i):find("^# %%%%") then
      end_line = i - 1
      break
    end
  end
  if not end_line then
    end_line = total_lines
  end

  -- Trim trailing blank lines
  while end_line > start_line and getline_trimmed(end_line) == "" do
    end_line = end_line - 1
  end

  -- For 'inner', exclude the '# %%' header line
  -- and skip one blank line if it's right after it
  if ai_type == "i" and start_line < end_line then
    start_line = start_line + 1
    if getline_trimmed(start_line) == "" then
      start_line = start_line + 1
    end
  end

  -- Get full range of last line (col = 1 to end of line)
  local end_col = #(vim.fn.getline(end_line)) + 1

  return {
    from = { line = start_line, col = 1 },
    to = { line = end_line, col = end_col },
  }
end
-- }}}

-- for snacks.dashboard.sections.terminal "weather wttr.in app"{{{
local city = vim.fn.system("curl -s ipinfo.io/city"):gsub("%s+", "")
-- }}}

-- }}}

-- {{{ [[ OPTIONS ]]

-- File{{{
vim.opt.backup        = false         -- create a backup file
vim.opt.clipboard     = "unnamedplus" -- system clipboard
vim.opt.hidden        = true          -- switching from unsaved buffers
vim.opt.inccommand    = "split"       -- preview substitutions live, as you type
vim.opt.matchtime     = 2             -- duration of showmatch, default 5
vim.opt.mouse         = "a"           -- mouse
vim.opt.scrolloff     = 5             -- how many lines are displayed on the upper and lower sides of the cursor
vim.opt.showmode      = true          -- display the current vim mode (no need)
vim.opt.sidescrolloff = 8             -- number of columns to keep at the sides of the cursor
vim.opt.splitbelow    = true          -- splitting window below
vim.opt.splitright    = true          -- splitting window right
vim.opt.swapfile      = false         -- create a swap file
vim.opt.syntax        = "on"
vim.opt.termguicolors = true          -- terminal supports more colors
vim.opt.termguicolors = true          -- terminal supports more colors
vim.opt.timeoutlen    = 300           -- time to wait for a mapped sequence to complete, default 1000
vim.opt.updatetime    = 200           -- speed up response time
vim.opt.wrap          = false         -- disable wrapping of lines longer than the width of window
vim.opt.writebackup   = false         -- create backups when writing files
vim.opt.matchpairs    = { "(:)", "{:}", "[:]", "<:>" }
vim.opt.iskeyword:remove("_")         -- oddeli slova pri mazani, nebude brat ako jedno slovo
-- }}}

-- Completition{{{
vim.opt.completeopt = { "menuone", "noselect" } -- completion options
vim.opt.pumheight   = 10                        -- completion menu height
-- vim.opt.wildmenu    = true                      -- make tab completion for files/buffers act like bash
-- }}}

-- Indention{{{
local indent_config = {
  vim        = { shiftwidth = 2, softtabstop = 2, tabstop = 2 },
  python     = { shiftwidth = 4, softtabstop = 4, tabstop = 4 },
  html       = { shiftwidth = 2, softtabstop = 2, tabstop = 2 },
  css        = { shiftwidth = 2, softtabstop = 2, tabstop = 2 },
  javascript = { shiftwidth = 2, softtabstop = 2, tabstop = 2 },
  typescript = { shiftwidth = 2, softtabstop = 2, tabstop = 2 },
  json       = { shiftwidth = 2, softtabstop = 2, tabstop = 2 },
  jinja      = { shiftwidth = 4, softtabstop = 4, tabstop = 4 },
  django     = { shiftwidth = 4, softtabstop = 4, tabstop = 4 },
  htmldjango = { shiftwidth = 4, softtabstop = 4, tabstop = 4 },
  typst      = { shiftwidth = 2, softtabstop = 2, tabstop = 2 },
  jupyter    = { shiftwidth = 4, softtabstop = 4, tabstop = 4 },
  lua        = { shiftwidth = 2, softtabstop = 2, tabstop = 2 },
  toml        = { shiftwidth = 2, softtabstop = 2, tabstop = 2 },
  ps1        = { shiftwidth = 4, softtabstop = 4, tabstop = 4 },
  bash       = { shiftwidth = 4, softtabstop = 4, tabstop = 4 },
}

-- Create autocommand group
vim.api.nvim_create_augroup("CustomIndentation", { clear = true })

for filetype, opts in pairs(indent_config) do
  vim.api.nvim_create_autocmd("FileType", {
    group = "CustomIndentation",
    pattern = filetype,
    callback = function()
      vim.opt_local.autoindent  = true             -- auto indentation
      vim.opt_local.expandtab   = true             -- convert tabs to spaces (prefered for python)
      vim.opt_local.smartindent = true             -- make indenting smarter
      vim.opt_local.shiftwidth  = opts.shiftwidth  -- spaces inserted for each indentation
      vim.opt_local.softtabstop = opts.softtabstop -- when hitting <BS>, pretend like a tab is removed, even if spaces
      vim.opt_local.tabstop     = opts.tabstop     -- insert spaces for a tab
    end,
  })
end
-- }}}

-- Fold{{{
-- vim.opt.foldcolumn = "1"                          -- folding column show
vim.opt.foldenable    = true                         -- folding allowed
vim.opt.foldexpr      = "nvim_treesitter#foldexpr()" -- folding method use treesitter
vim.opt.foldlevel     = 0                            -- folding from lvl 1
vim.opt.foldmethod    = "expr"                       -- folding method
-- vim.opt.foldmethod = "marker"                     -- folding method
-- vim.opt.foldtext   = [[getline(v:foldstart)]]     -- folding - disable all chunk when folded
-- vim.opt.fillchars:append({eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "",})
-- }}}

-- Search{{{
vim.opt.hlsearch   = true -- search highlighting
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.incsearch  = true -- highlight while searching
vim.opt.smartcase  = true -- intelligent case sensitivity when searching (if there is upper case, turn off case ignoring)
vim.opt.wrapscan   = true -- search the entire file repeatedly
vim.opt.wildignore = vim.opt.wildignore + { "*/node_modules/*", "*/.git/*", "*/vendor/*" }
-- }}}

-- UI{{{
vim.opt.cmdheight    = 0     -- command line height
vim.opt.cursorline   = true  -- highlight the current line
vim.opt.laststatus   = 3     -- global status bar (sposobuje nefunkcnost resource lua.init)
vim.opt.fillchars    = ""    -- disable fillchars
vim.opt.number       = true  -- absolute line numbers
vim.opt.signcolumn   = "yes" -- symbol column width
-- vim.opt.list      = true                                               -- show some invisible characters (tabs...
-- vim.opt.listchars = { eol = "¬", tab = "› ", trail = "·", nbsp = "␣" } -- list characters
-- }}}

-- Neovim Python Host{{{
vim.g.python3_host_prog = osvar.os_type == "windows" and (osvar.nvim_venv .. "\\Scripts\\python.exe")
  or (osvar.nvim_venv .. "/bin/python3")
-- }}}

-- Shell and Cursor Setup{{{
local function ConfigureShellAndCursor()
  -- Function to set cursor appearance
  local function SetCursor()
    vim.opt.guicursor = { "n-v-c:block,i-ci-ve:bar-blinkwait200-blinkoff150-blinkon150" }
  end

  -- Shell & Cursor Configuration
  if osvar.os_type == "windows" then
    vim.opt.shell = "pwsh.exe"
    vim.opt.shellcmdflag =
      "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;$PSStyle.Formatting.Error = '';$PSStyle.Formatting.ErrorAccent = '';$PSStyle.Formatting.Warning = '';$PSStyle.OutputRendering = 'PlainText';"
    vim.opt.shellredir = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
    vim.opt.shellpipe = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""

    -- Set cursor for a specific user
    if osvar.username ~= "mech" then
      SetCursor()
    end
  else
    vim.opt.shell = osvar.os_type == "wsl" and "/bin/zsh" or "/bin/zsh"
    if osvar.os_type == "wsl" then
      SetCursor()
    end
  end
end

-- Call the function to apply the configuration
ConfigureShellAndCursor()
-- }}}

vim.filetype.add({ -- {{{
  extension = {
    zsh    = "sh",
    sh     = "sh",
    ipynb  = "ipynb",
    typ    = "typst",
  },
  filename = {
    [".zshrc"]  = "bash",
    [".zshenv"] = "sh",
    [".ipynb"]  = "ipynb", -- Only if you have a custom opener; otherwise, `ipynb` isn't a real filename
  },
}) -- }}}

-- }}}

-- {{{ [[ KEYMAPS ]]

-- Wrapper for mapping custom keybindings{{{
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end -- }}}

-- Leader Key{{{
map("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- }}}

-- Save, Quit{{{
map({ "n", "v", "i", "x" }, "<C-s>", "<cmd>w<cr>", { desc = "Save" })
map({ "n", "v", "i", "x" }, "<C-w>", "<cmd>wq<cr>", { desc = "Save-Quit" })
map({ "n", "v", "i", "x" }, "<C-q>", "<cmd>q!<cr>", { desc = "Quit" })
-- map("n", "<leader>x", "<cmd>w<cr><cmd>luafile %<cr><esc>", { desc = "Reload Lua" })
-- }}}

-- Windows{{{
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
-- }}}

-- Buffers{{{
map("n", "<A-Right>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<A-Left>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
-- map("n", "<A-UP>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })
-- map("n", "<A-Down>", "<cmd>bp<bar>bd#<cr>", { desc = "Quit buffer" })
map("n", "<A-UP>", "<cmd>lua require('mini.bufremove').delete()<cr>", { desc = "Quit buffer" })
map("n", "<A-Down>", "<cmd>lua require('mini.bufremove').delete()<cr>", { desc = "Quit buffer" })
-- }}}

-- Move in insert mode{{{
map("i", "<C-h>", "<Left>", { desc = "Go Left" })
map("i", "<C-j>", "<Down>", { desc = "Go Down" })
map("i", "<C-k>", "<Up>", { desc = "Go Up" })
map("i", "<C-l>", "<Right>", { desc = "Go Right" })
-- }}}

-- Indenting{{{
map("v", "<", "<gv", { desc = "Unindent line" })
map("v", ">", ">gv", { desc = "Indent line" })
-- }}}

-- Move Lines{{{
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move text down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move text up" })
map("v", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text up" })
map("v", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text down" })
map("x", "<A-j>", "<cmd>move '>+1<cr>gv-gv", { desc = "Move text up" })
map("x", "<A-k>", "<cmd>move '<-2<cr>gv-gv", { desc = "Move text down" })
-- }}}

-- Better Paste{{{
map("v", "p", '"_dP', { desc = "Paste no yank" })
map("n", "x", '"_x', { desc = "Delete character no yank" })
-- }}}

-- Vertical move and center{{{
map("n", "<C-d>", "<C-d>zz", { desc = "Up and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Down and center" })
-- }}}

-- Close floating window, notification and clear search with ESC{{{
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

map({ "n" }, "<Esc>", close_floating_and_clear_search, { desc = "Close floating windows, dismiss notifications, and clear search" })
-- }}}

-- Terminal{{{
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal" })
map("t", "<C-Up>", "<cmd>wincmd k<cr>", { desc = "Up from Terminal" })
map("t", "<C-Down>", "<cmd>wincmd j<cr>", { desc = "Down from Terminal" })
map("t", "<C-Left>", "<cmd>wincmd h<cr>", { desc = "Left from Terminal" })
map("t", "<C-Right>", "<cmd>wincmd l<cr>", { desc = "Right from Terminal" })

-- Terminal Toggle{{{
map({ "n", "t" }, "<C-\\>", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_win_close(win, true)
      vim.cmd("bwipeout! " .. buf) -- Completely remove the terminal buffer
      return
    end
  end
  vim.cmd("below split | terminal")
  vim.cmd("resize " .. math.floor(vim.o.lines * 0.4)) -- Adjust the height of the terminal split to 40% of the screen height
  vim.cmd("startinsert")
end, { desc = "Terminal" })
-- }}}

-- Ipython terminal REPL{{{
map({ "n", "t" }, "<leader>ti", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_win_close(win, true)
      vim.cmd("bwipeout! " .. buf) -- Completely remove the terminal buffer
      return
    end
  end
  vim.cmd("below split | terminal ipython --no-autoindent")
  vim.cmd("resize " .. math.floor(vim.o.lines * 0.4)) -- Adjust the height of the terminal split to 40% of the screen height
  vim.cmd("startinsert")
end, { desc = "Ipython Terminal REPL" })
-- }}}

-- Send line to terminal{{{
map("n", "<leader>tl", function()
  local term_buf = vim.fn.bufnr("term://*")

  if term_buf ~= -1 then
    local job_id = vim.b[term_buf].terminal_job_id
    local line = vim.api.nvim_get_current_line()
    vim.fn.chansend(job_id, line .. "\n")
  end
end, { desc = "Send Line To Terminal" })
-- }}}

-- Send visual selection to terminal{{{
map("v", "<leader>t", function()
  -- Yank the visual selection into the default register
  vim.cmd('normal! "vy')

  local term_buf = vim.fn.bufnr("term://*")

  if term_buf ~= -1 then
    local job_id = vim.b[term_buf].terminal_job_id
    local selection = vim.fn.getreg("v") -- Get the yanked text from register v

    -- Send the selection exactly as is to the terminal
    vim.fn.chansend(job_id, selection .. "\n")
  end
end, { desc = "Send Visual Selection To Terminal" })
-- }}}
-- }}}

-- Mix{{{
map("n", "<BS>", "X", { desc = "TAB as X in normal mode" })
map("n", "<A-a>", "<esc>ggVG<cr>", { desc = "Select all text" })
map("n", "<A-v>", "<C-q>", { desc = "Visual block mode" })
map("n", "<A-+>", "<C-a>", { desc = "Increment number" })
map("n", "<A-->", "<C-x>", { desc = "Decrement number" })
-- map("n", "<A-r>", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word cursor is on globally" })
-- map("n", "<A-s>", ":%s/<c-r><c-w>//g<left><left>", { desc = "replace word" })
-- map("n", "<leader>r", "*``cgn", { desc = "replace word under cursor" })
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })
-- }}}

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

-- {{{ terminal settings
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    -- Hide buffer name in the tabline for terminal buffers
    vim.opt_local.buflisted = false
    vim.cmd("setlocal nonumber norelativenumber")
  end,
})
-- }}}

-- {{{ open terminal at same location as opened file
vim.api.nvim_create_autocmd("BufEnter", {
  command = [[silent! lcd %:p:h]],
  group = mygroup,
  desc = "open terminal in same location as opened file",
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
  pattern = "*.lua",
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
-- }}}

-- markdown filetype{{{
-- pretoze snacks.dashboard pri otvarani markdown suborov nevedel spravne priradit filetype
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.md" },
  callback = function()
    vim.cmd("setlocal filetype=markdown")
  end,
})
-- }}}

-- htmldjango / jinja.html filetypes and comment{{{
local function select_html_filetype()
  local max_lines = math.min(50, vim.fn.line("$"))
  for n = 1, max_lines do
    local line = vim.fn.getline(n)
    if line:match("{{.*}}") or line:match("{%%%-?%s*(end.*|extends|block|macro|set|if|for|include|trans)%f[%W]") then
      vim.bo.filetype = "htmldjango"
      return
    end
  end
end

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.html", "*.htm" },
  callback = select_html_filetype
})

-- for commenting
vim.api.nvim_create_autocmd("FileType", {
  pattern = "htmldjango",
  callback = function()
    vim.bo.commentstring = "{# %s #}"
  end,
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

local function new_notebook(filename) -- {{{
  -- upravena povodna funkcia pomocou AI
  local path = filename .. ".ipynb"
  local file, err = io.open(path, "wb") -- Use "wb" to ensure binary mode (no BOM)

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
  end, 100) -- 100ms delay
end -- }}}

vim.api.nvim_create_user_command("NewNotebook", function(opts) -- {{{
  new_notebook(opts.args)
end, {
  nargs = 1,
  complete = "file",
}) -- }}}

-- keymap for new Jupyter notebook creation
map("n", "<leader>cj", function()
  local file_name = vim.fn.input("Notebook name: ")
  if file_name ~= "" then
    vim.cmd("NewNotebook " .. file_name)
  end
end, { desc = "Create Jupyter Notebook" })
--}}}

-- convert markdown/quarto to raw python code{{{
vim.api.nvim_create_user_command("ConvertMarkdownToPython", function()-- {{{
  local buf = 0
  local ft = vim.bo[buf].filetype
  if ft ~= "markdown" and ft ~= "quarto" then
    vim.notify("This command only works for Markdown or Quarto files", vim.log.levels.WARN)
    return
  end

  -- Get source and target filenames
  local source = vim.api.nvim_buf_get_name(buf)
  local base = vim.fn.fnamemodify(source, ":t:r")
  local filename = base .. ".py"

  -- Always use markdown parser regardless of filetype
  local parser = vim.treesitter.get_parser(buf, "markdown")
  local tree = parser:parse()[1]
  local root = tree:root()

  local query = vim.treesitter.query.parse("markdown", [[
    ((code_fence_content) @code)
  ]])

  local lines = {}

  for _, node in query:iter_captures(root, buf) do
    local text = vim.treesitter.get_node_text(node, buf)
    for _, line in ipairs(vim.fn.split(text, "\n")) do
      table.insert(lines, line)
    end
    table.insert(lines, "") -- Add blank line between blocks
  end

  -- Write to output file
  local file, err = io.open(filename, "w")
  if not file then
    vim.notify("Failed to write file: " .. err, vim.log.levels.ERROR)
    return
  end
  for _, line in ipairs(lines) do
    file:write(line .. "\n")
  end
  file:close()

  vim.cmd("edit " .. filename)

  -- After buffer loads, move imports to top
  vim.defer_fn(function()
    local py_buf = 0
    local py_parser = vim.treesitter.get_parser(py_buf, "python")
    local root = py_parser:parse()[1]:root()

    local py_query = vim.treesitter.query.parse("python", [[
      (import_statement) @imp
      (import_from_statement) @imp
    ]])

    local import_nodes = {}
    for _, node in py_query:iter_captures(root, py_buf) do
      table.insert(import_nodes, node)
    end

    table.sort(import_nodes, function(a, b) return a:start() < b:start() end)

    local lines_to_remove = {}
    local import_texts = {}

    for _, node in ipairs(import_nodes) do
      local s, _, e, _ = node:range()
      for i = s, e do lines_to_remove[i] = true end
      table.insert(import_texts, vim.treesitter.get_node_text(node, py_buf))
    end

    local buf_lines = vim.api.nvim_buf_get_lines(py_buf, 0, -1, false)
    for i = #buf_lines - 1, 0, -1 do
      if lines_to_remove[i] then table.remove(buf_lines, i + 1) end
    end

    local import_lines = {}
    for _, text in ipairs(import_texts) do
      for line in text:gmatch("[^\r\n]+") do
        table.insert(import_lines, line)
      end
    end
    table.insert(import_lines, "") -- Blank line after imports

    for i = #import_lines, 1, -1 do
      table.insert(buf_lines, 1, import_lines[i])
    end

    vim.api.nvim_buf_set_lines(py_buf, 0, -1, false, buf_lines)
  end, 100)
end, { desc = "Convert markdown or quarto code blocks to a Python script" })-- }}}

-- keymap for convert to raw python
map("n", "<leader>cp", "<cmd>ConvertMarkdownToPython<cr>", { desc = "Convert To Python Code" })
-- }}}

-- auto find and set python environment in project folder{{{
vim.api.nvim_create_user_command("SetProjectVenv", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local client = clients[1]

  if not client or not client.config or not client.config.root_dir then
    print("No LSP root found.")
    return
  end

  local root = client.config.root_dir
  local sep = package.config:sub(1,1) -- OS path separator
  local venv_dir = root .. sep .. ".venv"
  local python_path = venv_dir .. sep .. (sep == "\\" and "Scripts\\python.exe" or "bin/python")

  if vim.fn.filereadable(python_path) == 1 then
    vim.g.python3_host_prog = python_path
    vim.env.VIRTUAL_ENV = venv_dir
    print("Activated venv: " .. venv_dir)
  else
    print("No .venv found at: " .. venv_dir)
  end
end, {
  desc = "Set Python venv from LSP root",
})

vim.keymap.set("n", "<leader>pv", ":SetProjectVenv<CR>", { desc = "Set project .venv" })
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

-- }}}

-- {{{ [[ LAZY MANAGER ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- {{{
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
vim.opt.rtp:prepend(lazypath) -- }}}

require("lazy").setup({

  performance = { -- {{{
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        -- "matchparen", -- for highlights matching brackets
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  }, -- }}}

  spec = { -- {{{

    -- {{{ [ Colorscheme ]
    { "rebelot/kanagawa.nvim", -- {{{
      -- enabled = false,
      priority = 1000,
      config = function()
        require("kanagawa").setup({ -- {{{
          colors = { -- {{{
            palette = {
              -- fujiWhite = "#FEFEFA",
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
          }, -- }}}
          overrides = function(colors) -- {{{
            local theme = colors.theme
            return {
              WinSeparator = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
              -- change cmd popup menu colors
              Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_m1 },
              PmenuKind = { fg = theme.ui.shade0, bg = theme.ui.bg_m1 },
              PmenuExtra = { fg = theme.ui.shade0, bg = theme.ui.bg_m1 },
              -- -- PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2, italic = true },
              PmenuSel = { fg = colors.palette.surimiOrange, bg = theme.ui.bg_p2 },
              PmenuKindSel = { fg = colors.palette.surimiOrange, bg = theme.ui.bg_p2 },
              PmenuExtraSel = { fg = colors.palette.surimiOrange, bg = theme.ui.bg_p2 },
              PmenuSbar = { bg = theme.ui.bg_m1 },
              PmenuThumb = { bg = theme.ui.bg_p2 },
              -- change cmp items colors
              BlinkCmpMenuBorder = { link = "FloatBorder" },
              -- render-markdown headings
              RenderMarkdownH1Bg = { bg = theme.ui.bg_m1, fg = colors.palette.autumnRed },
              RenderMarkdownH2Bg = { bg = theme.ui.bg_m1, fg = colors.palette.autumnYellow },
              RenderMarkdownH3Bg = { bg = theme.ui.bg_m1, fg = colors.palette.autumnGreen },
              RenderMarkdownH4Bg = { bg = theme.ui.bg_m1, fg = colors.palette.oniViolet },
              RenderMarkdownH5Bg = { bg = theme.ui.bg_m1, fg = colors.palette.dragonBlue },
              RenderMarkdownH6Bg = { bg = theme.ui.bg_m1, fg = "#717C7C" },
              RenderMarkdownH1 = { fg = colors.palette.autumnRed },
              RenderMarkdownH2 = { fg = colors.palette.autumnYellow },
              RenderMarkdownH3 = { fg = colors.palette.autumnGreen },
              RenderMarkdownH4 = { fg = colors.palette.oniViolet },
              RenderMarkdownH5 = { fg = colors.palette.dragonBlue },
              RenderMarkdownH6 = { fg = "#717C7C" },
              -- mini.tabline
              MiniTablineCurrent = { bg = theme.ui.bg_m1, fg = colors.palette.surimiOrange }, -- buffer is current (has cursor in it).
              MiniTablineVisible = { bg = theme.ui.bg_m1, fg = "#717C7C" }, -- buffer is visible (displayed in some window).
              MiniTablineHidden = { bg = theme.ui.bg_m1, fg = "#717C7C" }, -- buffer is hidden (not displayed).
              MiniTablineModifiedCurrent = { bg = theme.ui.bg_p2, fg = colors.palette.surimiOrange }, -- buffer is modified and current.
              MiniTablineModifiedVisible = { bg = theme.ui.bg_p2, fg = "#717C7C" }, -- buffer is modified and visible.
              MiniTablineModifiedHidden = { bg = theme.ui.bg_p2, fg = "#717C7C" }, -- buffer is modified and hidden.
              -- MiniTablineFill = { bg = theme.ui.bg_m1, fg = colors.palette.surimiOrange }, -- unused right space of tabline.
              -- MiniTablineTabpagesection = { bg = theme.ui.bg_m1, fg = colors.palette.surimiOrange }, -- section with tabpage information.
              -- MiniTablineTrunc = { bg = theme.ui.bg_m1, fg = colors.palette.surimiOrange }, -- truncation symbols indicating more left/right tabs.
              -- Match VSCode Markdown Colorscheme
              -- https://github.com/rebelot/kanagawa.nvim/issues/207
              ["@markup.link.url.markdown_inline"] = { link = "Special" }, -- (url)
              ["@markup.link.label.markdown_inline"] = { link = "WarningMsg" }, -- [label]
              ["@markup.italic.markdown_inline"] = { link = "Exception" }, -- *italic*
              ["@markup.raw.markdown_inline"] = { link = "String" }, -- `code`
              ["@markup.list.markdown"] = { link = "Function" }, -- + list
              ["@markup.quote.markdown"] = { link = "@spell" }, -- > blockcode
              ["@markup.list.checked.markdown"] = { link = "WarningMsg" }, -- checked list item
            }
          end, -- }}}
        }) -- }}}
        vim.cmd.colorscheme("kanagawa")
      end,
    }, -- }}}
    -- }}}

    -- {{{ [ Treesitter ]
    { "nvim-treesitter/nvim-treesitter",
      -- enabled = false,
      version = false,
      build = ":TSUpdate",
      -- lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
      -- event = { "BufReadPre", "BufNewFile" },
      -- cmd = { "TSBufEnable" },
      dependencies = { -- {{{
        -- "windwp/nvim-ts-autotag",
        "nvim-treesitter/nvim-treesitter-textobjects",
      }, -- }}}
      main = "nvim-treesitter.configs",
      opts = { -- {{{
        ensure_installed = { -- {{{
          "python",
          "bash",
          "lua",
          "html",
          "scss",
          "markdown",
          "markdown_inline",
          "query",
          "vim",
          "vimdoc",
          "yaml",
          "typst",
          "latex",
          "regex",
        }, -- }}}
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { -- oznacujem casti definovane pomocou treesitteru
          enable = true,
          keymaps = {
            init_selection = "<Enter>",
            node_incremental = "<Enter>",
            scope_incremental = false,
            node_decremental = "<Backspace>",
          },
        },
        textobjects = {
          move = { -- pre jump medzi blokmi kodu v markdown, quarto, jupyternotebooks
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]c"] = { query = "@code_cell.inner", desc = "Next Cell" },
            },
            goto_previous_start = {
              ["[c"] = { query = "@code_cell.inner", desc = "Previous Cell" },
            },
          },
          select = { -- pre quarto, markdown, jupyter notebooks definove v mini.ai
          },
          swap = { -- funguje len pre quarto a markdown, ak su pod spolocnym headrom (hlavickou)
            enable = true,
            swap_next = {
              ["]s"] = { query = "@code_cell.outer", desc = "Swap Next Cell" },
            },
            swap_previous = {
              ["[s"] = { query = "@code_cell.outer", desc = "Swap Previous Cell" },
            },
          },
        },
      }, -- }}}
    },
    -- }}}

    -- {{{ [ Mason, Formatter, Linter ]
    { "williamboman/mason.nvim",-- {{{
      -- enable = false,
      lazy = true,
      cmd = { "Mason", "MasonInstallAll" },
      config = function()
        local ensure_installed = {
          "bash-language-server",
          "emmet-ls",
          "lua-language-server",
          "basedpyright",
          "marksman",
          "tinymist",
          "json-lsp",
          "htmx-lsp",
          --formatters
          "beautysh",
          "prettier",
          "stylua",
          "ruff",
          "black",
          -- linters
          "shellcheck",
          "eslint_d",
          "djlint",
          "htmlhint",
          -- "vale",
        }
        vim.api.nvim_create_user_command("MasonInstallAll", function()
          for _, server in ipairs(ensure_installed) do
            vim.cmd("MasonInstall " .. server)
          end
        end, {})

        require("mason").setup()
      end,
    },-- }}}

    { -- Formatter{{{
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      cmd = { "ConformInfo" },
      keys = {
        { "<leader>lf", function() require("conform").format({ async = true, lsp_fallback = true }) end, mode = "", desc = "Formatting",},
      },
      config = function()
        require("conform").setup({
          formatters_by_ft = {
            bash = { "beautysh" },
            javascript = { "prettier" },
            css = { "prettier" },
            lua = { "stylua" },
            html = { "prettier" },
            htmldjango = { "djlint" },
            -- python = { "ruff_fix", "ruff_organize_imports", "black", lsp_format = "first" },
            python = { "ruff_format", "black" },
            ["_"] = { "trim_whitespace", "trim_newlines" },
          },
          format_on_save = function(bufnr)
            local disable_filetypes = { lua = true, json = true }
            if disable_filetypes[vim.bo[bufnr].filetype] then
              return nil -- Disable format on save
            end
            return {
              timeout_ms = 500,
              lsp_fallback = true,
            }
          end,
        })
      end,
    }, -- }}}

    { -- Linter{{{
      "mfussenegger/nvim-lint",
      event = { "BufWritePost", "BufReadPost", "InsertLeave" },
      config = function()
        require("lint").linters_by_ft = {
          bash = { "shellcheck" },
          javascript = { "eslint_d" },
          python = { "ruff" },
          html = { "htmlhint" },
          htmldjango = { "djlint" },
          -- markdown = { "vale" },
        }
        -- Automatically run linters on file events
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
          callback = function()
            require("lint").try_lint()
          end,
        })
      end,
    }, -- }}}
    -- }}}

    -- {{{ [ Autocompletion ]
    { "saghen/blink.cmp", -- {{{
      enabled = true,
      event = "InsertEnter",
      -- dependencies = "rafamadriz/friendly-snippets",
      version = "1.*",
      opts = { -- {{{
        fuzzy = { implementation = "prefer_rust" }, -- "prefer_rust" or "lua"
        keymap = {
          preset = "enter",
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "normal",
        },
        completion = {
          accept = { auto_brackets = { enabled = true } },
          menu = {
            border = "rounded",
            draw = {
              columns = {
                { "kind_icon" },
                { "label", "label_description", gap = 1 },
                { "source_name", "kind", gap = 1 },
              },
            },
          },
          list = {
            selection = {
              preselect = false,
            },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 250,
            window = { border = "rounded" },
          },
        },
        signature = {
          enabled = true,
          window = { border = "rounded" },
        },
        -- snippets = { preset = 'mini_snippets' },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
          providers = {},
        },
        -- window = {
        --   completion = {
        --     border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },  -- Border chars
        --     winhighlight = 'Normal:CmpPmenu,CursorLine:CmpPmenuSel,Search:None',
        --   },
        --   documentation = {
        --     border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },  -- Border chars
        --   },
        -- },
      }, -- }}}
      opts_extend = { "sources.default" },
    }, -- }}}
    -- }}}

    -- {{{ [ Snack.nvim collection ]
    { "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      -- enabled = false,
      opts = {
        styles = {},
        dashboard = { -- {{{
          enabled = true,
          preset = {
            keys = {
              { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
              { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
              -- { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
              { icon = " ", key = "o", desc = "Old Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
              { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",},
              { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.dashboard.pick('projects', {dev = '~/git-repos/', confirm='picker', recent = false})",},
              { icon = " ", key = "s", desc = "Sessions", action = ":lua MiniSessions.select()",},
              { icon = "󱙓 ", key = "N", desc = "Notes", action = ":lua Snacks.dashboard.pick('files', {cwd = osvar.ObsidianPath()})",},
              -- { icon = " ", key = "S", desc = "Restore Session", section = "session" },
              { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
            header = dashboard_header,
          },
          sections = {
            -- { section = "header" },
            { section = "terminal",
              cmd = (osvar.os_type == "windows")
                and ('powershell -NoLogo -Command "Write-Host \'Hello ' .. osvar.username .. '\' -ForegroundColor Magenta"')
                or  ("echo '\27[1;35mHello " .. osvar.username .. "\27[0m'"),
              indent = 28, padding = 2, height = 1 },
            { section = "terminal",
              cmd = (osvar.os_type == "windows")
                and ('powershell -Command "Invoke-RestMethod wttr.in/' .. city .. '?format=`"%l: %c %t %w %T`""')
                or  ('curl -s "wttr.in/' .. city .. '?format=%l:+%c+%t+%w+%T\\n" | sed \'s/.*/\\x1b[34m&\\x1b[0m/\''),
              indent = 8, padding = 2, height = 1 },
            { section = "keys", gap = 1, padding = 1 },
            { section = "startup", padding = 2 },
          },
        }, -- }}}
        image = { -- {{{
          -- enabled = true,
          enabled = osvar.os_type ~= "wsl",
          formats = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif", "mp4", "mov", "avi", "mkv", "webm", "pdf",},
          force = true,
        }, -- }}}
        input = {-- {{{
          enabled = true,
          win = {
            style = "input",
            keys = {
              i_esc = { "<esc>", { "cmp_close", "cancel", "stopinsert" }, mode = "i", expr = true },
            },
          },
        },-- }}}
        lazygit = { enabled = true },
        notifier = { enabled = true },
        picker = { -- {{{
          enabled = true,
          layout = { preset = "ivy", preview = false },
          sources = {
            explorer = { -- {{{
              auto_close = true,
              win = {
                list = {
                  keys = {
                    ["<c-h>"] = "toggle_hidden",
                    ["<RIGHT>"] = "confirm",
                    ["<LEFT>"] = "explorer_close", -- close directory
                  },
                },
              },
            }, -- }}}
          },
        }, -- }}}
        quickfile = { enabled = true }, -- When doing nvim somefile.txt, it will render the file as quickly as possible, before loading your plugins
        rename = { enabled = true },
        scope = { enabled = false }, -- Scope detection based on treesitter or indent (alternative mini.indentscope)
        scroll = { enabled = false }, -- Smooth scrolling for Neovim. Properly handles scrolloff and mouse scrolling (alt mini.animate)
        statuscolumn = { enabled = false },
        words = { enabled = true },
      },
      keys = { -- {{{
        { "]]", mode = { "n", "t" }, function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference",},
        { "[[", mode = { "n", "t" }, function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference",},
        -- {"<leader>D", function() Snacks.dashboard.open() end, desc = "Dashboard",},
        -- Top Pickers & Explorer
        { "<leader>e", function() Snacks.explorer({ layout = { preset = "sidebar", layout = { position = "left" } } }) end, desc = "File Explorer",},
        { "<leader>E", function() vim.cmd("lcd D:\\") Snacks.explorer.open({ layout = { preset = "sidebar", layout = { position = "left" } } }) end, desc = "File Explorer D drive",},
        { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files",},
        { "<leader>f,", function() Snacks.picker.buffers() end, desc = "Buffers",},
        -- find
        { "<leader>ff", function() Snacks.picker.files() end, desc = "Files",},
        { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File",},
        -- {"<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files",},
        { "<leader>fp", function() Snacks.picker.projects({ dev = "~/git-repos/", recent = false }) end, desc = "Find Projects",},
        { "<leader>fo", function() Snacks.picker.recent() end, desc = "Old/Recent Files",},
        { "<leader>fR", function() Snacks.rename.rename_file() end, desc = "Rename File",},
        -- git
        -- {"<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit",},
        -- {"<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches",},
        -- {"<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log",},
        -- {"<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line",},
        -- {"<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status",},
        -- {"<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash",},
        -- {"<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)",},
        -- {"<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File",},
        -- Grep
        { "<leader>gg", function() Snacks.picker.grep() end, desc = "Grep",},
        { "<leader>gl", function() Snacks.picker.lines() end, desc = "Grep Buffer Lines",},
        { "<leader>gb", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers",},
        { "<leader>gw", function() Snacks.picker.grep_word() end, desc = "Grep Word or Selection", mode = { "n", "x" },},
        -- search
        { '<leader>f"', function() Snacks.picker.registers() end, desc = "Search Registers",},
        { "<leader>f/", function() Snacks.picker.search_history() end, desc = "Search History",},
        { "<leader>fa", function() Snacks.picker.autocmds() end, desc = "Search Autocmds",},
        { "<leader>f:", function() Snacks.picker.commands() end, desc = "Search Commands",},
        { "<leader>fC", function() Snacks.picker.command_history() end, desc = "Command History",},
        { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Search Diagnostics",},
        { "<leader>fD", function() Snacks.picker.diagnostics_buffer() end, desc = "Search Buffer Diagnostics",},
        { "<leader>fh", function() Snacks.picker.help() end, desc = "Search Help Pages",},
        { "<leader>fH", function() Snacks.picker.highlights() end, desc = "Search Highlights",},
        { "<leader>fi", function() Snacks.picker.icons() end, desc = "Search Icons",},
        { "<leader>fj", function() Snacks.picker.jumps() end, desc = "Search Jumps",},
        { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Search Keymaps",},
        { "<leader>fl", function() Snacks.picker.loclist() end, desc = "Search Location List",},
        { "<leader>fm", function() Snacks.picker.marks() end, desc = "Search Marks",},
        { "<leader>fM", function() Snacks.picker.man() end, desc = "Search Man Pages",},
        -- {"<leader>fp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec",},
        { "<leader>fq", function() Snacks.picker.qflist() end, desc = "Search Quickfix List",},
        -- {"<leader>sR", function() Snacks.picker.resume() end, desc = "Search Resume",},
        { "<leader>fu", function() Snacks.picker.undo() end, desc = "Search Undo History",},
        { "<leader>fs", function() Snacks.picker.colorschemes() end, desc = "Search Colorschemes",},
        { "<leader>ft", function() Snacks.picker.treesitter() end, desc = "Search Treesitter",},
        { "<leader>fN", function() Snacks.picker.notifications() end, desc = "Notification History",},
        -- LSP
        { "<leader>ly", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition",},
        { "<leader>ls", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols",},
        { "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols",},
      }, -- }}}
    },
    -- }}}

    -- {{{ [ Mini.nvim collection ]
    { "echasnovski/mini.nvim",
      -- event = "BufReadPre",
      event = "VeryLazy",
      enabled = true,
      config = function()
        local ai = require("mini.ai") -- {{{
        local gen_ai_spec = require("mini.extra").gen_ai_spec
        local ts_spec = ai.gen_spec.treesitter({
          a = { "@code_cell.outer", "@block.outer", "@conditional.outer", "@loop.outer" },
          i = { "@code_cell.inner", "@block.inner", "@conditional.inner", "@loop.inner" },
        })
        require("mini.ai").setup({
          n_lines = 500,
          custom_textobjects = {
            -- Code blocks for quarto, markdown, python jupyter notebooks etc.
            -- musim vytvorit after/queries/.. textobjects
            -- sluzi na visual selection
            -- jump medzi blokmi je definovany v nvim-treesitter-textobjects
            -- funkcia python_code_cell je v [[ DETECT OS]]
            c = function(ai_type)
              local cell = python_code_cell(ai_type)
              if cell ~= nil then
                return cell
              else
                return ts_spec(ai_type)
              end
            end,

            -- Brackets and quotes
            ["("] = { "%b()", "^.().*().$" },
            ["["] = { "%b[]", "^.().*().$" },
            ["{"] = { "%b{}", "^.().*().$" },
            ['"'] = { '%b""', "^.().*().$" },
            ["'"] = { "%b''", "^.().*().$" },
            ["`"] = { "%b``", "^.().*().$" },

            -- Word with case
            e = {{ "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" }, "^().*()$",},
            -- From mini.extra
            B = gen_ai_spec.buffer(),
            D = gen_ai_spec.diagnostic(),
            I = gen_ai_spec.indent(),
            L = gen_ai_spec.line(),
            N = gen_ai_spec.number(),
          },
        }) -- }}}

        require("mini.align").setup()

        require("mini.basics").setup({ -- {{{
          options = {
            basic = false,
            extra_ui = false,
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
        }) -- }}}

        require("mini.bracketed").setup({ -- {{{
          buffer = { suffix = "b", options = {} },
          comment = { suffix = "x", options = {} },
          conflict = { suffix = "", options = {} },
        }) -- }}}

        require("mini.bufremove").setup()

        local miniclue = require("mini.clue") -- {{{
        -- Add a-z/A-Z marks.{{{
        local function mark_clues()
          local marks = {}
          vim.list_extend(marks, vim.fn.getmarklist(vim.api.nvim_get_current_buf()))
          vim.list_extend(marks, vim.fn.getmarklist())

          return vim
            .iter(marks)
            :map(function(mark)
              local key = mark.mark:sub(2, 2)
              if not string.match(key, '^%a') then
                return nil
              end

              local desc
              if mark.file then
                desc = vim.fn.fnamemodify(mark.file, ':p:~:.')
              elseif mark.pos[1] and mark.pos[1] ~= 0 then
                local line_num = mark.pos[2]
                local lines = vim.fn.getbufline(mark.pos[1], line_num)
                if lines and lines[1] then
                  desc = string.format('%d: %s', line_num, lines[1]:gsub('^%s*', ''))
                end
              end

              if desc then
                return {
                  { mode = 'n', keys = string.format("`%s", key), desc = desc },
                  { mode = 'n', keys = string.format("'%s", key), desc = desc },
                }
              end
            end)
            :flatten()
            :filter(function(clue) return clue ~= nil end)
            :totable()
        end-- }}}

        -- Clues for recorded macros.{{{
        local function macro_clues()
          local res = {}
          for _, register in ipairs(vim.split('abcdefghijklmnopqrstuvwxyz', '')) do
            local keys = string.format('"%s', register)
            local ok, desc = pcall(vim.fn.getreg, register, 1)
            if ok and desc ~= '' then
              table.insert(res, { mode = 'n', keys = keys, desc = desc })
              table.insert(res, { mode = 'v', keys = keys, desc = desc })
            end
          end

          return res
        end-- }}}

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
            { mode = "n", keys = "[" },
            { mode = "n", keys = "]" },
          },
          clues = {
            -- Enhance this by adding descriptions for <Leader> mapping groups
            miniclue.gen_clues.builtin_completion(),
            miniclue.gen_clues.g(),
            miniclue.gen_clues.marks(),
            miniclue.gen_clues.registers(),
            -- miniclue.gen_clues.windows(),
            miniclue.gen_clues.z(),
            -- Custom extras.
            mark_clues,
            macro_clues,
            -- moje skratky - normal mode
            { mode = "n", keys = "<Leader>c", desc = "+Code/Create" },
            { mode = "n", keys = "<Leader>f", desc = "+Find/Files" },
            { mode = "n", keys = "<Leader>g", desc = "+Grep" },
            { mode = "n", keys = "<Leader>l", desc = "+LSP" },
            { mode = "n", keys = "<Leader>m", desc = "+Mini" },
            { mode = "n", keys = "<Leader>ms", desc = "+Sessions" },
            { mode = "n", keys = "<Leader>n", desc = "+Notes" },
            { mode = "n", keys = "<Leader>nl", desc = "+Links" },
            { mode = "n", keys = "<Leader>p", desc = "+Python" },
            { mode = "n", keys = "<Leader>t", desc = "+Terminal" },
            { mode = "n", keys = "<Leader>w", desc = "+Window" },
            { mode = "n", keys = "<Leader>wl", desc = "+Layout" },
            { mode = "n", keys = "<Leader>q", desc = "+Quarto" },
            { mode = "n", keys = "<Leader>qr", desc = "+Runner" },
            { mode = "n", keys = "<Leader>i", desc = "+Image" },
            { mode = "x", keys = "<Leader>n", desc = "+Notes" },
            { mode = "x", keys = "<Leader>g", desc = "+Grep" },
            { mode = "x", keys = "<Leader>p", desc = "+Python" },
            { mode = "x", keys = "<Leader>l", desc = "+LSP" },
          },
          window = {
            delay = 300,
          },
        }) -- }}}

        require("mini.comment").setup({-- {{{
          options = {},
          mappings = (osvar.os_type == "linux")
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
            },
        }) -- }}}

        --         local completion = require("mini.completion")-- {{{
        --         local opts = { filtersort = "fuzzy" }
        --         local process_items = function(items, base)
        --           return MiniCompletion.default_process_items(items, base, opts)
        --         end
        --         require("mini.icons").tweak_lsp_kind() -- for icon showing
        --         completion.setup({
        --           delay = { completion = 50, info = 50, signature = 50 },
        --           lsp_completion = {
        --             source_func = "completefunc", -- omnifunc
        --             auto_setup = true,
        --             process_items = process_items,
        --             snippet_insert = MiniSnippets,
        --           },
        --         })
        -- -- }}}

        local minifiles = require("mini.files")-- {{{

        -- Create mappings which use data from entry under cursor{{{
        -- yank in register full path of entry under cursor
        local yank_path = function()
          local path = (minifiles.get_fs_entry() or {}).path
          if path == nil then return vim.notify('Cursor is not on valid entry') end
          vim.fn.setreg(vim.v.register, path)
        end

        -- set focused directory as current working directory
        local set_cwd = function()
          local path = (minifiles.get_fs_entry() or {}).path
          if path == nil then return vim.notify('Cursor is not on valid entry') end
          vim.fn.chdir(vim.fs.dirname(path))
        end

        vim.api.nvim_create_autocmd('User', {
          pattern = 'MiniFilesBufferCreate',
          callback = function(args)
            local b = args.data.buf_id
            vim.keymap.set('n', 'gy', yank_path, { buffer = b, desc = 'Yank path' })
            vim.keymap.set('n', 'g~', set_cwd,   { buffer = b, desc = 'Set cwd' })
          end,
        })
        -- }}}

        minifiles.setup({
          mappings = {
            close = "<ESC>",
            go_in = "<Right>",
            go_in_plus = "<CR>",
            go_out = "<Left>",
            go_out_plus = "H",
            mark_goto = "'",
            mark_set = "m",
            reset = "<BS>",
            reveal_cwd = "@",
            show_help = "g?",
            synchronize = "=",
            trim_left = "<",
            trim_right = ">",
          },
        })
        map( "n", "<leader>-", function() if not MiniFiles.close() then MiniFiles.open() end end, { desc = "Mini files" })
        -- }}}

        local hipatterns = require("mini.hipatterns") -- {{{
        hipatterns.setup({
          highlighters = {
            -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
            fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
            hack  = { pattern = "%f[%w]()HACK()%f[%W]", group  = "MiniHipatternsHack" },
            todo  = { pattern = "%f[%w]()TODO()%f[%W]", group  = "MiniHipatternsTodo" },
            note  = { pattern = "%f[%w]()NOTE()%f[%W]", group  = "MiniHipatternsNote" },

            -- Highlight hex color strings (`#rrggbb`) using that color
            hex_color = hipatterns.gen_highlighter.hex_color(),
          },
        })
        map( "n", "\\H", function()require("mini.hipatterns").toggle()end, { desc = "Toggle 'Hipatterns'" })
        -- }}}

        require("mini.icons").setup()

        require("mini.jump2d").setup({ -- {{{
          mappings = {
            start_jumping = ",",
          },
        }) -- }}}

        require("mini.pairs").setup({ -- {{{
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
            -- Prevents the action if the cursor is just before any character or next to a "\".
            ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\][%s%)%]%}]',},
            ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\][%s%)%]%}]',},
            ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\][%s%)%]%}]',},
            -- This is default (prevents the action if the cursor is just next to a "\").
            [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
            [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
            ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
            ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\].", register = { cr = false } },
            [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\].", register = { cr = false } },
            -- Prevents the action if the cursor is just before or next to any character.
            ['"'] = {action = 'closeopen', pair = '""', neigh_pattern = '[^%w][^%w]', register = { cr = false },},
            ["'"] = {action = 'closeopen', pair = "''", neigh_pattern = '[^%w][^%w]', register = { cr = false },},
            ['`'] = {action = 'closeopen', pair = '``', neigh_pattern = '[^%w][^%w]', register = { cr = false },},
          },
        }) -- }}}

        -- require("mini.pick").setup()

        require("mini.sessions").setup() -- {{{
        map( "n", "<leader>msw", function()vim.ui.input({ prompt = "Session name: " }, function(input) if input and input ~= "" then MiniSessions.write(input) end end)end, { desc = "Session Write" })
        map( "n", "<leader>mss", "<cmd>lua MiniSessions.select()<cr>", { desc = "Session Select/Read" })
        map( "n", "<leader>msD", "<cmd>lua MiniSessions.select('delete')<cr>", { desc = "Session Delete" })
        -- }}}

        -- local snippets = require("mini.snippets")-- {{{
        -- local gen_loader = require('mini.snippets').gen_loader
        -- snippets.setup({
        --   snippets = {
        --     -- Load per-language snippets from runtimepath, like ~/.config/nvim/snippets/python.json
        --     gen_loader.from_lang({ path = vim.fn.stdpath('config') .. '/snippets' }),
        --   },
        -- })
        -- -- Start snippet LSP server for completion integration
        -- snippets.start_lsp_server()
        -- -- }}}

        require("mini.splitjoin").setup({ -- {{{
          mappings = {
            toggle = "gS",
            split = "gk",
            join = "gj",
          },
        }) -- }}}

        require("mini.surround").setup({ -- {{{
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
            ["l"] = { output = { left = "[", right = "]()" } },
          },
        }) -- }}}

        local statusline = require("mini.statusline") -- {{{

        -- VS Code-like theme {{{
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

        -- Set highlights for different modes
        local function set_statusline_highlights()
          local hl_groups = {
            MiniStatuslineModeNormal  = { fg = colors.white, bg = colors.purple, style = "normal" },
            MiniStatuslineModeInsert  = { fg = colors.white, bg = colors.blue, style   = "normal" },
            MiniStatuslineModeVisual  = { fg = colors.white, bg = colors.green, style  = "normal" },
            MiniStatuslineModeReplace = { fg = colors.white, bg = colors.orange, style = "normal" },
            MiniStatuslineModeCommand = { fg = colors.white, bg = colors.red, style    = "normal" },
            MiniStatuslineModeOther   = { fg = colors.white, bg = colors.black, style  = "normal" },
            MiniStatuslineInactive    = { fg = colors.grey,  bg = colors.black },
            -- MiniStatuslineDevinfo     = { fg = colors.white, bg = colors.grey },
            -- MiniStatuslineFilename    = { fg = colors.white, bg = colors.grey, style = "normal" },
            -- MiniStatuslineFileinfo    = { fg = colors.white, bg = colors.grey },
          }

          for group, opts in pairs(hl_groups) do
            vim.api.nvim_set_hl(0, group, { fg = opts.fg, bg = opts.bg, bold = opts.style == "bold" })
          end
        end

        -- Apply colors initially
        set_statusline_highlights()

        -- Ensure colors stay the same after switching themes
        vim.api.nvim_create_autocmd("ColorScheme", {
          pattern = "*",
          callback = set_statusline_highlights,
        }) -- }}}

        -- Function to show macro recording status{{{
        local function macro_recording()
          local reg = vim.fn.reg_recording()
          if reg == "" then
            return ""
          end -- Return empty string if no macro is being recorded
          return string.format("󰑋 @%s", reg)
        end -- }}}

        -- Function to show the active Python virtual environment{{{
        local function python_venv()
          local venv = os.getenv("VIRTUAL_ENV") -- Get virtual environment path
          if not venv or venv == "" then
            return ""
          end -- Return empty string if no venv

          local venv_name = vim.fn.fnamemodify(venv, ":t") -- Extract only the folder name
          return string.format("󰌠 %s", venv_name)
        end -- }}}

        -- -- Function to show the active Molten status{{{
        -- local function molten_init()
        --   if not package.loaded["molten.status"] then
        --     return "M:X"
        --   end
        --
        --   local ok, molten_status = pcall(require, "molten.status")
        --   if not ok or type(molten_status.initialized) ~= "function" then
        --     return "M:X"
        --   end
        --
        --   local success, status = pcall(molten_status.initialized)
        --   return success and status == "Molten" and "M:A" or "M:X"
        -- end-- }}}

        -- -- Function to show buffer counts{{{
        -- local function buffer_counts()
        --   local loaded_buffers = #vim.tbl_filter(function(buf)
        --     return vim.fn.buflisted(buf) ~= 0
        --   end, vim.api.nvim_list_bufs())
        --   local modified_buffers = #vim.tbl_filter(function(buf)
        --     return vim.bo[buf].modified
        --   end, vim.api.nvim_list_bufs())
        --   return string.format("󰈔 [%d:%d+]", loaded_buffers, modified_buffers)
        -- end -- }}}

        statusline.setup({ -- {{{
          use_icons = true,
          content = {
            inactive = function()
              return MiniStatusline.combine_groups({
                { hl = "MiniStatuslineInactive", strings = { MiniStatusline.section_filename({ trunc_width = 140 }) } },
              })
            end,

            active = function()
              local mode, mode_hl = MiniStatusline.section_mode({ trunc_width       = 120 })
              local diagnostics   = MiniStatusline.section_diagnostics({trunc_width = 75, icon = "", signs = { ERROR = " ", WARN = " ", INFO = " ", HINT = "󰌵 " },})
              local lsp           = MiniStatusline.section_lsp({ trunc_width        = 75, icon = "" })
              local filename      = MiniStatusline.section_filename({ trunc_width   = 140 })
              local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width   = 1000 })
              local location      = "%l,%c"
              -- local buffer_counts   = buffer_counts()
              local macro_recording = macro_recording()
              -- local molten_init  = molten_init()
              local python_venv     = python_venv()

              return MiniStatusline.combine_groups({
                { hl = mode_hl, strings = { fileinfo, diagnostics } },
                "%<", -- Mark general truncate point
                { hl = mode_hl, strings = { filename, macro_recording } },
                "%= ", -- End left alignment
                { hl = mode_hl, strings = { lsp, python_venv, location },},
              })
            end,
          },
        }) -- }}}
        -- }}}

        require("mini.tabline").setup()

        require("mini.trailspace").setup() -- {{{
        vim.api.nvim_create_autocmd("BufWritePre", {
          callback = function()
            MiniTrailspace.trim()
            MiniTrailspace.trim_last_lines()
          end,
          desc = "Trim trailing whitespace and empty lines on save",
        }) -- }}}
      end,
    },
    -- }}}

    -- {{{ [ Notes ]
    { "zk-org/zk-nvim", -- {{{
      -- enabled = false,
      event = {
        "BufReadPost *.md",
        "BufNewFile  *.md",
      },
      config = function() -- {{{
        require("zk").setup({
          picker = "snacks_picker",
        })
        -- # custom command
        require("zk.commands").add("ZkFromLink", function()
          local line = vim.fn.getline(".")
          local col = vim.fn.col(".")
          local start_pos = line:sub(1, col):find("%[%[[^%]]*$")
          local end_pos = line:find("%]%]", col)

          if start_pos and end_pos then
            local title = line:sub(start_pos + 2, end_pos - 1)
            require("zk").new({ title = title, dir = osvar.ObsidianPath() .. "/inbox" })
          else
            print("No valid [[wikilink]] under cursor.")
          end
        end)
      end, -- }}}
      keys = { -- {{{
        { "<leader>nn", mode = "n", function() vim.ui.input({ prompt = "Title: " }, function(title) if not title then return end if title ~= "" then require("zk").new({ title = title, dir = osvar.ObsidianPath() .. "/inbox" }) else return end end) end, desc = "ZK New Note", noremap = true, silent = true},
        { "<leader>ns", mode = "n", function() Snacks.picker.files({ cwd = osvar.ObsidianPath() }) end, desc = "Search Note", noremap = true, silent = true },
        { "<leader>nD", mode = "n", ":lua local f=vim.fn.expand('%:p'); if vim.fn.confirm('Delete '..f..'?', '&Yes\\n&No') == 1 then os.remove(f); vim.cmd('bd!'); end<cr>", desc = "Delete Note", noremap = true, silent = true,},
        { "<leader>nt", mode = "n", "<cmd>ZkTags<cr>", desc = "Open Tags" },
        { "<leader>nq", mode = "n", "<cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<cr>", desc = "Search Query" },
        { "<leader>nl", mode = "n", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Follow Link" },
        { "<leader>ni", mode = "n", "<cmd>ZkInsertLink<cr>", desc = "Insert Link" },
        { "<leader>nb", mode = "n", "<cmd>ZkBacklinks<cr>", desc = "Backlinks" },
        { "<leader>nL", mode = "n", "<cmd>ZkLinks<cr>", desc = "Open Notes Linked To Buffer" },
        { "<leader>nN", mode = "n", "<cmd>ZkFromLink<cr>", desc = "Create Note From Link" },
        { "<leader>nf", mode = "v", ":'<,'>ZkMatch<cr>", desc = "Search Note Matching Visual Selection" },
        { "<leader>nt", mode = "v", ":'<,'>ZkNewFromTitleSelection<CR>", desc = "New Note From Title" },
        { "<leader>nc", mode = "v", ":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>", desc = "New Note From Content Selection" },
      }, -- }}}
    }, -- }}}

    { "HakonHarnes/img-clip.nvim",-- {{{
      opts = {
        default = {
          relative_to_current_file = true,
          dir_path = ".",
          file_name = function()
            local base = vim.fn.expand("%:t:r") -- note name without extension
            local time = os.date("%H%M%S")
            return base .. "-" .. time
          end,
          prompt_for_file_name = false,
        },
      },
      keys = {
        { "<leader>ip", "<cmd>PasteImage<cr>", desc = "Image Paste" },
        { "<leader>ik", function() Snacks.image.hover() end, desc = "Image Hoover" },
      },
    },-- }}}

    { "MeanderingProgrammer/render-markdown.nvim", -- {{{
      -- enabled = false,
      event = {
        "BufReadPost *.md",
        "BufNewFile  *.md",
        "BufReadPost *.qmd",
        "BufNewFile  *.qmd",
        "BufEnter  *.ipynb", -- pre jupyternotebooks
      },
      opts = {
        file_types = { "markdown", "quarto" },
        heading = {
          icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
        },
        completions = { blink = { enabled = true } },
        latex = {
          enabled = (osvar.os_type ~= "windows"),
          converter = "latex2text",
          highlight = "RenderMarkdownMath",
          top_pad = 0,
          bottom_pad = 0,
        },
      },
      keys = { -- {{{
        { "\\m", mode = { "n" }, "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle 'markdown preview'", noremap = true, silent = true,},
      }, -- }}}
    }, -- }}}

    { "obsidian-nvim/obsidian.nvim", -- {{{
      -- je to fork pretoze "epwalsh/obsidian.nvim" neobsahuje zatial "blink-cmp" a "snacks.picker"
      enabled = false,
      version = "*", -- recommended, use latest release instead of latest commit
      lazy = true,
      dependencies = { -- {{{
        "nvim-lua/plenary.nvim",
      }, -- }}}
      opts = { -- {{{
        ui = { enable = false }, -- vypnute ui pre doplnok render-markdown
        disable_frontmatter = true,
        workspaces = {
          {
            name = "Obsidian",
            path = osvar.ObsidianPath(), -- definovane v [[ DETECT OS ]]
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
          nvim_cmp = false,
          blink = true,
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
        picker = {
          -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
          name = "snacks.pick",
          -- Optional, configure key mappings for the picker. These are the defaults.
          -- Not all pickers support all mappings.
          note_mappings = {
            -- Create a new note from your query.
            new = "<C-x>",
            -- Insert a link to the selected note.
            insert_link = "<C-l>",
          },
          tag_mappings = {
            -- Add tag(s) to current note.
            tag_note = "<C-x>",
            -- Insert a tag at the current location.
            insert_tag = "<C-l>",
          },
        },
      }, -- }}}
      keys = { -- {{{
        {
          "<leader>ns",
          function()
            Snacks.picker.files({ cwd = osvar.ObsidianPath() })
          end,
          desc = "Search Note",
        },
        -- { "<leader>nn", mode = "n", function()osvar.ObsidianNewNote(false)end, desc = "new note", noremap = true, silent = true },
        {
          "<leader>nn",
          mode = "n",
          function()
            osvar.ObsidianNewNote(true, "basic")
          end,
          desc = "New Note Basic",
          noremap = true,
          silent = true,
        },
        { "<leader>nt", mode = "n", ":ObsidianTemplate<cr>", desc = "Template Pick" },
        { "<leader>ni", mode = "n", ":ObsidianPasteImg<cr>", desc = "Image Paste", noremap = true, silent = true },
        {
          "<leader>nc",
          mode = "n",
          ":ObsidianToggleCheckbox<cr>",
          desc = "Checkbox Toggle",
          noremap = true,
          silent = true,
        },
        { "<leader>nq", mode = "n", ":ObsidianQuickSwitch<cr>", desc = "Switch Note", noremap = true, silent = true },
        { "<leader>nlf", mode = "n", ":ObsidianFollowLink<cr>", desc = "Link Follow", noremap = true, silent = true },
        { "<leader>nlb", mode = "n", ":ObsidianBacklinks<cr>", desc = "Backlinks", noremap = true, silent = true },
        { "<leader>nlp", mode = "n", ":ObsidianLinks<cr>", desc = "Link Pick", noremap = true, silent = true },
        { "<leader>nT", mode = "n", ":ObsidianTags<cr>", desc = "Tags", noremap = true, silent = true },
        {
          "<leader>nD",
          mode = "n",
          ":lua local f=vim.fn.expand('%:p'); if vim.fn.confirm('Delete '..f..'?', '&Yes\\n&No') == 1 then os.remove(f); vim.cmd('bd!'); end<cr>",
          desc = "Delete Note",
          noremap = true,
          silent = true,
        },
        {
          "<leader>nE",
          mode = { "v", "x" },
          ":ObsidianExtractNote<cr>",
          desc = "Extract Text",
          noremap = true,
          silent = true,
        },
        { "<leader>nl", mode = { "v", "x" }, ":ObsidianLinkNew<cr>", desc = "Link New", noremap = true, silent = true },
      }, -- }}}
    }, -- }}}

      { "Kicamon/markdown-table-mode.nvim", -- auto format table in markdown {{{
        enabled = false,
        lazy = true,
        ft = { "markdown", "quarto" },
        opts = {},
      },-- }}}
    -- }}}

    -- {{{ [ Quarto, Jupyterlab ]
    { "quarto-dev/quarto-nvim", -- {{{
      -- enabled = false,
      ft = { "quarto" },
      opts = {
        lspFeatures = {
          languages = { "python", "bash", "lua", "html", "javascript" },
          chunks = "all",
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = { enabled = true },
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
        },
      },
      keys = { -- {{{
        { "<leader>qa", mode = { "n" }, "<cmd>QuartoActivate<cr>", desc = "Activate", noremap = true, silent = true },
        { "<leader>qp", mode = { "n" }, "<cmd>lua require'quarto'.quartoPreview()<cr>", desc = "Preview", noremap = true, silent = true,},
        { "<leader>qq", mode = { "n" }, "<cmd>lua require'quarto'.quartoClosePreview()<cr>", desc = "Quit", noremap = true, silent = true,},
        { "<leader>qh", mode = { "n" }, "<cmd>QuartoHelp<cr>", desc = "Help", noremap = true, silent = true },
        -- Quarto runner keymaps (code cell)
        { "<leader>qrc", mode = "n", function() require("quarto.runner").run_cell() end, desc = "Run Cell", noremap = true, silent = true,},
        { "<leader>qrl", mode = "n", function() require("quarto.runner").run_line() end, desc = "Run Line", noremap = true, silent = true,},
        -- { "<leader>pca", mode = "n", function() require("quarto.runner").run_above() end, desc = "run cell and above", noremap = true, silent = true },
        { "<leader>qra", mode = "n", function() require("quarto.runner").run_all() end, desc = "Run All Cells", noremap = true, silent = true,},
        { "<leader>qrA", mode = "n", function() require("quarto.runner").run_all(true) end, desc = "Run All Languages", noremap = true, silent = true,},
        { "<leader>r", mode = "v", function() require("quarto.runner").run_range() end, desc = "Run Selection", noremap = true, silent = true,},
      }, -- }}}
    }, -- }}}

    { "jmbuhr/otter.nvim", -- {{{
      -- enabled = false,
      event = {
        "BufReadPost *.md",
        "BufNewFile  *.md",
        "BufReadPost *.qmd",
        "BufNewFile  *.qmd",
        "BufEnter  *.ipynb", -- pre jupyternotebooks
      },
      init = function()
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
          pattern = { "*.md", "*.qmd", "*.ipynb" },
          callback = function()
            require("otter").activate()
          end,
        })
      end,
      keys = { -- {{{
        { "<leader>qo", mode = { "n" }, function() require("otter").activate() end, desc = "Otter Activate", noremap = true, silent = true,},
      }, -- }}}
    }, -- }}}

    { "GCBallesteros/jupytext.nvim", -- {{{
      -- enabled = false,
      opts = {
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
      },
    }, -- }}}

      { "benlubas/molten-nvim",-- {{{
        enabled = false,
        -- build = ":UpdateRemotePlugins",
        -- ft = { "python", "quarto", "markdown" },
        dependencies = os_type == "linux"-- {{{
          and { "3rd/image.nvim" }
          or { "willothy/wezterm.nvim", config = true },-- }}}
        init = function()-- {{{
        -- "pynvim" nainstalovat vo "venv"
        -- v mojom venv, kde som nainstaloval "ipykernel", resp. "jupyterlab", tak spustim:
        -- "python -m ipykernel install --user --name project_name"
        -- "project_name" dam nazov mojho venv, napr. venv: "base-venv", tak project_name:"base-venv"
        -- for windows read: https://github.com/benlubas/molten-nvim/blob/main/docs/Windows.md
        -- after that, update remote plugins ":UpdateRemotePlugins"
        -- restart neovim
          vim.g.python3_host_prog = PythonInterpreter()
          if os_type == "linux" then
            vim.g.molten_image_provider = "image.nvim"
          else
            vim.g.molten_image_provider = "wezterm"
            -- image_provider_opts = {
            --   command = "wezterm imgcat"  -- Remove `--tmux-passthru`
            -- }
            vim.g.molten_split_direction = "bottom" --direction of the output window, options are "right", "left", "top", "bottom"
            vim.g.molten_split_size = 40 --(0-100) % size of the screen dedicated to the output window
          end
          vim.g.molten_output_win_max_height = 20
          vim.g.molten_wrap_output = true
          vim.g.molten_auto_open_output = false -- cannot be true if molten_image_provider = "wezterm"
          vim.g.molten_virt_lines_off_by_1 = true -- this will make it so the output shows up below the \`\`\` cell delimiter
          vim.g.molten_virt_text_output = true

          -- -- change the configuration when editing a python file{{{
          -- vim.api.nvim_create_autocmd("BufEnter", {
          --   pattern = "*.py",
          --   callback = function(e)
          --     if string.match(e.file, ".otter.") then
          --       return
          --     end
          --     if require("molten.status").initialized() == "Molten" then -- this is kinda a hack...
          --       vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
          --       vim.fn.MoltenUpdateOption("virt_text_output", false)
          --     else
          --       vim.g.molten_virt_lines_off_by_1 = false
          --       vim.g.molten_virt_text_output = false
          --     end
          --   end,
          -- })-- }}}

          -- -- Undo those config changes when we go back to a markdown or quarto file{{{
          -- vim.api.nvim_create_autocmd("BufEnter", {
          --   pattern = { "*.qmd", "*.md", "*.ipynb" },
          --   callback = function(e)
          --     if string.match(e.file, ".otter.") then
          --       return
          --     end
          --     if require("molten.status").initialized() == "Molten" then
          --       vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
          --       vim.fn.MoltenUpdateOption("virt_text_output", true)
          --     else
          --       vim.g.molten_virt_lines_off_by_1 = true
          --       vim.g.molten_virt_text_output = true
          --     end
          --   end,
          -- })-- }}}

        end,-- }}}
        keys = {-- {{{
          -- { "<leader>pma", mode = "n", MoltenInitialize, desc = "activate", noremap = true, silent = true },
          { "<leader>pma", mode = "n", function()
            MoltenInitialize()
            vim.defer_fn(function()
              -- suvisi s [ Lualine ] statusline
              -- ak je molten activovany tak v lualine vypise "M:A"
              if require('molten.status').initialized() == "Molten" then
                vim.g.lualine_status = "M:A"  -- Store status in a global variable
                -- Refresh lualine statusline to apply the changes
                require("lualine").refresh({ place = { "statusline" } })
              end
            end, 200)
          end, desc = "activate", noremap = true, silent = true },
          { "<leader>pmb", mode = "n", ":MoltenOpenInBrowser<cr>", desc = "open in browser (html only)", noremap = true, silent = true },
          -- { "<leader>pmo", mode = "n", ":MoltenEvaluateOperator<cr>", desc = "operator evaluate", noremap = true, silent = true },
          -- { "<leader>pml", mode = "n", ":MoltenEvaluateLine<cr>", desc = "line evaluate", noremap = true, silent = true },
          -- { "<leader>pcR", mode = "n", ":MoltenReevaluateCell<cr>", desc = "re-evaluate cell", noremap = true, silent = true },
          { "<leader>pmd", mode = "n", ":MoltenDelete<cr>", desc = "delete output", noremap = true, silent = true },
          { "<leader>pmh", mode = "n", ":MoltenHideOutput<cr>", desc = "hide output", noremap = true, silent = true },
          { "<leader>pme", mode = "n", ":noautocmd MoltenEnterOutput<cr>", desc = "show/enter cell output", noremap = true, silent = true },
          -- { "<leader>pl", mode = "v", ":<C-u>MoltenEvaluateVisual<cr>gv", desc = "run lines", noremap = true, silent = true },

        },-- }}}
      },-- }}}
    -- }}}

    -- {{{ [ DAP debug ]

    { "mfussenegger/nvim-dap",
      enabled = false,
      dependencies = {-- {{{
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "jay-babu/mason-nvim-dap.nvim",
        -- Add debuggers here
        "mfussenegger/nvim-dap-python",
      },-- }}}
      config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        local dap_python = require("dap-python")

        require("mason-nvim-dap").setup {-- {{{
          automatic_installation = true,
          handlers = {},
          ensure_installed = {
            "debugpy",
          },
        }-- }}}

        -- Dap UI setup
        dapui.setup({-- {{{
          -- icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
          -- controls = {
          --   icons = {
          --     pause = "⏸",
          --     play = "▶",
          --     step_into = "⏎",
          --     step_over = "⏭",
          --     step_out = "⏮",
          --     step_back = "b",
          --     run_last = "▶▶",
          --     terminate = "⏹",
          --     disconnect = "⏏",
          --   },
          -- },
        })-- }}}

        -- -- Change breakpoint icons
        -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
        -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
        -- local breakpoint_icons = vim.g.have_nerd_font
        --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
        --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
        -- for type, icon in pairs(breakpoint_icons) do
        --   local tp = 'Dap' .. type
        --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
        --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
        -- end


        vim.fn.sign_define("DapBreakpoint", {
          text = "",
          texthl = "DiagnosticSignError",
          linehl = "",
          numhl = "",
        })

        vim.fn.sign_define("DapBreakpointRejected", {
          text = "", -- or "❌"
          texthl = "DiagnosticSignError",
          linehl = "",
          numhl = "",
        })

        vim.fn.sign_define("DapStopped", {
          text = "", -- or "→"
          texthl = "DiagnosticSignWarn",
          linehl = "Visual",
          numhl = "DiagnosticSignWarn",
        })

        -- Automatically open/close DAP UI
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end

        -- dap.listeners.after.event_initialized['dapui_config'] = dapui.open
        -- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
        -- dap.listeners.before.event_exited['dapui_config'] = dapui.close

        -- python specific config
        dap_python.setup(debugpy_path)
        -- dap_python.setup("python")

      end,
      keys = {-- {{{
        -- { "<leader>pdB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "breakpoint condition", noremap = true, silent = true },
        { "<leader>pdb", function() require("dap").toggle_breakpoint() end, desc = "toggle breakpoint", noremap = true, silent = true },
        { "<leader>pdc", function() require("dap").continue() end, desc = "run/continue", noremap = true, silent = true },
        -- { "<leader>pda", function() require("dap").continue({ before = get_args }) end, desc = "run with args", noremap = true, silent = true },
        -- { "<leader>pdC", function() require("dap").run_to_cursor() end, desc = "run to cursor", noremap = true, silent = true },
        -- { "<leader>pdg", function() require("dap").goto_() end, desc = "go to line (no execute)", noremap = true, silent = true },
        { "<leader>pdi", function() require("dap").step_into() end, desc = "step into", noremap = true, silent = true },
        -- { "<leader>pdj", function() require("dap").down() end, desc = "down", noremap = true, silent = true },
        -- { "<leader>pdk", function() require("dap").up() end, desc = "up", noremap = true, silent = true },
        -- { "<leader>pdl", function() require("dap").run_last() end, desc = "run last", noremap = true, silent = true },
        { "<leader>pdo", function() require("dap").step_out() end, desc = "step out", noremap = true, silent = true },
        { "<leader>pdO", function() require("dap").step_over() end, desc = "step over", noremap = true, silent = true },
        -- { "<leader>pdP", function() require("dap").pause() end, desc = "pause", noremap = true, silent = true },
        -- { "<leader>pdr", function() require("dap").repl.toggle() end, desc = "toggle REPL", noremap = true, silent = true },
        -- { "<leader>pds", function() require("dap").session() end, desc = "session", noremap = true, silent = true },
        { "<leader>pdq", function() require("dap").terminate() end, desc = "terminate", noremap = true, silent = true },
        { "<leader>pdw", function() require("dap.ui.widgets").hover() end, desc = "widgets", noremap = true, silent = true },
        -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
        { "<leader>pdu", function() require("dapui").toggle() end, desc = "UI", noremap = true, silent = true },
        -- { "<leader>pde", mode = {"n", "v"}, function() require("dapui").eval() end, desc = "eval", noremap = true, silent = true },
      },-- }}}
    },
    -- }}}

    -- {{{ [ Mix ]
    { "benomahony/uv.nvim", -- python uv and custom venv picker {{{
      -- enabled = false,
      ft = { "python" },
      config = function() -- {{{
        local uv = require("uv")
        -- local snacks = require("snacks")

        -- custom snack venv picker
        Snacks.picker.sources.venv_home = { -- {{{
          finder = function()
            local items = {
              { text = "Create new venv", is_create = true },
            }
            local handle = vim.loop.fs_scandir(osvar.venv_home)
            while handle do
              local name, typ = vim.loop.fs_scandir_next(handle)
              if not name then
                break
              end
              if typ == "directory" then
                local path = osvar.venv_home .. "/" .. name
                table.insert(items, {
                  text = name,
                  path = path,
                  is_current = vim.env.VIRTUAL_ENV == path,
                })
              end
            end
            return items
          end,

          format = function(i)
            return { { (i.is_current and "● " or "○ ") .. i.text } }
          end,

          confirm = function(picker, item)
            picker:close()
            if item then
              if item.is_create then
                vim.ui.input({ prompt = "New venv name: " }, function(name)
                  if name and #name > 0 then
                    local path = osvar.venv_home .. "/" .. name
                    uv.run_command("uv venv " .. path) -- Simplified command to create venv
                    uv.activate_venv(path)
                  end
                end)
              else
                uv.activate_venv(item.path)
                -- uv.run_command("uv activate " .. item.path)  -- Simplified command to activate venv
              end
            end
          end,
        } -- }}}

        uv.setup({
          keymaps = false,
          -- keymaps = { prefix = "<leader>x" }
          auto_activate_venv = false,
        })
      end, -- }}}
      keys = { -- {{{
        { "<leader>pe", mode = { "n" }, function() Snacks.picker("venv_home") end, desc = "Pick Venv (~/py-venv)", noremap = true, silent = true,},
        { "<leader>pr", mode = { "n" }, "<cmd>UVRunFile<cr>", desc = "UV Run Current File", noremap = true, silent = true,},
        { "<leader>ps", mode = { "v" }, "<cmd>UVRunSelection<cr>", desc = "UV Run Selection", noremap = true, silent = true,},
        { "<leader>pf", mode = { "n" }, "<cmd>UVRunFunction<cr>", desc = "UV Run Function", noremap = true, silent = true,},
        { "<leader>pE", mode = { "n" }, "<cmd>lua Snacks.picker.pick('uv_venv')<cr>", desc = "UV Environment", noremap = true, silent = true,},
        { "<leader>pi", mode = { "n" }, "<cmd>UVInit<cr>", desc = "UV Init", noremap = true, silent = true },
        { "<leader>pa", mode = { "n" }, "<cmd>lua vim.ui.input({prompt = 'Enter package name: '}, function(input) if input and input ~= '' then require('uv').run_command('uv add ' .. input) end end)<cr>", desc = "UV Add Package", noremap = true, silent = true,},
        { "<leader>pd", mode = { "n" }, "<cmd>lua vim.ui.input({prompt = 'Enter package name: '}, function(input) if input and input ~= '' then require('uv').run_command('uv remove ' .. input) end end)<cr>", desc = "UV Remove Package", noremap = true, silent = true,},
        { "<leader>ps", mode = { "n" }, "<cmd>lua require('uv').run_command('uv sync')<cr>", desc = "UV Sync Packages", noremap = true, silent = true,},
      }, -- }}}
    }, -- }}}

    { "lepture/vim-jinja", -- syntax/indent for jinja.html files {{{
      enabled = false,
      ft = { "jinja", "htmldjango", "html", "jinja.html" },
    }, -- }}}

    { "brenoprata10/nvim-highlight-colors", -- show colors {{{
      enabled = false,
      opts = {},
      keys = { -- {{{
        { "\\H", mode = "n", "<cmd>HighlightColors Toggle<cr>", desc = "Toggle 'highlight-colors'" },
      }, -- }}}
    }, -- }}}

    { "uga-rosa/ccc.nvim", -- color picker (:CccPick){{{
      enabled = false,
      opts = { -- {{{
        highlighter = {
          auto_enable = true,
          lsp = true,
        },
      }, -- }}}
      keys = { -- {{{
        { "<leader>vp", mode = "n", "<cmd>CccPick<cr>", desc = "color picker", noremap = true, silent = true },
      }, -- }}}
    }, -- }}}

    { "szw/vim-maximizer", -- maximize window {{{
      -- enabled = false,
      keys = { -- {{{
        { "<leader>wm", mode = { "n" }, "<cmd>MaximizerToggle<cr>", desc = "Maximize", noremap = true, silent = true },
      }, -- }}}
    }, -- }}}

    { "chomosuke/typst-preview.nvim",-- {{{
      ft = "typst",
      version = "1.*",
      opts = {
        dependencies_bin = {
          ['tinymist'] = nil, -- point to Mason's installation of tinymist
          ['websocat'] = nil
        },
      },
      keys = { -- {{{
        { "\\t", mode = { "n" }, "<cmd>TypstPreviewToggle<cr>", desc = "Toggle 'typst preview'", noremap = true, silent = true },
      }, -- }}}
    },-- }}}

    -- }}}
  }, -- spec end }}}

  install = { colorscheme = { "kanagawa" } },
  dev = { path = "~/git-repos/" },
})

-- }}}

-- [[ LSP ]]{{{
-- Path to Mason-installed binaries and formatters missing packages{{{
local separator = function()
  if osvar.os_type == "windows" then
    return ";"
  else
    return ":"
  end
end
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. separator() .. vim.env.PATH

-- solving problem with missing python packages "setuptools" for formatters, in shell run:
-- /home/vimi/.local/share/nvim/mason/packages/beautysh/venv/bin/pip install setuptools
-- }}}

-- LspInfo autocommand{{{
vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if vim.tbl_isempty(clients) then
    print("No LSP clients attached to this buffer.")
    return
  end

  -- Prepare the floating window content
  local lines = {}
  for _, client in ipairs(clients) do
    table.insert(lines, " Name:          " .. client.name)
    table.insert(lines, " ID:            " .. client.id)
    table.insert(lines, " Root Dir:      " .. (client.config.root_dir or "N/A"))
    table.insert(lines, " Filetypes:     " .. table.concat(client.config.filetypes or {}, ", "))

    local cmd_display = type(client.config.cmd) == "table"
    and table.concat(client.config.cmd, " ")
    or "<function>"
    table.insert(lines, " CMD:           " .. cmd_display)

    table.insert(lines, " Capabilities:  ")
    for k, _ in pairs(client.server_capabilities or {}) do
      table.insert(lines, "   - " .. k)
    end
  end

  -- Create a floating window to display the info
  local buf = vim.api.nvim_create_buf(false, true) -- Create an empty buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines) -- Set the lines in the buffer

  -- Set the floating window options
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = 80,
    height = #lines,
    row = 5,
    col = 5,
    style = 'minimal',
    border = 'rounded',
  })

  -- Optional: set the buffer to not be modifiable (just to display info)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end, {})-- }}}

-- {{{ [ LSP Diagnostic ]
vim.diagnostic.config({
  virtual_text = {
    current_line = true,
  },
  underline = true,
  severity_sort = true,
  float = { border = "rounded" },
  hover = true,
  })

for _, sign in ipairs({ { "Error", "" }, { "Warn", "" }, { "Hint", "󰌵" }, { "Info", "" } }) do
  vim.fn.sign_define("DiagnosticSign" .. sign[1], { texthl = "DiagnosticSign" .. sign[1], text = sign[2] })
end

-- inlay_hints - napr. pre basedpyright
vim.lsp.inlay_hint.enable()
-- }}}

-- {{{ [ LSP Capabilities ]
local original_capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require("blink.cmp").get_lsp_capabilities(original_capabilities)
vim.lsp.config("*", {
  capabilities = capabilities,
})
-- }}}

-- {{{ [ LSP Configs ]
local lsp_configs = {
  luals = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", "init.lua" },
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim", "Snacks", "MiniFiles", "MiniStatusline", "MiniSessions", "MiniTrailspace" },
        },
      },
    },
  },
  basedpyright = {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "pyrightconfig.json",
      ".git",
    },
    settings = {
      basedpyright = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = true,
          inlayHints = {
            variableTypes = true,
            callArgumentNames = true,
            functionReturnTypes = true,
            genericTypes = true,
          },
        },
      },
    },
  },
  bashls = {
    cmd = { "bash-language-server", "start" },
    filetypes = { "zsh", "bash", "sh" },
    root_markers = { ".git" },
    settings = {
      bashIde = {
        globPattern = "*@(.sh|.inc|.bash|.command)",
      },
    },
  },
  emmet_ls = {
    cmd = { "emmet-ls", "--stdio" },
    filetypes = { "astro", "css", "eruby", "html", "javascriptreact", "less", "pug", "sass", "scss", "svelte", "typescriptreact", "vue", "htmlangular" },
    root_markers = { ".git" },
  },
  marksman = {
    cmd = { "marksman", "server" },
    filetypes = { "markdown", "quarto" },
  },
  tinymist = {
    cmd = { "tinymist" },
    filetypes = { "typst" },
    root_markers = { ".git" },
  },
  htmx = {
    cmd = { "htmx-lsp" },
    filetypes = { "django-html", "htmldjango", "html", "jinja.html" },
    root_markers = { ".git" },
  },
}

for name, opts in pairs(lsp_configs) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
-- }}}

-- {{{ [ LSP Keymaps ]
map("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code Action" })
map("n", "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Goto Definition" })
map("n", "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "Goto Declaration" })
map("n", "<leader>li", "<cmd>lua vim.lsp.buf.implementation()<cr>", { desc = "Implementation" })
map("n", "<leader>lI", "<cmd>LspInfo<cr>", { desc = "Info" })
map("n", "<leader>lk", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "Hoover" })
map("n", "<leader>lr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "References" })
map("n", "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<leader>lh", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "Signature Help" })
map("n", "<leader>lx", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Diagnostic Open Float" })
-- inlay-hint toggle
map("n", "\\I", "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>", { desc = "Toggle 'inlay_hint'" })
-- }}}
-- LSP ends }}}
