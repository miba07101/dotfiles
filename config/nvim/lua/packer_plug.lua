local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- Basic plugins
  use "wbthomason/packer.nvim" -- Have packer manage itself
  use "nvim-lua/plenary.nvim" -- Useful lua functions used by lots of plugins
  use "lewis6991/impatient.nvim"
  use "rcarriga/nvim-notify"

  -- Colorscheme
  use "rebelot/kanagawa.nvim"
  use "AlexvZyl/nordic.nvim"
  use "aktersnurra/no-clown-fiesta.nvim"

  -- Statusline, bufferline
  use "nvim-lualine/lualine.nvim"
  use "akinsho/bufferline.nvim"

  -- UI
  use "goolord/alpha-nvim" -- Start screen
  -- use "ahmedkhalf/project.nvim"

  -- File explorer
  use "nvim-neo-tree/neo-tree.nvim"
  use "kyazdani42/nvim-web-devicons"
  use "MunifTanjim/nui.nvim"

  -- Comment, AutoPairs, AutoTags
  use "numToStr/Comment.nvim"
  use "JoosepAlviste/nvim-ts-context-commentstring"
  use "windwp/nvim-autopairs"
  use "windwp/nvim-ts-autotag"

  -- Terminal
  use "akinsho/toggleterm.nvim"

  -- Misc
  use "folke/which-key.nvim" -- Keymap popup
  use "famiu/bufdelete.nvim" -- Better buffer closing
  use "lukas-reineke/indent-blankline.nvim"
  use "norcalli/nvim-colorizer.lua" -- Color highlighting

  -- CMP autocompletion plugins
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "saadparwaiz1/cmp_luasnip"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-nvim-lua"

  -- Snippets
  use "L3MON4D3/LuaSnip"
  use "rafamadriz/friendly-snippets"

  -- LSP
  use "neovim/nvim-lspconfig"
  use {'williamboman/mason.nvim'}
  use {'williamboman/mason-lspconfig.nvim'}
  -- use "williamboman/nvim-lsp-installer"
  use "jose-elias-alvarez/null-ls.nvim"
  -- use "RRethy/vim-illuminate"
  -- use "stevearc/aerial.nvim" -- LSP symbols
  -- use "ray-x/lsp_signature.nvim"

  -- Telescope (Fuzzy Finder)
  use "nvim-telescope/telescope.nvim"
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'}

  -- Treesitter
  use "nvim-treesitter/nvim-treesitter"

  -- Git
  use "lewis6991/gitsigns.nvim"

  -- DAP
  -- use "mfussenegger/nvim-dap"
  -- use "rcarriga/nvim-dap-ui"
  -- use "ravenxrz/DAPInstall.nvim"

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
