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
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		config = function()
      -- local colortheme
      -- local is_night = tonumber(os.date("%H")) >= 19
      -- if is_night then
        -- vim.opt.background = "dark"
        -- colortheme = "colorscheme kanagawa-wave"
      -- else
        -- vim.opt.background = "light"
        -- colortheme = "colorscheme kanagawa-lotus"
      -- end
			require("kanagawa").setup({
        colors = {
          palette = {
            fujiWhite = "#FEFEFA",
            -- lotusWhite0 = "#d5cea3",
            -- lotusWhite1 = "#dcd5ac",
            -- lotusWhite2 = "#e5ddb0",
            -- lotusWhite3 = "#f2ecbc",
            -- lotusWhite4 = "#e7dba0",
            -- lotusWhite5 = "#e4d794",

            -- lotusWhite0 = "#DCD7BA",
            -- lotusWhite1 = "#DCD7BA",
            -- lotusWhite2 = "#DCD7BA",
            -- lotusWhite3 = "#FEFEFA",
            -- lotusWhite4 = "#EDEBDA",
            -- lotusWhite5 = "#EDEBDA",

            -- https://coolors.co/gradient-palette/fefefa-edebda?number=3
            lotusWhite0 = "#EDEBDA",
            lotusWhite1 = "#EDEBDA",
            lotusWhite2 = "#EDEBDA",
            lotusWhite3 = "#FEFEFA", -- baby powder white shade
            lotusWhite4 = "#F6F5EA",
            lotusWhite5 = "#F6F5EA",
          },
					theme = {
						all = {
							ui = {
								bg_gutter = "none",
							},
						},
					},
				},
				overrides = function(colors)
					local theme = colors.theme
					return {
						-- change cmd popup menu colors
						Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_m1 },
						-- PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2, italic = true },
						PmenuSel = { fg = colors.palette.surimiOrange, bg = theme.ui.bg_p2 },
						PmenuSbar = { bg = theme.ui.bg_m1 },
						PmenuThumb = { bg = theme.ui.bg_p2 },
						FloatBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
						-- change cmp items colors
						CmpItemKindVariable = { fg = colors.palette.crystalBlue, bg = "NONE" },
						CmpItemKindInterface = { fg = colors.palette.crystalBlue, bg = "NONE" },
						CmpItemKindFunction = { fg = colors.palette.oniViolet, bg = "NONE" },
						CmpItemKindMethod = { fg = colors.palette.oniViolet, bg = "NONE" },
						-- borderless telescope
						TelescopeTitle = { fg = theme.ui.special, bold = true },
						TelescopePromptNormal = { bg = theme.ui.bg_p1 },
						TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
						TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
						TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
						TelescopePreviewNormal = { bg = theme.ui.bg_dim },
						TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
					}
				end,
			})
			-- vim.cmd(colortheme)
			vim.cmd.colorscheme ("kanagawa")
		end,
	},

	{
		"rmehri01/onenord.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			-- vim.cmd.colorscheme('onenord')
		end,
	},

	{
		"Mofiqul/vscode.nvim",
		priority = 1000,
		config = function()
			local c = require("vscode.colors").get_colors()
			require("vscode").setup({
				-- Enable italic comment
				italic_comments = true,
				-- Override colors (see ./lua/vscode/colors.lua)
				color_overrides = {
					-- vscLineNumber = '#4EFCFE',
				},

				-- Override highlight groups (see ./lua/vscode/theme.lua)
				group_overrides = {
					-- this supports the same val table as vim.api.nvim_set_hl
					-- use colors from this colorscheme by requiring vscode.colors!
					-- Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
				},
			})
			-- vim.cmd("colorscheme vscode")
		end,
	},

	-- UI
	{ "nvim-lua/plenary.nvim" },

	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		config = function()
			require("dressing").setup()
		end,
	},

	{
		"rcarriga/nvim-notify",
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

	-- Comment
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local ft = require("Comment.ft")
			-- JINJA template set both line and block commentstring
			ft.set("jinja", { "{#%s#}", "{#*%s*#}" })
			require("Comment").setup({})
		end,
	},

	-- AutoPairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			-- If you want insert `(` after select function or method item
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
			require("nvim-autopairs").setup({})
		end,
	},

	-- Surround
	{
		"kylechui/nvim-surround",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- Swenv - change python environments
	{
		"AckslD/swenv.nvim",
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

	-- Maximize window
	{ "szw/vim-maximizer" },

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

	-- Colorizer
	{
		"norcalli/nvim-colorizer.lua",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("colorizer").setup()
		end,
	},

	-- Context comment string
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		config = function()
			require("ts_context_commentstring").setup({})
			vim.g.skip_ts_context_commentstring_module = true
		end,
	},

	-- Matchup
	{
		"andymass/vim-matchup",
		config = function()
			-- may set any options here
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},

	-- Quarto
	{
		"quarto-dev/quarto-nvim",
		ft = { "quarto" },
		dev = false,
		opts = {
			lspFeatures = {
				languages = { "python", "bash", "lua", "html", "javascript" },
			},
			-- codeRunner = {
			--   enabled = true,
			--   default_method = 'slime',
			-- },
		},
		dependencies = {
			{
				-- for language features in code cells
				-- added as a nvim-cmp source
				"jmbuhr/otter.nvim",
				dev = false,
				opts = {},
			},
			{
				-- Slime
				-- send code from python/r/qmd documets to a terminal or REPL
				-- like ipython, R, bash
				-- "jpalardy/vim-slime"
			},
		},
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		-- event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"python",
					"bash",
					"lua",
					"html",
					"css",
					"scss",
					"htmldjango",
					"markdown",
					"markdown_inline",
					"latex",
					"yaml",
					"typst",
				},
				highlight = { enable = true },
				autopairs = { enable = true },
				autotag = { enable = true },
				incremental_selection = { enable = true },
				matchup = { enable = true },
			})
		end,
	},

	-- Jinja template syntax
	{ "lepture/vim-jinja", event = { "BufReadPre", "BufNewFile" } },

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-telescope/telescope-file-browser.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		lazy = false,
		config = function()
			local actions = require("telescope.actions")
			local fb_actions = require("telescope").extensions.file_browser.actions
			require("telescope").setup({
				pickers = {
					colorscheme = {
						enable_preview = true,
					},
				},
				defaults = {
					--   path_display = { "truncate" },
					--   initial_mode = "normal", -- insert
					--   sorting_strategy = "ascending",
					layout_strategy = "vertical",
					--   layout_config = {
					--     preview_height = 0.55,
					--   --   horizontal = {
					--   --     prompt_position = "top",
					--   --     preview_width = 0.55,
					--   --     results_width = 0.8,
					--   --   },
					--     width = 0.85,
					--     height = 0.85,
					--     -- preview_cutoff = 130,
					-- },
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
		-- event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- LSP
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			-- Formatting
			"stevearc/conform.nvim",
			-- Linting
			"mfussenegger/nvim-lint",
		},
		config = function()
			require("plugins.lsp")
		end,
	},

	-- Bootstrap Completitions
	{
		"Jezda1337/cmp_bootstrap",
		config = function()
			require("bootstrap-cmp.config"):setup({
				file_types = { "jinja.html", "html" },
				url = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
			})
		end,
	},

	-- Codeium
	{
		"jcdickinson/codeium.nvim",
		-- commit = "62d1e2e5691865586187bd6aa890e43b85c00518",
	},

	-- CMP Completitions
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			-- codeium
			-- "jcdickinson/codeium.nvim",
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
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			-- luasnip nacita 'snippets' z friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })

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
					-- ak to odkomentujem, tak mi nebude robit selkciu v ponuke
					-- ["<Up>"] = cmp.config.disable,
					-- ["<Down>"] = cmp.config.disable,
					["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
					["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
					-- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
					["<C-y>"] = cmp.config.disable,
					-- Accept currently selected item. Set `select` to `false`
					-- to only confirm explicitly selected items.
					["<CR>"] = cmp.mapping.confirm({ select = false }),
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
						ellipsis_char = "...",
						symbol_map = { Codeium = "" },
						menu = {
							buffer = "[buf]",
							codeium = "[cod]",
							luasnip = "[snip]",
							nvim_lsp = "[lsp]",
							bootstrap = "[boot]",
							otter = "[otter]",
						},
					}),
				},
				sources = {
					{ name = "buffer" },
					{ name = "codeium" },
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "bootstrap" },
					{ name = "otter" },
				},
				sorting = {
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						require("cmp-under-comparator").under,
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
					entries = "custom",
				},
				experimental = {
					-- doplna text pri pisani, trochu otravne
					-- ghost_text = true,
					-- ghost_text = {hlgroup = "Comment"}
				},
			})
		end,
	},

	-- Obsidian
	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		lazy = true,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			workspaces = {
				{
					name = "Obsidian",
					path = vim.fn.expand("$OneDrive_DIR") .. "Dokumenty/zPoznamky/Obsidian/",
				},
			},
			notes_subdir = "inbox",
			new_notes_location = "notes_subdir",
			disable_frontmatter = true,
			templates = {
				subdir = "templates",
				date_format = "%Y-%m-%d",
				time_format = "%H:%M:%S",
			},
			completion = {
				nvim_cmp = true,
				min_chars = 2,
			},
		},
	},
	-- Headlines - highlight markdown headings and code blocks etc.
	{
		"lukas-reineke/headlines.nvim",
		enabled = true,
		lazy = true,
		ft = { "markdown", "quarto" },
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("headlines").setup({
				quarto = {
					query = vim.treesitter.query.parse(
						"markdown",
						[[
                (fenced_code_block) @codeblock
                ]]
					),
					codeblock_highlight = "CodeBlock",
					treesitter_language = "markdown",
				},
				markdown = {
					query = vim.treesitter.query.parse(
						"markdown",
						[[
                (fenced_code_block) @codeblock
                ]]
					),
					codeblock_highlight = "CodeBlock",
				},
			})
		end,
	},

	-- Vim-table-mode
	{
		"dhruvasagar/vim-table-mode",
		ft = { "markdown", "quarto" },
	},

	-- ollama ai gen.nvim
	{
		"David-Kunz/gen.nvim",
		config = function()
			require("gen").setup({
				model = "codellama",
				display_mode = "split", -- The display mode. Can be "float" or "split".
				show_prompt = true, -- Shows the prompt submitted to Ollama.
				-- show_model = true,
			})
		end,
	},

	-- Markdown
	-- {
	--   'MeanderingProgrammer/markdown.nvim',
	--   name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
	--   dependencies = { 'nvim-treesitter/nvim-treesitter' },
	--   config = function()
	--       require('render-markdown').setup({})
	--   end,
	-- },

  { -- molten
        "benlubas/molten-nvim",
        -- version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
        dependencies = { "3rd/image.nvim" },
        -- build = ":UpdateRemotePlugins",
        init = function()
            -- these are examples, not defaults. Please see the readme
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_output_win_max_height = 20
            vim.g.molten_virt_text_output = true
            vim.g.molten_wrap_output = true
            vim.g.molten_auto_open_output = false
        end,
    },

  { -- show images in nvim!
    '3rd/image.nvim',
    enabled = true,
    dev = false,
    ft = { 'markdown', 'quarto', 'vimwiki' },
    dependencies = {
      {
        'vhyrro/luarocks.nvim',
        priority = 1001, -- this plugin needs to run before anything else
        opts = {
          rocks = { 'magick' },
        },
      },
    },
    config = function()
      -- Requirements
      -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
      -- check for dependencies with `:checkhealth kickstart`
      -- needs:
      -- sudo apt install imagemagick
      -- sudo apt install libmagickwand-dev
      -- sudo apt install liblua5.1-0-dev
      -- sudo apt installl luajit

      local image = require 'image'
      image.setup {
        backend = 'kitty',
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            filetypes = { 'markdown', 'vimwiki', 'quarto' },
          },
        },
        editor_only_render_when_focused = false,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview' },
        max_width = 100, --nil,
        max_height = 12, --nil,
        max_height_window_percentage = math.huge, --30,
        max_width_window_percentage = math.huge, --nil,
        kitty_method = 'normal',
      }
    end,
  },

	-- keybidings whichkey
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup({
				icons = {
					breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
					separator = "➜", -- symbol used between a key and it's label
					group = "+", -- symbol prepended to a group
					rules = false, -- disable devicons
				},
				-- triggers_blacklist = {
				--   i = { "i", "j", "k" },
				--   v = { "j", "k" },
				-- },
			})

			-- normal mode
			require("which-key").add({
				mode = { "n" },
				{ "<leader>a", group = "ai ollama", silent = true, nowait = true },
				{ "<leader>b", group = "buffers", silent = true, nowait = true },
				{ "<leader>c", group = "code", silent = true, nowait = true },
				{ "<leader>d", group = "diagnostic", silent = true, nowait = true },
				{ "<leader>f", group = "files", silent = true, nowait = true },
				{ "<leader>g", group = "git", silent = true, nowait = true },
				{ "<leader>h", group = "help", silent = true, nowait = true },
				{ "<leader>l", group = "lsp", silent = true, nowait = true },
				-- { "<leader>m", group = "markdown", silent = true, nowait = true },
				{ "<leader>o", group = "obsidian", silent = true, nowait = true },
				{ "<leader>p", group = "python", silent = true, nowait = true },
				{ "<leader>q", group = "quarto", silent = true, nowait = true },
				{ "<leader>qo", group = "otter", silent = true, nowait = true },
				{ "<leader>t", group = "terminal", silent = true, nowait = true },
				{ "<leader>v", group = "neovim", silent = true, nowait = true },
				{ "<leader>w", group = "windows", silent = true, nowait = true },
			})

			-- visual mode
			require("which-key").add({
				mode = { "v" },
				{ "<leader>a", group = "ai ollama", silent = true, nowait = true },
				{ "<leader>q", group = "quarto", silent = true, nowait = true },
				{ "<leader>t", group = "terminal", silent = true, nowait = true },
			})
		end,
	},
})
