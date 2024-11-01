if vim.g.vscodium then
    -- VSCodium extension
    require("vscode-options")
elseif vim.g.vscode then
    -- VSCode extension
    require("vscode-options")
else
    -- ordinary Neovim
    require("options")
    require("keymaps")
    require("plugin-manager")
    require("autocommands")
end