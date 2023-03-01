-- Functional wrapper for mapping custom keybindings
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
map("n", "S", ":w<cr>", { desc = "Save" })
map("n", "W", ":wq<cr>", { desc = "Save-Quit" })
map("n", "Q", ":q!<cr>", { desc = "Quit" })
map("n", "<A-x>", ":w<cr>:luafile %<cr>", { desc = "Reload Lua" })

-- Windows
map("n", "<leader>wv", "<C-w>v", { desc = "Vertical" })
map("n", "<leader>wh", "<C-w>s", { desc = "Horizontal" })
map("n", "<leader>w=", "<C-W>=", { desc = "Equal" })
map("n", "<C-Up>", "<C-w>k", { desc = "Go UP" })
map("n", "<C-Down>", "<C-w>j", { desc = "Go DOWN" })
map("n", "<C-Left>", "<C-w>h", { desc = "Go LEFT" })
map("n", "<C-Right>", "<C-w>l", { desc = "Go RIGHT" })
map("n", "<S-Up>", ":resize +2<CR>", { desc = "Resize UP" })
map("n", "<S-Down>", ":resize -2<CR>", { desc = "Resize DOWN" })
map("n", "<S-Left>", ":vertical resize -2<CR>", { desc = "Resize LEFT" })
map("n", "<S-Right>", ":vertical resize +2<CR>", { desc = "Resize RIGHT" })

-- Buffers
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<A-Right>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<A-Left>", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<A-UP>", ":bp<BAR>bd#<CR>", { desc = "Quit buffer" })
map("n", "<A-Down>", ":bp<BAR>bd#<CR>", { desc = "Quit buffer" })

-- Indenting
map("v", "<", "<gv", { desc = "Unindent line" })
map("v", ">", ">gv", { desc = "Indent line" })

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move text DOWN" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move text UP" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move text DOWN" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move text UP" })
map("v", "<A-j>", ":m .+1<CR>==", { desc = "Move text UP" })
map("v", "<A-k>", ":m .-2<CR>==", { desc = "Move text DOWN" })
map("x", "<A-j>", ":move '>+1<CR>gv-gv", { desc = "Move text UP" })
map("x", "<A-k>", ":move '<-2<CR>gv-gv", { desc = "Move text DOWN" })

-- Clear search with <esc>
map("n", "<ESC>", "<cmd>nohlsearch<CR>", { desc = "No highlight" })
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Paste over currently selected text without yanking it
map("v", "p", '"_dP', { desc = "Paste no yank" })

-- MIX
map("i", "ii", "<ESC>", { desc = "INSERT mode toggle" })
map("n", "<A-a>", "<ESC>ggVG<CR>", { desc = "Select all text" })
map("n", "<BS>", "X", { desc = "TAB as X in NORMAL mode" })

-- Comment - mozem pouzit aj nastavenie v plugin-manager.lua
map('n', '<leader>/', '<CMD>lua require("Comment.api").toggle.linewise.current()<CR>', { desc = "comment"})
map('x', '<leader>/', '<ESC><CMD>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>', { desc = "comment" })

-- Lazy
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "lazy" })

-- Icon Picker
map("n", "<leader>in", "<cmd>IconPickerNormal<cr>", { desc = "icon normal mode" })
map("n", "<leader>iy", "<cmd>IconPickerYank<cr>", { desc = " yank icon into register" })
map("i", "<A-i>", "<cmd>IconPickerInsert<cr>", { desc = "icon insert mode" })

-- Telescope
map("n", "<leader>fx", "<cmd>Telescope<cr>", { desc = "telescope" })
map("n", "<leader>fe", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", { desc = "file browser" })
map("n", "<leader>fn", "<cmd>Telescope notify<cr>", { desc = "notifications" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "files" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<cr>", { desc = "words" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "recent files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "buffers" })
map("n", "<leader>fc", "<cmd>Telescope colorscheme<cr>", { desc = "colorscheme" })
map("n", "<leader>fp", "<cmd>lua require'telescope'.extensions.project.project{ display_type = 'full' }<cr>", { desc = "projects" })

-- LSP
map("n", "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "definition" })
map("n", "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "declaration" })
map("n", "<leader>lk", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "hoover" })
map("n", "<leader>lI", "<cmd>lua vim.lsp.buf.implementation()<cr>", { desc = "implementation" })
map("n", "<leader>lr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "references" })
map("n", "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "rename" })
map("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", { desc = "formatting" })
map("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "code action" })
map("n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "signature help" })

-- Diagnostic
-- enable / disable diagnostic
local diagnostics_active = true
local toggle_diagnostics = function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end

map('n', '<leader>dd', toggle_diagnostics, { desc = "diagnostic toggle" })
map("n", "<leader>dn", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", { desc = "next" })
map("n", "<leader>dp", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", { desc = "prev" })
map("n", "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", { desc = "loc list" })
map("n", "<leader>df", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "open float" })

-- Terminal
map("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "toggle" })
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "float" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "vertical" })
map("n", "<leader>tl", "<cmd>ToggleTermSendCurrentLine<cr>", { desc = "send line" })
map("v", "<leader>tb", "<cmd>ToggleTermSendVisualLines<cr>", { desc = "send block lines" })
map("v", "<leader>ts", "<cmd>ToggleTermSendVisualSelection<cr>", { desc = "send selection" })
map("n", "<leader>tr", "<cmd>lua _RANGER_TOGGLE()<cr>", { desc = "ranger" })

-- Improved Terminal Mappings
map("t", "<esc>", "<C-\\><C-n>", { desc = "terminal normal mode" })

-- GIT
map("n", "<leader>gl", "<cmd>lua _LAZYGIT_TOGGLE()<cr>", { desc = "lazygit" })
map("n", "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", { desc = "next hunk" })
map("n", "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", { desc = "prev hunk" })
map("n", "<leader>gb", "<cmd>lua require 'gitsigns'.blame_line()<cr>", { desc = "blame line" })
map("n", "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", { desc = "preview hunk" })
map("n", "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", { desc = "reset hunk" })
map("n", "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", { desc = "reset buffer" })
map("n", "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", { desc = "stage hunk" })
map("n", "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", { desc = "undo stage hunk" })
map("n", "<leader>go", "<cmd>Telescope git_status<cr>", { desc = "open changed file" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "checkout branch" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "checkout commit" })

-- NeoVim
map("n", "<leader>vn", "<cmd>set relativenumber!<cr>", { desc = "numbers toggle" })
map("n", "<leader>vl", "<cmd>IndentBlanklineToggle<cr>", { desc = "blankline toggle" })
map("n", "<leader>vb", "<cmd>let &bg=(&bg == 'dark' ? 'light' : 'dark' )<CR>", { desc = "background toggle" })
map("n", "<leader>vc", function()
  if vim.o.conceallevel > 0 then
    vim.o.conceallevel = 0
  else vim.o.conceallevel = 1
	end
end, { desc = "conceal level toggle" })
map("n",  "<leader>vk" , function()
	if vim.o.concealcursor == "n" then
		vim.o.concealcursor = ""
	else
		vim.o.concealcursor = "n"
	end
end, { desc = "conceal cursor toggle" })

-- Code Run
map("n", "<leader>cp", "<cmd>TermExec cmd='python3 %'<cr>", { desc = "python"} )
map("n", "<leader>cw", "<cmd>lua _WEB_TOGGLE()<cr>", { desc = "web preview"} )

-- Python
map("n", "<leader>pe", "<cmd>lua require('swenv.api').pick_venv()<cr>", { desc = "python envs" })
map("n", "<leader>pt", "<cmd>lua _BPYTHON_TOGGLE()<cr>", { desc = "bpython term" })
