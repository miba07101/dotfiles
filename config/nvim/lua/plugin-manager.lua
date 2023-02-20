local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
-- UI
    { "nvim-lua/plenary.nvim" },

    { "goolord/alpha-nvim",
        config = function()
          local dashboard = require "alpha.themes.dashboard"

          -- header
          dashboard.section.header.val = {
          [[      .__        .__ ]],
          [[___  _|__| _____ |__|]],
          [[\  \/ /  |/     \|  |]],
          [[ \   /|  |  Y Y  \  |]],
          [[  \_/ |__|__|_|  /__|]],
          [[               \/    ]],
          }

          -- buttons
          dashboard.section.buttons.val = {
            dashboard.button("r", " " .. " Recent files", "<cmd>Telescope oldfiles<cr>"),
            dashboard.button("e", " " .. " New file", "<cmd>ene <bar> startinsert <cr>"),
            dashboard.button("f", " " .. " Find file", "<cmd>Telescope find_files<cr>"),
            dashboard.button("p", " " .. " Python", '<cmd>Telescope file_browser path="~/git-repos/python/"<cr>'),
            dashboard.button("c", " " .. " Config", "<cmd>e ~/.config/nvim/lua/plugin-manager.lua<cr>"),
            dashboard.button("q", " " .. " Quit", ":qa<CR>"),
          }

          -- footer
          local function footer()
            return "Učiť sa, učiť sa, učiť sa! --V.I.Lenin"
          end

          dashboard.section.footer.val = footer()

          dashboard.section.header.opts.hl = "Include"
          dashboard.section.buttons.opts.hl = "Keyword"
          dashboard.section.footer.opts.hl = "Type"

          dashboard.opts.opts.noautocmd = true
          require("alpha").setup(dashboard.opts)
        end
    },

    { "rcarriga/nvim-notify",
        config = function()
          require("notify").setup({
            opts = {
                  timeout = 1000,
                  max_height = function()
                    return math.floor(vim.o.lines * 0.75)
                  end,
                  max_width = function()
                    return math.floor(vim.o.columns * 0.75)
                  end,
                  stages = "static",
                },
          })
        end,
        init = function()
          vim.notify = require("notify")
        end,
    },

-- Statusline, bufferline
    {
      "nvim-lualine/lualine.nvim",
        config = function()
          require("plugins.lualine")
        end,
    },

-- Comment, AutoPairs, AutoTags
    { "numToStr/Comment.nvim",
      config = function()
        require("Comment").setup({
        toggler = {
          line = '<leader>/',
        },
        opleader = {
          line = '<leader>/',
        },
      })
      end,
    },

    {
      "windwp/nvim-autopairs",
      config = function()
        require("nvim-autopairs").setup()
      end,
    },

-- Terminal
    {
      "akinsho/toggleterm.nvim",
      config = function()
        require("toggleterm").setup({
          size = function(term)
            if term.direction == "horizontal" then
              return 15
            elseif term.direction == "vertical" then
              return vim.o.columns * 0.4
            end
          end,
      })
      local Terminal = require("toggleterm.terminal").Terminal
      local bpython = Terminal:new({ direction = "horizontal", cmd = "bpython", hidden = true })
      local web = Terminal:new({ direction = "horizontal", cmd = "live-server ." })
      local lazygit = Terminal:new({ direction = "float", cmd = "lazygit", dir = "git_dir", hidden = true })

        function _BPYTHON_TOGGLE()
          bpython:toggle()
        end

        function _WEB_TOGGLE()
          web:toggle()
        end

        function _LAZYGIT_TOGGLE()
          lazygit:toggle()
        end

      end,
    },

-- Indent blank line
    {
      "lukas-reineke/indent-blankline.nvim",
      config = function()
        require("indent_blankline").setup({
          show_trailing_blankline_indent = false,
          use_treesitter = true,
          char = "▏",
          context_char = "▏",
          show_current_context = true,
        })
      end,
    },

-- Colorizer
    {
      "norcalli/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup()
      end,
    },

-- Colorscheme
    {
      "rebelot/kanagawa.nvim",
      priority = 1000,
      config = function()
        require("kanagawa").setup()
        vim.cmd("colorscheme kanagawa")
      end,
    },
    { "AlexvZyl/nordic.nvim" },
    { "aktersnurra/no-clown-fiesta.nvim" },

-- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      dependencies = {
        "JoosepAlviste/nvim-ts-context-commentstring",
        "windwp/nvim-ts-autotag",
      },
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "python", "bash", "lua", "html", "css" },
          highlight = { enable = true },
          context_commentstring = { enable = true },
          autopairs = { enable = true },
          autotag = { enable = true },
          incremental_selection = { enable = true },
          indent = { enable = true },
        })
      end,
    },

-- Telescope
    {
      "nvim-telescope/telescope.nvim",
      dependencies = {
        "nvim-telescope/telescope-file-browser.nvim",
        "nvim-tree/nvim-web-devicons",
      },
      lazy = false,
      config = function()
        require("telescope").setup({
          defaults = {
            path_display = { "truncate" },
            initial_mode = "normal", -- insert
            sorting_strategy = "ascending",
            layout_config = {
              horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                results_width = 0.8,
              },
              width = 0.87,
              height = 0.80,
              preview_cutoff = 120,
            },
          },
          extensions = {
            file_browser = {
              hidden = true,
              grouped = true, -- show directories first
            },
          },
        })
        require("telescope").load_extension("file_browser")
        require("telescope").load_extension("notify")
      end,
    },

-- LSP
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        -- LSP
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        -- Linters / Formaters
        "jose-elias-alvarez/null-ls.nvim",
      },
      config = function()
        require("plugins.lsp")
      end,
  },

-- CMP Completitions
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "lukas-reineke/cmp-under-comparator",
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
      },
      config = function()
        require("plugins.cmp")
      end,
    },

-- Keybidings WhichKey
    {
      "folke/which-key.nvim",
      lazy = false,
      config = function()
        require("which-key").setup({
          triggers_blacklist = {
            i = { "i", "j", "k" },
            v = { "j", "k" },
          },
        })
        local opts = {
          prefix = "<leader>",
          silent = true,
          nowait = true, -- use `nowait` when creating keymaps
        }
        local mappings = {
          b = { name = "Buffers" },
          c = { name = "Code" },
          f = { name = "Telescope" },
          g = { name = "Git" },
          l = { name = "LSP" },
          p = { name = "Lazy" },
          t = { name = "Terminal" },
          v = { name = "NeoVim" },
          w = { name = "Windows" },
        }
        require("which-key").register(mappings,opts)
      end,
    },
})
