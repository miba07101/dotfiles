local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local setup = {
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 5, -- spacing between columns
    align = "center", -- align columns left, center or right
  },
  triggers_blacklist = {
    -- list of mode / prefixes that should never be hooked by WhichKey
    i = { "i", "j", "k" },
    v = { "j", "k" },
  },
}

local opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
  g = { name = "Git" },
  l = { name = "LSP" },
  p = { name = "Packer" },
  r = { name = "Run Code" },
  s = { name = "Search" },
  t = { name = "Terminal" },
  w = { name = "Window split" },
}

which_key.setup(setup)
which_key.register(mappings, opts)
