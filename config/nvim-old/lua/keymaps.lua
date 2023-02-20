-- Functional wrapper for mapping custom keybindings
function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Remap space as leader key
map("", "<Space>", "<Nop>", { silent = true }) -- disable space because leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal --
-- Save, Quit
map("n", "S", ":w<cr>", { desc = "Save" })
map("n", "W", "<cmd>wq<cr>", { desc = "Save-Quit" })
map("n", "Q", "<cmd>q!<cr>", { desc = "Quit" })

-- Basic file system commands
-- map("n", "<leader>fc", ":!touch<Space>", { desc = "Create file" })
-- map("n", "<leader>dc", ":!mkdir<Space>", { desc = "Create directory" })
-- map("n", "<leader>mv", ":!mv<Space>%<Space>", {desc = "Move"})

-- Mix
map("i", "ii", "<ESC>", { desc = "INSERT mode toggle" })
map("n", "<leader>n", ":set relativenumber!<CR>", { desc = "Numbers toggle" })
-- map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "No highlight" })
map("n", "<ESC>", "<cmd>nohlsearch<CR>", { desc = "No highlight" })
-- map("n", "<leader>b", ":let &bg=(&bg == 'dark' ? 'light' : 'dark' )<CR>", { silent = true, desc = "Backround toggle" })
map("n", "<A-a>", "<ESC>ggVG<CR>", { desc = "Select all text" })
map("n", "<BS>", "X", { desc = "TAB as X in NORMAL mode" })
map("n", "zz", "za", { desc = "Folding" })

-- Window split
map("n", "<leader>wv", "<C-w>v", { desc = "Vertical split" })
map("n", "<leader>wh", "<C-w>s", { desc = "Horizontal split" })

-- Better window navigation
map("n", "<C-Up>", "<C-w>k", { desc = "Move to above split" })
map("n", "<C-Down>", "<C-w>j", { desc = "Move to below split" })
map("n", "<C-Left>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-Right>", "<C-w>l", { desc = "Move to right split" })

-- Resize windows
map("n", "<S-Up>", ":resize +2<CR>", { desc = "Resize split up" })
map("n", "<S-Down>", ":resize -2<CR>", { desc = "Resize split down" })
map("n", "<S-Left>", ":vertical resize -2<CR>", { desc = "Resize split left" })
map("n", "<S-Right>", ":vertical resize +2<CR>", { desc = "Resize split right" })
map("n", "<leader>=", "<C-W>=", { desc = "Equal windows" })

-- Buffers
-- Navigate buffers
map("n", "<A-Right>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<A-Left>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Quit buffers
map("n", "<A-UP>", ":bp<BAR>bd#<CR>", { desc = "Quit buffer" })
map("n", "<A-Down>", ":bp<BAR>bd#<CR>", { desc = "Quit buffer" })

-- Tabs
-- Create Tabs from Buffers
-- map("n", "<leader>t", ":tab sball<CR>", { desc = "Tabs from Buffers" })
-- Navigate Tabs
-- map("n", "<leader>h", ":tabp<CR>", { desc = "Previous Tab" })
-- map("n", "<leader>l", ":tabn<CR>", { desc = "Next Tab" })
-- Quit Tabs
-- map("n", "<leader>j", ":tabc<CR>", { desc = "Quit Tab" })
-- map("n", "<leader>k", ":tabo<CR>", { desc = "Quit Tab" })

-- Visual --
-- Stay in indent mode
map("v", "<", "<gv", { desc = "Unindent line" })
map("v", ">", ">gv", { desc = "Indent line" })

-- Move text up and down
map("v", "J", ":m .+1<CR>==", { desc = "Move text UP" })
map("v", "K", ":m .-2<CR>==", { desc = "Move text DOWN" })
  -- Paste over currently selected text without yanking it
map("v", "p", '"_dP', { desc = "Paste no yank" })

-- Visual Block --
-- Move text up and down
map("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move text block UP" })
map("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move text block DOWN" })

-- NeoTree
map("n", "<leader>e", ":Neotree toggle<cr>", { desc = "Neotree toggle" })
-- map("n", "<leader>f", ":Neotree focus<cr>", {})

-- Telescope
map("n", "<leader>ss", ":Telescope<CR>", { desc = "Search Telescope" })
map("n", "<leader>sf", ":Telescope find_files<CR>", { desc = "Search all files" })
map("n", "<leader>sw", ":Telescope live_grep<CR>", { desc = "Search words" })
map("n", "<leader>sp", ":Telescope projects<CR>", { desc = "Search projects" })
map("n", "<leader>sb", ":Telescope buffers<CR>", { desc = "Search buffers" })

-- Terminal
map("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
-- map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Term float" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Term horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Term vertical" })
map("n", "<leader>tl", "<cmd>ToggleTermSendCurrentLine<cr>", { desc = "Send line to term" })
map("v", "<leader>tb", "<cmd>ToggleTermSendVisualLines<cr>", { desc = "Send block lines to term" })
map("v", "<leader>ts", "<cmd>ToggleTermSendVisualSelection<cr>", { desc = "Send selection to term" })

-- Improved Terminal Mappings
map("t", "<esc>", "<C-\\><C-n>", { desc = "Terminal normal mode" })

-- Comment
map('n', '<leader>/', '<CMD>lua require("Comment.api").toggle.linewise.current()<CR>', { desc = "Comment line"})
map('x', '<leader>/', '<ESC><CMD>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>', { desc = "Comment line" })

-- Alpha Dashboard
map("n", "<leader>d", "<cmd>Alpha<cr>", { desc = "Alpha Dashboard" })

-- Aaerial
map("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Aaerial - symbols outline" })
  -- Jump forwards/backwards with '{' and '}'
map("n", "{", "<cmd>AerialPrev<cr>", { desc = "Jump backwards in Aerial" })
map("n", "}", "<cmd>AerialNext<cr>", { desc = "Jump forwards in Aerial" })
  -- Jump up the tree with '[[' or ']]'
map("n", "[[", "<cmd>AerialPrevUp<cr>", { desc = "Jump up and backwards in Aerial" })
map("n", "]]", "<cmd>AerialNextUp<cr>", { desc = "Jump up and forwards in Aerial" })

-- Packer
map("n", "<leader>pc", "<cmd>PackerCompile<CR>", { desc = "Compile" })
map("n", "<leader>pi", "<cmd>PackerInstall<CR>", { desc = "Install" })
map("n", "<leader>ps", "<cmd>PackerSync<CR>", { desc = "Sync" })
map("n", "<leader>pS", "<cmd>PackerStatus<CR>", { desc = "Status" })
map("n", "<leader>pu", "<cmd>PackerUpdate<CR>", { desc = "Update" })

-- LSP
map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "LSP go to declaration" })
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "LSP go to definition" })
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "LSP hoover" })
map("n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "LSP implementation" })
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "LSP references" })
map("n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", { desc = "LSP diagnostic open float" })
map("n", "<leader>lf", "<cmd>lua vim.lsp.buf.formatting()<cr>", { desc = "Formatting" })
map("n", "<leader>li", "<cmd>Mason<cr>", { desc = "Mason install LSP" })
-- map("n", "<leader>lI", "<cmd>LspInstallInfo<cr>", { desc = " Install info" })
map("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code action" })
map("n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", { desc = "Go to next buffer" })
map("n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", { desc = "Go to prev buffer" })
map("n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename buffer" })
map("n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", { desc = "Signature help" })
map("n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", { desc = "Set loc list" })

-- Git
map("n", "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", { desc = "Next Hunk" })
map("n", "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", { desc = "Prev Hunk" })
map("n", "<leader>gl","<cmd>lua require 'gitsigns'.blame_line()<cr>", { desc = "Blame" })
map("n", "<leader>gp","<cmd>lua require 'gitsigns'.preview_hunk()<cr>", { desc = "Preview Hunk" })
map("n", "<leader>gr","<cmd>lua require 'gitsigns'.reset_hunk()<cr>", { desc = "Reset Hunk" })
map("n", "<leader>gR","<cmd>lua require 'gitsigns'.reset_buffer()<cr>", { desc = "Reset Buffer" })
map("n", "<leader>gs","<cmd>lua require 'gitsigns'.stage_hunk()<cr>", { desc = "Stage Hunk" })
map("n", "<leader>gu","<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", { desc = "Undo Stage Hunk" })
map("n", "<leader>go","<cmd>Telescope git_status<cr>", { desc = "Open changed file" })
map("n", "<leader>gb","<cmd>Telescope git_branches<cr>", { desc = "Checkout branch" })
map("n", "<leader>gc","<cmd>Telescope git_commits<cr>", { desc = "Checkout commit" })
map("n", "<leader>gd","<cmd>Gitsigns diffthis HEAD<cr>", { desc = "Diff" })

-- Run Code
-- Python
map("n", "<leader>rp", "<cmd>TermExec cmd='python3 %'<cr>", { desc = "Python"} )
map("n", "<leader>rb", "<cmd>lua _PYTHON_TOGGLE()<cr>", { desc = "BPython Terminal" })
map("n", "<leader>rw", "<cmd>lua _WEB_TOGGLE()<cr>", { desc = "Web Preview"} )
-- HTML live preview - prestalo to fungovat :(
-- map("n", "<leader>rw", "<cmd>Bracey<cr>", { desc = "HTML live preview"} )
-- map("n", "<leader>rs", "<cmd>BraceyStop<cr>", { desc = "HTML Stop live preview"} )
