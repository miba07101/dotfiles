require("mason").setup()

local servers = {
	bashls = {
		filetypes = { "zsh", "bash", "sh" },
	},
	cssls = {},
	html = {},
	jsonls = {},
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
				},
				telemetry = {
					enable = false,
				},
			},
		},
	},
	pyright = {
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "off",
				},
			},
		},
	},
}

-- local capabilities = require("cmp_nvim_lsp").default_capabilities(
--   vim.lsp.protocol.make_client_capabilities())
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Auto install servers
require("mason-lspconfig").setup({
	ensure_installed = vim.tbl_keys(servers),
	automatic_installation = true,
})

-- Setup LSP servers
require("mason-lspconfig").setup_handlers({
	function(server)
		local server_opts = servers[server] or {}
		server_opts.capabilities = capabilities
		require("lspconfig")[server].setup(server_opts)
	end,
})

-- Diagnostic customization
-- See :help vim.diagnostic.config()
vim.diagnostic.config({
	virtual_text = false,
	underline = true,
	severity_sort = true,
	float = {
		focusable = true,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- See :help sign_define()
local sign = function(opts)
	vim.fn.sign_define(opts.name, {
		texthl = opts.name,
		text = opts.text,
		numhl = "",
	})
end

sign({ name = "DiagnosticSignError", text = "" })
sign({ name = "DiagnosticSignWarn", text = "" })
sign({ name = "DiagnosticSignHint", text = "" })
sign({ name = "DiagnosticSignInfo", text = "" })

-- Hover float window configuration
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

-- Signature help window configuration
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

-- Linters / Formaters
-- Auto install
require("mason-null-ls").setup({
	ensure_installed = {
		"beautysh",
		"shellcheck",
		"stylua",
		"prettier",
		"black",
		"flake8",
	},
	automatic_installation = true,
})

local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	debug = false,
	sources = {
		-- Bash
		formatting.beautysh,
		diagnostics.shellcheck,
		-- Lua
		formatting.stylua,
		-- JavaScript, HTML, CSS
		formatting.prettier.with({
			extra_filetypes = { "toml" },
			extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
		}),
		-- Python
		formatting.black.with({ extra_args = { "--fast" } }),
		diagnostics.flake8,
	},
})
