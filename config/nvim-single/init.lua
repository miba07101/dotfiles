--https://github.com/benfrain/neovim/blob/main/lua/options.lua
--https://github.com/YanivZalach/Vim_Config_NO_PLUGINS/blob/main/.vimrc
--https://github.com/NormTurtle/Windots/blob/main/vi/init.lua
--https://github.com/ntk148v/neovim-config/blob/master/lua/options.lua
--https://github.com/sodabyte/minimal-nvim/blob/main/lua/config/options.lua
-- Determine the operating system
local function detect_os_type()
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
end

local os_type = detect_os_type()

print("detected os: " .. detect_os_type())

-- +--------------------------------------------------------------------------+
-- KEYMAPS
-- +--------------------------------------------------------------------------+

local function keymaps()
  -- Wrapper for mapping custom keybindings
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
  map("n", "<C-s>", ":w<cr>", { desc = "Save" })
  map("n", "W", ":wq<cr>", { desc = "Save-Quit" })
  map("n", "Q", ":q!<cr>", { desc = "Quit" })
  map("n", "<leader>x", ":w<cr>:luafile %<cr>", { desc = "Reload Lua" })
end

keymaps()

-- +--------------------------------------------------------------------------+
-- OPTIONS
-- +--------------------------------------------------------------------------+

local function options()
	local opt = vim.opt

	-- indention
	local indent = 2
	opt.list = true
	opt.listchars = { eol = "¬", tab = "› " }
	opt.autoindent = true -- auto indentation
	opt.smartindent = true   -- make indenting smarter
	--opt.softtabstop = indent -- when hitting <BS>, pretend like a tab is removed, even if spaces
	opt.shiftwidth = indent  -- the number of spaces inserted for each indentation
	opt.tabstop = indent     -- insert 2 spaces for a tab
--opt.shiftround = true    -- use multiple of shiftwidth when indenting with "<" and ">"

	opt.clipboard = "unnamedplus" -- Use the system clipboard
	opt.mouse = "a" -- Allow the use of the mouse
	opt.number = true -- Allow absolute line numbers


	-- nastavenia kurzoru
	if os_type == "wsl" then
		opt.guicursor = {"n-v-c:block,i-ci-ve:bar-blinkwait200-blinkoff150-blinkon150"}  -- Cursor help: guicursor
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

end

options()

