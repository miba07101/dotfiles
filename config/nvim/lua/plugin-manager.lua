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
      require("kanagawa").setup({
        overrides = function(colors)
          local theme = colors.theme
          return {
            -- change cmd popup menu colors
            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
            -- PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2, italic = true },
            PmenuSel = { fg = colors.palette.surimiOrange, bg = theme.ui.bg_p2 },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
            FloatBorder = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
            -- change cmp items colors
            CmpItemKindVariable = { fg = colors.palette.crystalBlue, bg = "NONE" },
            CmpItemKindInterface = { fg = colors.palette.crystalBlue, bg = "NONE" },
            CmpItemKindFunction = { fg = colors.palette.oniViolet, bg = "NONE" },
            CmpItemKindMethod = { fg = colors.palette.oniViolet, bg = "NONE" },
          }
      end,
      })
      vim.cmd("colorscheme kanagawa")
    end,
  },

  { "AlexvZyl/nordic.nvim",
    -- priority = 1000,
    -- config = function()
    --   require("nordic").setup()
    --   vim.cmd("colorscheme nordic")
    -- end,
  },

  { "aktersnurra/no-clown-fiesta.nvim"
  },

  { "olivercederborg/poimandres.nvim"
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
      -- If you want insert `(` after select function or method item
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
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
          cmd = "ipython",
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
        additional_vim_regex_highlighting = true,
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
        -- indent = { enable = true },
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
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      -- codeium
      "jcdickinson/codeium.nvim",
      -- sorting
      "lukas-reineke/cmp-under-comparator",
      -- snippets
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      -- icons
      "onsails/lspkind.nvim",
    },
    config = function()
      -- require("plugins.cmp")
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require('lspkind')

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      -- luasnip nacita 'snippets' z friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- codeium
      -- after install run ":Codeium Auth" and insert tokken from web
      require("codeium").setup({})

      cmp.setup({
        -- enabled = function()
        --   -- disable completion in comments
        --   if require"cmp.config.context".in_treesitter_capture("comment")==true
              -- or require"cmp.config.context".in_syntax_group("Comment") then
        --     return false
        --   else
        --     return true
        --   end
        -- end,
        enabled = true,
        snippet = {
          expand = function(args)
             -- for luasnip
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-q>"] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
          -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
          ["<C-y>"] = cmp.config.disable,
          -- Accept currently selected item. Set `select` to `false`
          -- to only confirm explicitly selected items.
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- they way you will only jump inside the snippet region
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            ellipsis_char = '...',
            symbol_map = { Codeium = "", },
            menu = ({
              buffer = "[buf]",
              codeium = "[cod]",
              luasnip = "[snip]",
              nvim_lsp = "[lsp]",
              nvim_lua = "[lua]",
            })
          }),
        },
        sources = {
          { name = "buffer" },
          { name = "codeium" },
          { name = "luasnip" },
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
          { name = "path" },
          { name = 'nvim_lsp_signature_help' },
        },
        sorting = {
              comparators = {
                  cmp.config.compare.offset,
                  cmp.config.compare.exact,
                  cmp.config.compare.score,
                  require "cmp-under-comparator".under,
                  cmp.config.compare.kind,
                  cmp.config.compare.sort_text,
                  cmp.config.compare.length,
                  cmp.config.compare.order,
              },
          },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp.config.window.bordered({
            -- farby pre winhighlight su definovane v kanagawa teme
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
            scrollbar = true,
          }),
          documentation = cmp.config.window.bordered({
            -- farby pre winhighlight su definovane v kanagawa teme
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          }),
        },
        view = {
          entries = "custom"
        },
        experimental = {
          ghost_text = true,
          -- ghost_text = {hlgroup = "Comment"}
        },
      })
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
        h = { name = "help" },
        i = { name = "icons" },
        l = { name = "lsp" },
        n = { name = "neorg" },
        p = { name = "python" },
        t = { name = "terminal" },
        v = { name = "neovim" },
        w = { name = "windows" },
      }
      require("which-key").register(mappings, opts)
    end,
  },

  -- Neorg
  { "nvim-neorg/neorg",
    -- lazy-load on filetype
    -- ft = "norg",
    build = ":Neorg sync-parsers",
    opts = {
      load = {
        ["core.defaults"] = {}, -- Loads default behaviour
        ["core.norg.concealer"] = {}, -- Adds pretty icons to your documents
        ["core.norg.dirman"] = { -- Manages Neorg workspaces
          config = {
              workspaces = {
                  python_notes = "~/git-repos/python/00-notes",
              },
              default_workspace = "python_notes",
            },
        },
      },
    },
  },

  -- -- Fidget - show LSP server progress
  -- { "j-hui/fidget.nvim",
  --   config = function()
  --     require("fidget").setup()
  --   end,
  -- }
 })
