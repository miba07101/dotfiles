set nocompatible                    " musi byt - NEVYHNUTNE!!!
let mapleader ="\<space>"

" => Pluginy ---------------------------------------------------------------------- {{{1

" Auto instalacia Plug-vim manazera
    let need_to_install_plugins = 0
    if empty(glob('~/.vim/autoload/plug.vim'))
        silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    let need_to_install_plugins = 1
    endif

" Zoznam Pluginov
    call plug#begin('~/.vim/plugged')
        " Visual
            Plug 'rbong/vim-crystalline'
            Plug 'ap/vim-css-color'
            Plug 'jsit/toast.vim'
        " Syntax
            Plug 'tpope/vim-commentary'
            Plug 'dense-analysis/ale'
            Plug 'sheerun/vim-polyglot'
            Plug 'lifepillar/vim-mucomplete'
        " Python
            Plug 'tell-k/vim-autopep8'

     call plug#end()

" Auto instalacia Pluginov
    if need_to_install_plugins == 1
        echo "Installing plugins..."
        silent! PlugInstall
        echo "Done!"
        q
    endif

" => Všeobecné nastavenia --------------------------------------------------------- {{{1

filetype plugin indent on
set shell=/bin/bash                 "nastavi terminal na bash
syntax on                           "zvyraznenie textu
" set modifiable
set number                          "cislovanie riadkov
" set relativenumber                  "cislovanie podla pozicie kurzora (0)
set backspace=indent,eol,start      "povoli backspace v INSERT mode
set history=50                      "ulozi historiu :cmdline
" set autoread                       "znovu nacita subory zmmenene mimo vim
" set autowrite                     "automaticke ulozenie
set hidden                          "vim sa chova ako iny editor, buffer moze existovat v pozadi
set clipboard=unnamedplus           "kopirovanie/vkladanie medzi vim a inym programom
set encoding=UTF-8
set fileencoding=UTF-8
set fileformat=unix
set nowrap                          "zalamovanie riadkov
set splitright                      "pri otvarani noveho suboru rozdeli obrazovku vpravo
set splitbelow                      "pri otvarani noveho suboru rozdeli obrazovku dole
set cursorline                      "zobrazi ciaru kde sa nachadza kurzor
set mouse=a                         "povoli mys
set wildmode=longest,list,full      "zapne autocompletion
set scrolloff=3                     "ponecha 3 riadky pred/po kurzor pri skrolovani
set timeoutlen=1000 ttimeoutlen=0   "urychly reakciu ESC klavesy

" Grafika/vizualna tema
set termguicolors
" set t_Co=256
" if strftime('%H') >= 7 && strftime('%H') < 15
"   set background=light
" else
  set background=dark
" endif
colorscheme toast                   "zvolena/instalovana vizualna tema

" Vypnutie swap suborov
set noswapfile
set nobackup
set nowritebackup

" Odsadenie
set tabstop=4                       "odsadenie pouzitim tab o X miest
set softtabstop=4
set shiftwidth=4                    "odsadenie o X miest
set expandtab                       "nahradi tab medzerami
set list listchars=tab:›\ ,trail:.,extends:>,precedes:<,nbsp:~,eol:¬

" Vyhladavanie
set incsearch                       "najde dalsiu zhodu pokial piseme
"set hlsearch                        "zvyrazni vyhladavane slovo
set ignorecase                      "ignoruje velke/male pismena
set smartcase                       "rozlisuje velke/male pismena pokial zadam

" Autocompletion
set complete+=kspell
set completeopt-=preview
set completeopt+=menu,menuone,noinsert
set shortmess+=c

" Ulozi ako SUDO
ca w!! w !sudo tee "%"

" Nastavenie tvaru kurzora
" let &t_SI = "\<Esc>]50;CursorShape=1\x7"            "INSERT MODE
" let &t_SR = "\<Esc>]50;CursorShape=2\x7"            "REPLACE MODE
" let &t_EI = "\<Esc>]50;CursorShape=0\x7"            "NORMAL MODE
let &t_SI .= "\<ESC>[1 q"
let &t_SR .= "\<ESC>[3 q"
let &t_EI .= "\<ESC>[1 q"

" Skript umožňujúci používanie ALT klavesy
" Pouzitie `map` oneskoruje ukoncenie insert mode by timeoutlen!
for i in range(97,122)
  let c = nr2char(i)
  " exec "map \e".c." <M-".c.">"
  " exec "map! \e".c." <M-".c.">"
  exec "nmap \e".c." <M-".c.">"
endfor

" => Nastavenie Pluginov ---------------------------------------------------------- {{{1

" vim-crystalLine
function! StatusLine(current, width)
    let l:s = ''
    if a:current
        let l:s .= crystalline#mode() . crystalline#right_mode_sep('') . ' %f '
    else
        let l:s .= '%#CrystallineInactive#'
    endif
    let l:s .= '%='
    if a:current
        let l:s .= crystalline#left_sep('Fill','') . ' %{&ft} | %{&fenc!=#""?&fenc:&enc} | %{&ff} '
        let l:s .= crystalline#left_mode_sep('Fill')
    endif
    if a:width > 80
        let l:s .= ' %l/%L %c%V %P '
    else
        let l:s .= ' '
    endif
    return l:s
endfunction

function! TabLine()
    return crystalline#bufferline() . '%=%#CrystallineTab#' . ' %999Xx%X '
endfunction

let g:crystalline_enable_sep = 0
let g:crystalline_statusline_fn = 'StatusLine'
let g:crystalline_tabline_fn = 'TabLine'
let g:crystalline_theme = 'default'

set laststatus=2                            "zobrazi statusbar
set showtabline=2                           "zobrazi tabbar (=1 - iba ak je otvorenych viac suborov)
set noshowmode                              "nebude zobrazovat v cmd line MOD (InSERT, NORMAL, VISUAL)

" ale
" musim nainstalovat language-server ( napr. pyright)
let g:ale_linters = {'python': ['flake8', 'pyright']}
let g:ale_fixers = {'*': ['remove_trailing_lines', 'trim_whitespace'], 'python': ['black', 'yapf', 'autopep8']}
let g:ale_fix_on_save = 0
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 0
let g:ale_sign_column_always = 0
let g:ale_completion_enabled = 0
let g:ale_floating_preview = 1
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']
" set omnifunc=ale#completion#OmniFunc
" let g:ale_sign_error = '!'
" let g:ale_sign_warning = ' '
" highlight clear ALEErrorSign

" let g:ale_completion_symbols = {
"   \ 'text': '',
"   \ 'method': '',
"   \ 'function': '',
"   \ 'constructor': '',
"   \ 'field': '',
"   \ 'variable': '',
"   \ 'class': '',
"   \ 'interface': '',
"   \ 'module': '',
"   \ 'property': '',
"   \ 'unit': 'unit',
"   \ 'value': 'val',
"   \ 'enum': '',
"   \ 'keyword': 'keyword',
"   \ 'snippet': '',
"   \ 'color': 'color',
"   \ 'file': '',
"   \ 'reference': 'ref',
"   \ 'folder': '',
"   \ 'enum member': '',
"   \ 'constant': '',
"   \ 'struct': '',
"   \ 'event': 'event',
"   \ 'operator': '',
"   \ 'type_parameter': 'type param',
"   \ '<default>': 'v'
"   \ }

" autopep8
let g:autopep8_aggressive = 2
let g:autopep8_diff_type='vertical'
let g:autopep8_disable_show_diff = 1

" mucomplete
let g:mucomplete#enable_auto_at_startup = 1
" let g:jedi#popup_on_dot = 0  " It may be 1 as well

" => Netrw file manager ----------------------------------------------------------- {{{1

let g:netrw_banner=0
" let g:netrw_liststyle=3
let g:netrw_browse_split=0
let g:netrw_keepdir=0
" " skratka pre skrytie/odkrytie suborov - gh
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'
" let g:netrw_localcopydircmd = 'cp -r'

"Funkcia na zapnutie/vypnutie NETRW
function! ToggleExplorer()
    if &ft == "netrw"
        if exists("w:netrw_rexfile")
            if w:netrw_rexfile == "" || w:netrw_rexfile == "NetrwTreeListing"
                quit
            else
                exec 'e ' . w:netrw_rexfile
            endif
        else
            if exists("w:netrw_rexlocal")
                Rexplore
            else
                quit
            endif
        endif
    else
        Explore
        :call DrawNetrwIcons()
    endif
endfun

nmap <silent> <M-f> :call ToggleExplorer()<CR>

" Funkcia otvori subor v novom okne vpravo a zatvori NETRW
function! OpenToRight()
    :normal v
    let g:path=expand('%:p')
    execute 'q!'
    :call ToggleExplorer()
    execute 'belowright vnew' g:path
    :normal <C-w>l
endfunction

" Klávesové skratky
function! NetrwMapping()
    nmap <buffer> . gh:call DrawNetrwIcons()<CR>
    nmap <buffer> <LEFT> -:call DrawNetrwIcons()<CR>
    nmap <buffer> <RIGHT> <CR>:call DrawNetrwIcons()<CR>
    nmap <buffer> fc %:w<CR>
    nmap <buffer> dc d:call DrawNetrwIcons()<CR>
    nmap <buffer> V :call OpenToRight()<cr>
endfunction

augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END

" Ikony pre NETRW
sign define netrw_dir text= texthl=netrwDir
sign define netrw_exec text= texthl=netrwExe
sign define netrw_link text=⤤ texthl=netrwSymLink
sign define netrw_file text= texthl=netrwPlain

sign define netrw_c text= texthl=netrwPlain
sign define netrw_go text= texthl=netrwPlain
sign define netrw_js text= texthl=netrwPlain
sign define netrw_py text= texthl=netrwPlain
sign define netrw_rs text= texthl=netrwPlain
sign define netrw_ts text= texthl=netrwPlain

sign define netrw_conf text= texthl=netrwPlain
sign define netrw_db text= texthl=netrwPlain
sign define netrw_html text= texthl=netrwPlain
sign define netrw_json text= texthl=netrwPlain
sign define netrw_md text= texthl=netrwPlain

sign define netrw_img text= texthl=netrwPlain
sign define netrw_sound text=♫ texthl=netrwPlain

function! DrawNetrwIcons()
    if &filetype != 'netrw'
        return
    endif

    let l:bufnr = bufnr('')
    exec 'sign unplace * buffer='.l:bufnr

    let l:line_nr=1
    let l:num_lines=line('$')
    while l:line_nr <= l:num_lines
        let l:sign_name = 'netrw_file'
        let l:line = getline(l:line_nr)

        if l:line == ''
            let l:line_nr += 1
            continue
        endif

        if l:line =~ '/$'
            let l:sign_name = 'netrw_dir'
        elseif l:line =~ '@\t --> '
            let l:sign_name = 'netrw_link'
        elseif l:line =~ '\*$'
            let l:sign_name = 'netrw_exec'

        elseif l:line =~ '\.\(c\|cc\|cpp\)$'
            let l:sign_name = 'netrw_c'
        elseif l:line =~ '\.go$\|^go.mod$\|^go.sum$'
            let l:sign_name = 'netrw_go'
        elseif l:line =~ '\.\(js\|jsx\)$'
            let l:sign_name = 'netrw_js'
        elseif l:line =~ '\.pyc\?$'
            let l:sign_name = 'netrw_py'
        elseif l:line =~ '\.rs$\|^Cargo.lock$\|^Cargo.toml$'
            let l:sign_name = 'netrw_rs'
        elseif l:line =~ '\.\(tsx\|ts\)$'
            let l:sign_name = 'netrw_ts'

        elseif l:line =~ '^\.gitignore$\|^\.dockerignore$'
            let l:sign_name = 'netrw_conf'
        elseif l:line =~ '\.\(sql\|dump\|db\)$'
            let l:sign_name = 'netrw_db'
        elseif l:line =~ '\.\(htm\|html\)$'
            let l:sign_name = 'netrw_html'
        elseif l:line =~ '\.\(json$\|yaml\|yml\)$'
            let l:sign_name = 'netrw_json'
        elseif l:line =~ '\.md$'
            let l:sign_name = 'netrw_md'

        elseif l:line =~ '\.\(gif\|png\|ico\|jpg\|bmp\|svg\)$'
            let l:sign_name = 'netrw_img'
        elseif l:line =~ '\.\(mp3\|f4a\|flac\|wav\)$'
            let l:sign_name = 'netrw_sound'
        endif

        exec 'sign place '.l:line_nr.' line='.l:line_nr.' name='.l:sign_name.' buffer='.l:bufnr
        let l:line_nr += 1
    endwhile
endfunction

" => AutoCommands ----------------------------------------------------------------- {{{1

augroup AutoCommands
    autocmd!
"nastavi kurzor tam kde som skoncil
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
"zrusi automaticke komentovanie v novom riadku
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
"otvori okno HELP vzdy vpravo
    autocmd BufEnter *.txt if &buftype == 'help' | wincmd L | endif
    autocmd BufEnter * silent! lcd %:p:h                        "otvori terminal tam kde je ulozeny otvoreny subor
    autocmd FileType vim setlocal foldmethod=marker             "folding textu
    " autocmd FileType python setlocal foldmethod=indent          "folding textu
    autocmd InsertEnter,InsertLeave * set nocursorline!         "zapne/vypne cursorline v insert mode
    autocmd BufWritePre * %s/\s\+$//e                           "odstrani trailling whitespace (medzeru na konci) pri ulozeni suboru
"spustenie PYTHON suboru pomocou <M-p>
    autocmd FileType python map <buffer> <M-p> :w<CR>:exec '!clear; python3' shellescape(@%, 1)<CR>
    autocmd FileType python imap <buffer> <M-p> <esc>:w<CR>:exec '!clear; python3' shellescape(@%, 1)<CR>
    autocmd FileType python setlocal colorcolumn=80
" Resize vim windows when overall window size changes
    autocmd VimResized * wincmd =
augroup END

 " => Klávesové skratky ------------------------------------------------------------ {{{1

" zoznam klavesovych skratiek (spustim <leader>?)
nnoremap <leader>x :echo "
        \================ Uloženie, vypnutie ================== \n
        \ALT+s                  : ulozi subor                   \n
        \Shift+q                : vypne bez ulozenia            \n
        \Shift+w                : vypne s ulozenim              \n
        \================ Plugins ============================= \n
        \ALT+o                  : ale fix                       \n
        \ALT+l                  : ale lint                      \n
        \ALT+k                  : ale next wrap                 \n
        \ALT+j                  : ale previous wrap             \n
        \gd                     : ale goto definition           \n
        \gr                     : ale find reference            \n
        \H                      : ale hover                     \n
        \ALT+u                  : Autopep8                      \n
        \ALT+a                  : vypne/zapne autocompletion    \n
        \leader+/               : komentovanie                  \n
        \================ Subory ============================== \n
        \leader+fc              : vytvori subor                 \n
        \leader+dc              : vytvori priecinok             \n
        \leader+mv              : presunie subor                \n
        \================ Okna ================================ \n
        \leader+v               : vertikalne rozdelenie         \n
        \leader+h               : horizontalne rozdelenie       \n
        \leader+=               : rovnaka velkost okna          \n
        \leader+sipky L,R,U,D   : zmena velkosti okna           \n
        \CTRL+sipky             : prepinanie medzi oknami       \n
        \================ Tab ================================= \n
        \leader+t               : vytvorenie TAB z bufferov     \n
        \SHIFT+sipky L,R        : prepinanie medzi TAB          \n
        \SHIFT+sipky U,D        : vypnutie TAB                  \n
        \================ Buffers ============================= \n
        \ALT+sipky L,R          : prepinanie medzi Buffermi     \n
        \ALT+sipky U,D          : vypne Buffer                  \n
        \================ Rozne =============================== \n
        \ii                     : vypne INSERT mode             \n
        \ALT+t                  : zapne terminal                \n
        \ALT+b                  : zmeni background              \n
        \ALT+n                  : zapne/vypne relativenumbers   \n
        \CTRL+a                 : oznaci vsetok text            \n
        \zz                     : folding                       \n
        \"<CR>

" Uloženie, vypnutie suboru
noremap <M-s> :w<CR>
nnoremap <S-w> :wq<CR>
nnoremap <S-q> :q!<CR>

" Ale
nmap <M-o> <Plug>(ale_fix)
nmap <M-l> <Plug>(ale_lint)
nmap <M-k> <Plug>(ale_next_wrap)
nmap <M-j> <Plug>(ale_previous_wrap)
nmap gd <Plug>(ale_go_to_definition)
nmap gr :ALEFindReferences<CR>
nmap H <Plug>(ale_hover)

" Autopep8
nmap <M-u> :call Autopep8()<CR>

" MUcomplete
nmap <M-a> :MUcompleteAutoToggle<CR>

" Vim-commentary
" pre komentovanie a odkomentovanie riadka sluzi ta ista skratka (vim nepozna / preto je tam _)
nmap <leader>/ <Plug>CommentaryLine
xmap <leader>/ <Plug>Commentary

" Basic file system commands
nnoremap <leader>fc :!touch<Space>
nnoremap <leader>dc :!mkdir<Space>
nnoremap <leader>mv :!mv<Space>%<Space>

" Rozdelenie okna
nnoremap <leader>v <C-w>v
nnoremap <leader>h <C-w>s

" Zmena velkosti okna
nnoremap <leader><Right> :vertical resize -2<CR>
nnoremap <leader><Left> :vertical resize +2<CR>
nnoremap <leader><Up> :resize +2<CR>
nnoremap <leader><Down> :resize -2<CR>
nnoremap <leader>= <C-W>=

" Prepinanie medzi rozdelenymi oknami (Ctrl+sipky)
nnoremap <C-Down> <C-W>j
nnoremap <C-Up> <C-W>k
nnoremap <C-Left> <C-W>h
nnoremap <C-Right> <C-W>l

" Vytvorenie tab zo vsetkych bufferov
nnoremap <leader>t :tab sball<CR>

" Prepinanie medzi tab (SHIFT + šípky)
nnoremap <S-Left> :tabp<CR>
nnoremap <S-Right> :tabn<CR>

" Vypne tab (SHIFT + šípky hore/dole)
nnoremap <S-Up> :tabc<CR>
nnoremap <S-Down> :tabo<CR>

" Prepinanie medzi buffermi (ALT + šípky)
nnoremap <M-Left> :bprev<CR>
nnoremap <M-Right> :bnext<CR>

" Vypne buffer v tom istom okne (ulozi zmeny :w - prepne do predchadzajuceho bufferu :bp - vypne aktualny buffer :bd )
nnoremap <M-Up> :bp<BAR>bd#<CR>
nnoremap <M-Down> :bp<BAR>bd#<CR>

" Rôzne
inoremap ii <ESC>
nnoremap <M-t> :term<CR>
nnoremap <M-b> :let &bg=(&bg == "dark" ? "light" : "dark" )<CR>
nnoremap <M-n> :set relativenumber!<CR>
nnoremap <C-a> <ESC>ggVG<CR>
nnoremap <BS> X
nnoremap zz za
" vypne zvyraznenie hladaneho textu stlacenim ENTER
nnoremap <CR> :noh<CR>
