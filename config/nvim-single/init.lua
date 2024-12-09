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
  map("n", "<A-x>", ":w<cr>:luafile %<cr>", { desc = "Reload Lua" })
end

keymaps()

-- +--------------------------------------------------------------------------+
-- OPTIONS
-- +--------------------------------------------------------------------------+

local function options()
	vim.opt.clipboard = "unnamedplus" -- Use the system clipboard
	vim.opt.mouse = "a" -- Allow the use of the mouse
	vim.opt.number = true -- Allow absolute line numbers
	vim.opt.tabstop = 2 -- Number of space in a tab

	-- nastavenia kurzoru
	if os_type == "wsl" then
		vim.opt.guicursor = {"n-v-c:block,i-ci-ve:bar-blinkwait200-blinkoff150-blinkon150"}  -- Cursor help: guicursor
		vim.opt.shell = "/bin/bash"
	elseif os_type == "linux" then
		vim.opt.shell = "/bin/zsh"
	elseif os_type == "windows" then
		vim.opt.shell = "pwsh.exe"
		vim.opt.shellcmdflag = "-NoLogo"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
	else
		vim.opt.shell = "/bin/zsh"
	end

end

options()

