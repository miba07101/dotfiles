local mygroup = vim.api.nvim_create_augroup("vimrc", { clear = true })

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 300,
		})
	end,
	group = mygroup,
	desc = "Briefly highlight yanked text",
})

-- unfold at open
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = { "*.py", "*.css", "*.scss", "*.html" },
	command = [[:normal zR]], -- zR-open, zM-close folds
	group = mygroup,
	desc = "Unfold",
})

-- autoformat code on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.py", "*.json", "*.css", "*.scss" },
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
	group = mygroup,
	desc = "Autoformat code on save",
})

-- auto linting
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	pattern = { "*" },
  callback = function()
    require("lint").try_lint()
  end,
})

-- sass compilation on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.sass", "*.scss" },
	command = [[:silent exec "!sass --no-source-map %:p %:r.css"]],
	group = mygroup,
	desc = "SASS compilation on save",
})

-- shiftwidth setup
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "py", "java", "cs" },
	callback = function()
		vim.bo.shiftwidth = 4
	end,
	group = mygroup,
	desc = "Set shiftwidth to 4 in these filetypes",
})

-- restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		if vim.fn.line("'\"") >= 1 and vim.fn.line("'\"") <= vim.fn.line("$") and vim.fn.expand("&ft") ~= "commit" then
			vim.cmd('normal! g`"')
		end
	end,
	group = mygroup,
	desc = "Restore cursor position",
})

-- show cursor line only in active window
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

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd("FocusGained", {
	command = [[:checktime]],
	group = mygroup,
	desc = "Update file when there are changes",
})

-- windows to close with "q"
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

-- don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", {
	command = [[set formatoptions-=cro]],
	group = mygroup,
	desc = "Don't auto comment new line",
})

-- open HELP on right side
-- vim.api.nvim_create_autocmd("BufEnter", {
--   command = [[if &buftype == 'help' | wincmd L | endif]],
--   group = mygroup,
--   desc = "Help on right side",
-- })

-- open terminal at same location as opened file
vim.api.nvim_create_autocmd("BufEnter", {
	command = [[silent! lcd %:p:h]],
	group = mygroup,
	desc = "Open terminal in same location as opened file",
})

-- terminal options
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.opt_local.relativenumber = false
		vim.opt_local.number = false
		vim.cmd("startinsert!")
	end,
	group = mygroup,
	desc = "Terminal Options",
})

-- remove trailling whitespace (medzeru na konci) when SAVE file
vim.api.nvim_create_autocmd("BufWritePre", {
	command = [[%s/\s\+$//e]],
	group = mygroup,
	desc = "Remove tarilling whitespace",
})

-- resize vim windows when overall window size changes
vim.api.nvim_create_autocmd("VimResized", {
	command = [[wincmd =]],
	group = mygroup,
	desc = "Resize windows to equal",
})

-- PYTHON
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
