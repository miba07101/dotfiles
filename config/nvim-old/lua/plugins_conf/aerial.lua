local status_ok, aerial = pcall(require, "aerial")
if not status_ok then
	return
end

aerial.setup({
  attach_mode = "global",
  backends = { "lsp", "treesitter" },
  min_width = 28,
  show_guides = true,
  filter_kind = false,
  icons = {
    Array = "",
    Boolean = "⊨",
    Class = "",
    Constant = "",
    Constructor = "",
    Key = "",
    Function = "",
    Method = "ƒ",
    Namespace = "",
    Null = "NULL",
    Number = "#",
    Object = "⦿",
    Property = "",
    TypeParameter = "𝙏",
    Variable = "",
    Enum = "ℰ",
    Package = "",
    EnumMember = "",
    File = "",
    Module = "",
    Field = "",
    Interface = "ﰮ",
    String = "𝓐",
    Struct = "𝓢",
    Event = "",
    Operator = "+",
  },
  guides = {
    mid_item = "├ ",
    last_item = "└ ",
    nested_top = "│ ",
    whitespace = "  ",
  },
})
