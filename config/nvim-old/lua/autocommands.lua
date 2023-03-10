  local api = vim.api

  -- Highlight on yank
  local yankGrp = api.nvim_create_augroup("YankHighlight", { clear = true })
  api.nvim_create_autocmd("TextYankPost", {
    command = "silent! lua vim.highlight.on_yank()",
    group = yankGrp,
  })

  -- show cursor line only in active window
  local cursorGrp = api.nvim_create_augroup("CursorLine", { clear = true })
  api.nvim_create_autocmd(
    { "InsertLeave", "WinEnter" },
    { pattern = "*", command = "set cursorline", group = cursorGrp }
  )
  api.nvim_create_autocmd(
    { "InsertEnter", "WinLeave" },
    { pattern = "*", command = "set nocursorline", group = cursorGrp }
  )

  -- go to last loc when opening a buffer
  api.nvim_create_autocmd(
    "BufReadPost",
    { command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]] }
  )

  -- Check if we need to reload the file when it changed
  -- api.nvim_create_autocmd("FocusGained", { command = [[:checktime]] })

  -- windows to close with "q"
  api.nvim_create_autocmd(
    "FileType",
    { pattern = { "help", "startuptime", "qf", "lspinfo" }, command = [[nnoremap <buffer><silent> q :close<CR>]] }
  )
  api.nvim_create_autocmd("FileType", { pattern = "man", command = [[nnoremap <buffer><silent> q :quit<CR>]] })

-- don't auto comment new line
  api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

-- open HELP on right side
  api.nvim_create_autocmd("BufEnter", { command = [[if &buftype == 'help' | wincmd L | endif]] })

-- open terminal at same location as opened file
  api.nvim_create_autocmd( "BufEnter", { command = [[silent! lcd %:p:h]] })

-- remove trailling whitespace (medzeru na konci) when SAVE file
  api.nvim_create_autocmd( "BufWritePre", { command = [[%s/\s\+$//e]] })

-- PYTHON
  -- api.nvim_create_autocmd( "FileType", { pattern = "python", command = [[map <buffer> <M-p> :w<CR>:exec '!clear; python3' shellescape(@%, 1)<CR>]] })
  api.nvim_create_autocmd( "FileType", { pattern = "python", command = [[nnoremap <buffer> <M-p> :w<CR>:terminal python3 "%"<CR>]] })
  -- api.nvim_create_autocmd( "FileType", { pattern = "python", command = [[imap <buffer> <M-p> <esc>:w<CR>:exec '!clear; python3' shellescape(@%, 1)<CR>]] })
  api.nvim_create_autocmd( "FileType", { pattern = "python", command = [[setlocal colorcolumn=80]] })

-- resize vim windows when overall window size changes
  api.nvim_create_autocmd( "VimResized", { command = [[wincmd =]] })
