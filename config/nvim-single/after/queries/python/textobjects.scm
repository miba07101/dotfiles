; extends

; ((comment) @code_cell.outer
;   (#eq? @code_cell.outer "# %%"))
;
; ((comment) @code_cell.inner
;   (#eq? @code_cell.inner "# %%"))

((comment) @code_cell.outer
  (#lua-match? @code_cell.outer "^# %%%%"))

((comment) @code_cell.inner
  (#lua-match? @code_cell.inner "^# %%%%"))

