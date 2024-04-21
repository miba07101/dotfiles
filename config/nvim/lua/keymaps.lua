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

-- Visual block mode - oznacovanie stlpcov
-- map("n", "<A-v>", "<C-q>", { desc = "Visual block mode" })
-- map("n", "<C-q>", "<C-v>", { desc = "Visual block mode" })

-- Help
map("n", "<leader>hs", "<cmd>h nvim-surround.usage<cr>", { desc = "Surround help" })

-- Windows
map("n", "<leader>wv", "<C-w>v", { desc = "Vertical" })
map("n", "<leader>wh", "<C-w>s", { desc = "Horizontal" })
map("n", "<leader>w=", "<C-W>=", { desc = "Equal" })
map("n", "<leader>wm","<cmd>MaximizerToggle<CR>", { desc = "Maximize" })

map("n", "<C-Up>", "<C-w>k", { desc = "Go UP" })
map("n", "<C-Down>", "<C-w>j", { desc = "Go DOWN" })
map("n", "<C-Left>", "<C-w>h", { desc = "Go LEFT" })
map("n", "<C-Right>", "<C-w>l", { desc = "Go RIGHT" })
map("n", "<S-Up>", ":resize +2<CR>", { desc = "Resize UP" })
map("n", "<S-Down>", ":resize -2<CR>", { desc = "Resize DOWN" })
map("n", "<S-Left>", ":vertical resize -2<CR>", { desc = "Resize LEFT" })
map("n", "<S-Right>", ":vertical resize +2<CR>", { desc = "Resize RIGHT" })
map("n", "<S-Right>", ":vertical resize +2<CR>", { desc = "Resize RIGHT" })
map("n", "<leader>wlh", "<cmd>windo wincmd K<cr>", { desc = "Horizontal layout" })
map("n", "<leader>wlv", "<cmd>windo wincmd H<cr>", { desc = "Vertical layout" })

-- Buffers
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<A-Right>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<A-Left>", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<A-UP>", ":bp<BAR>bd#<CR>", { desc = "Quit buffer" })
map("n", "<A-Down>", ":bp<BAR>bd#<CR>", { desc = "Quit buffer" })
map("n", "<leader>bc", ":bp<BAR>bd#<CR>", { desc = "Quit buffer" })

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
map("n", "x", '"_x', { desc = "Delete character no yank" })

-- MIX
map("i", "ii", "<ESC>", { desc = "INSERT mode toggle" })
map("n", "<A-a>", "<ESC>ggVG<CR>", { desc = "Select all text" })

-- Comment - mozem pouzit aj nastavenie v plugin-manager.lua
map("n", "<leader>/", '<CMD>lua require("Comment.api").toggle.linewise.current()<CR>', { desc = "comment" })
map(
	"x",
	"<leader>/",
	'<ESC><CMD>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>',
	{ desc = "comment" }
)

-- Lazy
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "lazy" })

-- Telescope
map("n", "<leader>fx", "<cmd>Telescope<cr>", { desc = "telescope" })
map("n", "<leader>fe", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", { desc = "file browser" })
map("n", "<leader>fn", "<cmd>Telescope notify<cr>", { desc = "notifications" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "files" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<cr>", { desc = "words" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "recent files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "buffers" })
map("n", "<leader>fc", "<cmd>Telescope colorscheme<cr>", { desc = "colorscheme" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "diagnostics" })

-- LSP
map("n", "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "definition" })
map("n", "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "declaration" })
map("n", "<leader>lk", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "hoover" })
map("n", "<leader>lI", "<cmd>lua vim.lsp.buf.implementation()<cr>", { desc = "implementation" })
map("n", "<leader>lr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "references" })
map("n", "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "rename" })
map("n", "<leader>lf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "formatting" })
map("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "code action" })
map("n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<cr>", { desc = "signature help" })
map("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "server info" })

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

map("n", "<leader>dd", toggle_diagnostics, { desc = "diagnostic toggle" })
map("n", "<leader>dn", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", { desc = "next" })
map("n", "<leader>dp", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", { desc = "prev" })
map("n", "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<cr>", { desc = "loc list" })
map("n", "<leader>df", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "open float" })
map("n", "<leader>dt","<cmd>windo diffthis<CR>", { desc = "differ this" })
map("n", "<leader>do","<cmd>diffoff!<CR>", { desc = "differ off" })
map("n", "<leader>du","<cmd>diffupdate<CR>", { desc = "differ update" })

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

-- NeoVim
map("n", "<leader>vn", "<cmd>set relativenumber!<cr>", { desc = "numbers toggle" })
-- map("n", "<leader>vl", "<cmd>IBLToggle<cr>", { desc = "blankline toggle" })
map("n", "<leader>vb", "<cmd>let &bg=(&bg == 'dark' ? 'light' : 'dark' )<CR>", { desc = "background toggle" })
map("n", "<leader>vc", function()
	if vim.o.conceallevel > 0 then
		vim.o.conceallevel = 0
	else
		vim.o.conceallevel = 1
	end
end, { desc = "conceal level toggle" })
map("n", "<leader>vk", function()
	if vim.o.concealcursor == "n" then
		vim.o.concealcursor = ""
	else
		vim.o.concealcursor = "n"
	end
end, { desc = "conceal cursor toggle" })

-- Code Run
map("n", "<leader>cw", "<cmd>lua _WEB_TOGGLE()<cr>", { desc = "web preview" })

-- CMP completion
map("i", "<M-e>", "<cmd>lua require('cmp').setup({enabled = true})<cr>", { desc = "cmp enable" })
map("i", "<M-d>", "<cmd>lua require('cmp').setup({enabled = false})<cr>", { desc = "cmp disable" })

-- Python
map("n", "<leader>pe", "<cmd>lua require('swenv.api').pick_venv()<cr>", { desc = "pick venvs" })
map("n", "<leader>pr", "<cmd>w<cr><cmd>TermExec cmd='python3 %' go_back=0<cr>", { desc = "run code" })
map("n", "<leader>pt", "<cmd>lua _PYTHON_TOGGLE()<cr>", { desc = "ipython term" })

-- Quarto
map("n", "<leader>qa", "<cmd>QuartoActivate<cr>", { desc = "activate" })
map("n", "<leader>qp", "<cmd>lua require'quarto'.quartoPreview()<cr>", { desc = "preview" })
map("n", "<leader>qq", "<cmd>lua require'quarto'.quartoClosePreview()<cr>", { desc = "quit" })
map("n", "<leader>qh", "<cmd>QuartoHelp<cr>", { desc = "help" })

-- Otter (for quarto completion)
map("n", "<leader>qod", "<cmd>lua require('otter').ask_definition()<cr>", { desc = "definition" })
map("n", "<leader>qoh", "<cmd>lua require('otter').ask_hover()<cr>", { desc = "hover" })
map("n", "<leader>qor", "<cmd>lua require('otter').ask_references()<cr>", { desc = "references" })
map("n", "<leader>qon", "<cmd>lua require('otter').ask_rename()<cr>", { desc = "rename" })
map("n", "<leader>qof", "<cmd>lua require('otter').ask_format()<cr>", { desc = "format" })

-- Obsidian
map("n", "<leader>ol", "<cmd>lua require('obsidian').util.gf_passthrough()<cr>", { desc = "wiki links" })
map("n", "<leader>ob", "<cmd>lua require('obsidian').util.toggle_checkbox()<cr>", { desc = "toggle checkbox" })
map("n", "<leader>oo", ":cd /home/vimi/OneDrive/Dokumenty/zPoznamky/Obsidian/<cr>", { desc = "open vault" })
map("n", "<leader>on", ":ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>", { desc = "convert note" })
map("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>", { desc = "strip date - must have cursor on title" })
map("n", "<leader>os", ":Telescope find_files search_dirs={\"/home/vimi/OneDrive/Dokumenty/zPoznamky/Obsidian/\"}<cr>", { desc = "search in vault" })
map("n", "<leader>oz", ":Telescope live_grep search_dirs={\"/home/vimi/OneDrive/Dokumenty/zPoznamky/Obsidian/\"}<cr>", { desc = "search in notes" })
-- for review workflow
map("n", "<leader>orm", ":!mv '%:p' /home/vimi/OneDrive/Dokumenty/zPoznamky/Obsidian/zzz<cr>:bd<cr>", { desc = "move note" })
map("n", "<leader>ord", ":!rm '%:p'<cr>:bd<cr>", { desc = "delete note" })
