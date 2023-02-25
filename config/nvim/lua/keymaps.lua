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

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw / clear hlsearch / diff update" })

  -- Paste over currently selected text without yanking it
map("v", "p", '"_dP', { desc = "Paste no yank" })

-- MIX
map("i", "ii", "<ESC>", { desc = "INSERT mode toggle" })
map("n", "<A-a>", "<ESC>ggVG<CR>", { desc = "Select all text" })
map("n", "<BS>", "X", { desc = "TAB as X in NORMAL mode" })

-- Comment - ak by nefungovalo nastavenie v plugin-manager.lua
-- map('n', '<leader>/', '<CMD>lua require("Comment.api").toggle.linewise.current()<CR>', { desc = "Comment line"})
-- map('x', '<leader>/', '<ESC><CMD>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>', { desc = "Comment line" })

-- Telescope
map("n", "<leader>fx", "<cmd>Telescope<cr>", { desc = "Telescope" })
map("n", "<leader>fe", "<cmd>Telescope file_browser<cr>", { desc = "File browser" })
map("n", "<leader>fn", "<cmd>Telescope notify<cr>", { desc = "Notifications" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Files" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<cr>", { desc = "Words" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fc", "<cmd>Telescope colorscheme<cr>", { desc = "Colorscheme" })
map("n", "<leader>fp", "<cmd>lua require'telescope'.extensions.project.project{ display_type = 'full' }<cr>", { desc = "Projects" })

-- LSP
map("n", "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "Definition" })
map("n", "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "Declaration" })
map("n", "<leader>lk", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "Hoover" })
map("n", "<leader>lI", "<cmd>lua vim.lsp.buf.implementation()<cr>", { desc = "Implementation" })
map("n", "<leader>lr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "References" })
map("n", "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", { desc = "Formatting" })
map("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code action" })
map("n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "Signature help" })
map("n", "<leader>ln", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", { desc = "Go to next" })
map("n", "<leader>lp", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", { desc = "Go to prev" })
map("n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", { desc = "Set loc list" })
map("n", "<leader>ll", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "Diagnostic open float" })
map("n", "<leader>le", "<cmd>lua require('swenv.api').pick_venv()<cr>", { desc = "Python envs" })

-- Terminal
map("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle" })
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Float" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Vertical" })
map("n", "<leader>tl", "<cmd>ToggleTermSendCurrentLine<cr>", { desc = "Send line" })
map("v", "<leader>tb", "<cmd>ToggleTermSendVisualLines<cr>", { desc = "Send block lines" })
map("v", "<leader>ts", "<cmd>ToggleTermSendVisualSelection<cr>", { desc = "Send selection" })
map("n", "<leader>tp", "<cmd>lua _BPYTHON_TOGGLE()<cr>", { desc = "BPython" })
map("n", "<leader>tr", "<cmd>lua _RANGER_TOGGLE()<cr>", { desc = "Ranger" })

-- Improved Terminal Mappings
map("t", "<esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })

-- GIT
map("n", "<leader>tl", "<cmd>lua _LAZYGIT_TOGGLE()<cr>", { desc = "LazyGit" })

map("n", "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", { desc = "Next Hunk" })
map("n", "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", { desc = "Prev Hunk" })
map("n", "<leader>gl", "<cmd>lua require 'gitsigns'.blame_line()<cr>", { desc = "Blame" })
map("n", "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", { desc = "Preview Hunk" })
map("n", "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", { desc = "Reset Hunk" })
map("n", "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", { desc = "Reset Buffer" })
map("n", "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", { desc = "Stage Hunk" })
map("n", "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", { desc = "Undo Stage Hunk" })
map("n", "<leader>go", "<cmd>Telescope git_status<cr>", { desc = "Open changed file" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Checkout branch" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Checkout commit" })

-- NeoVim
map("n", "<leader>vn", "<cmd>set relativenumber!<cr>", { desc = "Numbers toggle" })
map("n", "<leader>vl", "<cmd>IndentBlanklineToggle<cr>", { desc = "Indent Blankline toggle" })
map("n", "<leader>vb", "<cmd>let &bg=(&bg == 'dark' ? 'light' : 'dark' )<CR>", { desc = "Backround toggle" })

-- Code Run
map("n", "<leader>cp", "<cmd>TermExec cmd='python3 %'<cr>", { desc = "Python"} )
map("n", "<leader>cw", "<cmd>lua _WEB_TOGGLE()<cr>", { desc = "Web Preview"} )
map("n", "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", { desc = "Diff" })
