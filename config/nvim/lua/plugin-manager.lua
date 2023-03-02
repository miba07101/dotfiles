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
  -- Colorscheme
  { "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup()
      vim.cmd("colorscheme kanagawa")
    end,
  },

  { "AlexvZyl/nordic.nvim"

  },

  { "aktersnurra/no-clown-fiesta.nvim"

  },

  -- UI
  { "nvim-lua/plenary.nvim"

  },

  { "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup()
    end,
  },

  { "goolord/alpha-nvim",
    config = function()
      local dashboard = require("alpha.themes.dashboard")

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
        -- dashboard.button("p", " " .. " Python", "<cmd>Telescope file_browser path=~/git-repos/python/<cr>"),
        dashboard.button(
          "p",
          " " .. " Projects",
          "<cmd>lua require'telescope'.extensions.project.project{ display_type = 'full' }<cr>"
        ),
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
    end,
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

  { "ziontee113/icon-picker.nvim",
    config = function()
      require("icon-picker").setup({
        disable_legacy_commands = true,
      })
    end,
  },

  -- Statusline, bufferline
  { "nvim-lualine/lualine.nvim",
    config = function()
      require("plugins.lualine")
    end,
  },

  -- Comment
  { "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        -- toggler = {
        --   line = '<leader>/',
        -- },
        -- opleader = {
        --   line = '<leader>/',
        -- },
      })
    end,
  },

  -- AutoPairs
  { "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Surround
  { "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Swenv - change python environments
  { "AckslD/swenv.nvim",
    config = function()
      require("swenv").setup({
        get_venvs = function(venvs_path)
          return require("swenv.api").get_venvs(venvs_path)
        end,
        venvs_path = vim.fn.expand("~/python-venv"), -- zadat cestu k envs
        post_set_venv = function()
          vim.cmd(":LspRestart<cr>")
        end,
      })
    end,
  },

  -- Terminal
  { "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
      })
      local Terminal = require("toggleterm.terminal").Terminal

      function _RANGER_TOGGLE()
        local Path = require("plenary.path")
        local path = vim.fn.tempname()
        local ranger = Terminal:new({
          direction = "float",
          cmd = ('ranger --choosefiles "%s"'):format(path),
          close_on_exit = true,
          on_close = function()
            Data = Path:new(path):read()
            vim.schedule(function()
              vim.cmd("e " .. Data)
            end)
          end,
        })
        ranger:toggle()
      end

      function _PYTHON_TOGGLE()
        local python = Terminal:new({
          direction = "horizontal",
          cmd = "python3",
          hidden = true,
        })
        python:toggle()
      end

      function _WEB_TOGGLE()
        local web = Terminal:new({
          direction = "horizontal",
          cmd = "live-server .",
        })
        web:toggle()
      end

      function _LAZYGIT_TOGGLE()
        local lazygit = Terminal:new({
          direction = "float",
          cmd = "lazygit",
          dir = "git_dir",
          hidden = true,
        })
        lazygit:toggle()
      end
    end,
  },

  -- Indent blank line
  { "lukas-reineke/indent-blankline.nvim",
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
  { "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      "windwp/nvim-ts-autotag",
      "HiPhish/nvim-ts-rainbow2",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "python", "bash", "lua", "html", "css" },
        highlight = { enable = true },
        additional_vim_regex_highlighting = false,
        context_commentstring = { enable = true },
        autopairs = { enable = true },
        autotag = { enable = true },
        rainbow = { enable = true,
          disable = {},
          query = 'rainbow-parens',
          strategy = require 'ts-rainbow.strategy.global',
          max_file_lines = 3000
        },
        incremental_selection = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Telescope
  { "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope-project.nvim",
    },
    lazy = false,
    config = function()
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions
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
            mappings = {
              ["n"] = {
                ["<RIGHT>"] = actions.select_default,
                ["<LEFT>"] = fb_actions.goto_parent_dir,
              },
            },
          },
          project = {
            base_dirs = {
              { path = "~/git-repos/epd/" },
              { path = "~/git-repos/python/" },
            },
            -- hidden_files = true,
          },
        },
      })
      require("telescope").load_extension("file_browser")
      require("telescope").load_extension("project")
      require("telescope").load_extension("notify")
    end,
  },

  -- LSP
  { "neovim/nvim-lspconfig",
    dependencies = {
      -- LSP
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      -- Linters / Formaters
      "jose-elias-alvarez/null-ls.nvim",
      "jay-babu/mason-null-ls.nvim",
    },
    config = function()
      require("plugins.lsp")
    end,
  },

  -- CMP Completitions
  { "hrsh7th/nvim-cmp",
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
  { "folke/which-key.nvim",
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
        b = { name = "buffers" },
        c = { name = "code" },
        d = { name = "diagnostic" },
        f = { name = "telescope" },
        g = { name = "git" },
        i = { name = "icons" },
        l = { name = "lsp" },
        p = { name = "python" },
        t = { name = "terminal" },
        v = { name = "neovim" },
        w = { name = "windows" },
      }
      require("which-key").register(mappings, opts)
    end,
  },

  -- -- Fidget - show LSP server progress
  -- { "j-hui/fidget.nvim",
  --   config = function()
  --     require("fidget").setup()
  --   end,
  -- }
})
