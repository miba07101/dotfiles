;; extends

; Keywords
(("and"      @keyword.operator) (#set! conceal ""))
(("assert"   @keyword) (#set! conceal ""))
(("async"    @keyword) (#set! conceal ""))
(("await"    @keyword) (#set! conceal "神"))
(("break"    @keyword) (#set! conceal ""))
(("class"    @keyword) (#set! conceal ""))
(("continue" @keyword) (#set! conceal ""))
(("def"      @keyword.function) (#set! conceal ""))
(("del"      @keyword) (#set! conceal ""))
(("except"   @keyword) (#set! conceal ""))
(("from"     @keyword) (#set! conceal ""))
(("global"   @keyword) (#set! conceal ""))
(("import"   @include) (#set! conceal ""))
(("is"       @keyword) (#set! conceal "﫦"))
(("lambda"   @include) (#set! conceal "λ"))
(("not"      @keyword.operator) (#set! conceal "✗"))
(("or"       @keyword.operator) (#set! conceal ""))
(("pass"     @keyword) (#set! conceal ""))
(("raise"    @keyword) (#set! conceal ""))
(("return"   @keyword) (#set! conceal ""))
(("try"      @keyword) (#set! conceal ""))
(("with"     @keyword) (#set! conceal ""))
(("yield"    @keyword) (#set! conceal ""))
; ((import_from_statement ("from") @include) (#set! conceal ""))
; ((yield ("from") @keyword) (#set! conceal ""))

; Conditional
(("if"       @conditional) (#set! conceal "?"))
(("elif"     @conditional) (#set! conceal "¿"))
(("else"     @conditional) (#set! conceal "!"))

; Repeat
(("for"      @repeat) (#set! conceal ""))
(("while"    @repeat) (#set! conceal "節"))

; Functions
((call function: (identifier) @function.builtin (#eq? @function.builtin "print")) (#set! conceal ""))
