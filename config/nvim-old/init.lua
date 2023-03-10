require "settings"
require "keymaps"
require "packer_plug"
require "colorscheme"
require "autocommands"

-- Plugins configuration

require "plugins_conf.alpha"
require "plugins_conf.autopairs"
require "plugins_conf.bufferline"
require "plugins_conf.cmp"
require "plugins_conf.colorizer"
require "plugins_conf.comment"
-- require "plugins_conf.gitsigns"
-- require "plugins_conf.illuminate"
require "plugins_conf.impatient"
require "plugins_conf.indent-line"
require "plugins_conf.lualine"
require "plugins_conf.luasnip"
require "plugins_conf.lsp"
-- require "plugins_conf.lsp.null-ls"
-- require "plugins_conf.aerial"
require "plugins_conf.neo-tree"
require "plugins_conf.notify"
-- require "plugins_conf.project"
require "plugins_conf.telescope"
require "plugins_conf.toggleterm"
require "plugins_conf.treesitter"
require "plugins_conf.which-key"

local is_wsl = vim.fn.has("wsl")
if is_wsl == 1
  then
    vim.opt.guicursor = {"n-v-c:block,i-ci-ve:bar-blinkwait200-blinkoff150-blinkon150"}  -- Cursor help: guicursor
end

