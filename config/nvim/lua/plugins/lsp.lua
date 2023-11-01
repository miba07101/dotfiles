require("mason").setup()

local servers = {
  bashls = {
    filetypes = { "zsh", "bash", "sh" },
  },
  cssls = {},
  -- tailwindcss = {},
  -- html = {
  --   filetypes = { "html", "htmldjango" },
  -- },
  jsonls = {},
  emmet_ls = {
               filetypes = { 'html', 'htmldjango', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'javascript', 'typescript', 'markdown' },
               init_options = {
                  html = {
                     options = {
                        -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L26
                        ["bem.enabled"] = true,
                     },
                  },
               }
            },
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
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
          autoImportCompletions = true,
          typeCheckingMode = "off",
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
        },
      },
    },
  },
}

-- Auto install servers
require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_installation = true,
})

-- Setup LSP servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- local on_attach = function(client, bufnr)
--   -- sem zadat on_attach funkcie doplnkov
-- end

require("mason-lspconfig").setup_handlers({
  function(server)
    local server_opts = servers[server] or {}
    server_opts.capabilities = capabilities
    server_opts.on_attach = on_attach
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
require("mason-tool-installer").setup({
      ensure_installed = {
        "beautysh", -- bash formater
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "shellcheck", -- bash linter
        "pylint", -- python linter
        "flake8", -- python linter
        "eslint_d", -- js linter
        "djlint", -- django linter
      },
    })

-- Formatting
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    bash = { "beautysh" },
    javascript = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    lua = { "stylua" },
    python = { "isort", "black" },
  },
  -- format_on_save = {
  --   lsp_fallback = true,
  --   async = false,
  --   timeout_ms = 1000,
  -- },
})

-- Linting
local lint = require("lint")

lint.linters_by_ft = {
  bash = { "shellcheck" },
  javascript = { "eslint_d" },
  python = { "flake8" },
}
