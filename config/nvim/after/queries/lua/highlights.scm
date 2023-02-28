;;extends

; Keywords
(("return"   @keyword) (#set! conceal ""))
(("local"    @keyword) (#set! conceal "~"))
(("function" @keyword) (#set! conceal ""))
(("and"      @keyword) (#set! conceal "▼"))
(("end"      @keyword) (#set! conceal "E"))
(("in"       @keyword) (#set! conceal "i"))

; Repeat
(("do"       @repeat) (#set! conceal ""))
(("for"      @repeat) (#set! conceal ""))

; Conditional
(("if"       @conditional) (#set! conceal "?"))
(("then"     @conditional) (#set! conceal "↙"))
(("else"     @conditional) (#set! conceal "!"))
(("elseif"   @conditional) (#set! conceal "¿"))

; Functions
((function_call name: (identifier) @function.builtin (#eq? @function.builtin "require")) (#set! conceal ""))
((function_call name: (identifier) @function.builtin (#eq? @function.builtin "print"  )) (#set! conceal ""))
((function_call name: (identifier) @function.builtin (#eq? @function.builtin "pairs"  )) (#set! conceal "P"))
((function_call name: (identifier) @function.builtin (#eq? @function.builtin "ipairs" )) (#set! conceal "I"))

; Vim
(((dot_index_expression) @field (#eq? @field "vim.cmd"     )) (#set! conceal ""))
(((dot_index_expression) @field (#eq? @field "vim.api"     )) (#set! conceal ""))
(((dot_index_expression) @field (#eq? @field "vim.fn"      )) (#set! conceal "#"))
(((dot_index_expression) @field (#eq? @field "vim.g"       )) (#set! conceal "G"))
(((dot_index_expression) @field (#eq? @field "vim.schedule")) (#set! conceal ""))
(((dot_index_expression) @field (#eq? @field "vim.opt"     )) (#set! conceal "S"))
(((dot_index_expression) @field (#eq? @field "vim.env"     )) (#set! conceal "$"))
(((dot_index_expression) @field (#eq? @field "vim.o"       )) (#set! conceal "O"))
(((dot_index_expression) @field (#eq? @field "vim.bo"      )) (#set! conceal "B"))
(((dot_index_expression) @field (#eq? @field "vim.wo"      )) (#set! conceal "W"))
(((dot_index_expression) @field (#eq? @field "vim.keymap.set")) (#set! conceal ""))

; overit
((dot_index_expression table: (identifier) @keyword  (#eq? @keyword  "math" )) (#set! conceal ""))
(((break_statement) @keyword) (#set! conceal "ﰈ"))
