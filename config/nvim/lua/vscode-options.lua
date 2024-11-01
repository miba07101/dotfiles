-- Options
-- yank/copy to clipboard
vim.opt.clipboard:append("unnamedplus")

-- Keymaps
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- remap leader key
map("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- paste preserves primal yanked piece
map("v", "p", '"_dP', opts)

-- better indent handling
map({"n", "v"}, "<", "<gv", opts) 
map({"n", "v"}, ">", ">gv", opts)

-- removes highlighting after escaping vim search
map("n", "<Esc>", "<Esc>:noh<CR>", opts)
