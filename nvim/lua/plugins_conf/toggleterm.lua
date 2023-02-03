local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

toggleterm.setup({
	size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
})

local Terminal = require("toggleterm.terminal").Terminal
local python = Terminal:new({ direction = "horizontal", cmd = "bpython", hidden = true })

function _PYTHON_TOGGLE()
	python:toggle()
end

local web = Terminal:new({ direction = "horizontal", cmd = "live-server ." })

function _WEB_TOGGLE()
	web:toggle()
end
