" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
    finish
endif

"if has("vms")
"  set nobackup         " do not keep a backup file, use versions instead
"else
"  set backup           " keep a backup file
"endif

" In many terminal emulators the mouse works just fine, thus enable it.
" Mouse needs to be activated to work with tmux
if has('mouse')
    set mouse+=n
endif


"" OPTIONS
" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set listchars=tab:Ⱶ-,trail:•,extends:»,precedes:«,eol:¬
set fillchars=vert:┆,fold:+,diff:―
set wildmode=list:longest,full
set sessionoptions+=resize

set guifont=Input\ 8
set guioptions-=T       " no toolbar
set guioptions-=r       " no right-hand scrollbar
set guioptions-=L       " no left-hand scrollbar
set guioptions-=m       " no menu bar
set guioptions-=e       " non-graphical tabline
set guioptions+=c       " console dialogs instead of popup dialogs

set history=100         " keep 100 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set showmatch           " show matching brackets
set ignorecase          " ignore case when matching
set smartcase           " use smartcase matching
set nowrap              " no text wrap around
set sidescroll=1        " scroll 1 column
set sidescrolloff=1
set number              " show line number
set numberwidth=1       " use minimum width to show line numbers
set cursorline          " highlight the screen line of the cursor
set shiftwidth=4        " use 3 spaces for (auto)indent
set smarttab            " turn on smarttabs
set expandtab           " expand tabs to spaces
set softtabstop=4       " insert 3 spaces for a tab
set autoread            " automatically read a file when it was modified outside of VIM
set wildmenu            " show command-line completion menu
set modelines=1         " set modlines to 1 line instead of 5 (default)
set hidden              " abandoned (modified but not saved) buffers are not unloaded
set scrolloff=5         " set scroll off context lines
set linebreak           " wrap lines on 'breakat' characters
set showbreak=└         " character to prepend on wrapped lines
set lazyredraw          " Don't redraw when executing macros
set notimeout           " Don't let unfinished mappings timeout
set ttimeout            " Let term keycodes timeout
set ttimeoutlen=50      " Set term keycode timeout low since we have a fast terminal
set nrformats-=octal    " Treat octals (leading 0) as decimals when <C-A> and <C-X>
set matchpairs+=<:>     " Add angle brackets to pair matching operator (%)
set matchtime=2         " shorten matchpair highlight time (default: 5)
set laststatus=2        " Show status line always
" Super basic/not fancy statusline
set statusline=\ %(%h%w%q%)\ %f\ %(%m\ %r%)%<%=%vc\ %LL\ %y

let g:mapleader = ';'   " mapleader maps to ';' instead of default '\'


"" System-Wide Packages
runtime! ftplugin/man.vim     " use in-window man pages
packadd! editexisting
packadd! matchit
packadd! shellmenu

"" System-Wide Plugins
" IndentLine plugin options
if 1
    let g:indentLine_enabled = 0
    let g:indentLine_char = '┆'
    " toggle/reset indent lines for indentlines plugin
    nnoremap <leader>ii :IndentLinesToggle<CR>
    nnoremap <leader>ir :IndentLinesReset<CR>
endif

" Airline plugin options
if 1
    let g:loaded_airline = 0   " mask airline
    let g:airline_theme_patch_func = 'AirlineThemePatch'   " see AirlineThemePatch below
    let g:airline_symbols = {}
    let g:airline_symbols.whitespace = '‼'
    let g:airline_powerline_fonts = 1

    call airline#parts#define_raw('file', '%f')
    call airline#parts#define('modified', {
        \ 'condition' : '&modified',
        \ 'text' : '(*)',
        \ 'accent' : 'red'
        \ })
    call airline#parts#define('modifiable', {
        \ 'condition' : '!&modifiable',
        \ 'text' : '(■)',
        \ 'accent' : 'red'
        \ })
    let g:airline_section_c = airline#section#create(['%<', 'file', 'modified', 'modifiable', ' ', 'readonly'])

    " Load/enable airline extensions selectively
    let g:airline_extensions = [
        \ 'netrw',
        \ 'quickfix',
        \ 'tabline',
        \ 'whitespace',
        \ ]
    "   \ 'undotree',

    " See :help airline-tabline
    " use tabline to show buffers only not tabs
    let g:airline#extensions#tabline#show_tabs = 0
    let g:airline#extensions#tabline#buffer_nr_show = 1
    let g:airline#extensions#tabline#fnamecollapse = 1
    let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
    let g:airline#extensions#tabline#buffer_min_count = 2

    " Airline theme patch function
    func! AirlineThemePatch(palette)
        " index 2 is ctermfg, index 3 is ctermbg
        if g:airline_theme == 'base16'
            " this works for solarized coloring, maybe not others
            for section in keys(a:palette.inactive)
                if section =~# 'airline_\%(a\|b\|c\)'
                    " reverse
                    let a:palette.inactive[section][2] = 8
                    let a:palette.inactive[section][3] = 11
                endif
            endfor
            for section in keys(a:palette.inactive_modified)
                if section =~# 'airline_\%(a\|b\|c\)'
                    let a:palette.inactive_modified[section][2] = 3
                endif
            endfor
        endif
        if g:airline_theme == 'wombat'
            for colors in values(a:palette.inactive)
                let colors[2] = 16
                let colors[3] = 239
            endfor
        endif
    endfunc
endif

" NERDtree plugin options
let g:loaded_nerd_tree = 1          " mask NERDTree


"" Local Plugins and Packages
packadd! vim-SkyBison
if &rtp =~ 'SkyBison'
    nnoremap <silent> <leader>: :<C-U>call SkyBison("")<CR>
    nnoremap <leader>b 2:<C-U>call SkyBison("b ")<CR>
    nnoremap <leader>sb 2:<C-U>call SkyBison("sb ")<CR>
    nnoremap <leader>vb 2:<C-U>call SkyBison("vert sb ")<CR>
endif

packadd! vim-sayonara
if &rtp =~ 'sayonara'
    nnoremap <silent> QQ :Sayonara<CR>
endif


"" MAPPINGS
" Toggle GUI menu bar
if has('gui_running')
    function! ToggleGUIMenuBar()
        if &guioptions =~# 'm'
            set guioptions-=m
        else
            set guioptions+=m
        endif
    endfunc

    nnoremap <A-m> :call ToggleGUIMenuBar()<CR>
endif

" Syntax highlighting debug
map <F2> :echo "hi<" .
         \ synIDattr(synID(line("."),col("."),1),"name") .
         \ '> trans<' .
         \ synIDattr(synID(line("."),col("."),0),"name") .
         \ "> lo<" .
         \ synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") .
         \ ">"<CR>

" Some GUI fonts
nnoremap <silent> <F8>  :set guifont=Monaco\ 7.5 <Bar> set lsp& <CR>
nnoremap <silent> <F9>  :set guifont=Meslo\ LG\ S\ for\ Powerline\ 7.5 <Bar> set lsp=-1 <CR>
nnoremap <silent> <F10> :set guifont=Fira\ Mono\ for\ Powerline\ 7.5 <Bar> set lsp=-1 <CR>
nnoremap <silent> <F11> :set guifont=Input\ 8 <Bar> set lsp& <CR>
nnoremap <silent> <F12> :set guifont=Envy\ Code\ R\ for\ Powerline\ 8 <Bar> set lsp& <CR>

" map \ and | to forward/backwards line search
" map , to |(column goto)
nnoremap \| ,
nnoremap , \|
nnoremap \ ;

" <CR> to :
"nnoremap <CR> :

" map window movement <C-W>{h,j,k,l}
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Buffer forward/backward
nnoremap <silent> <Tab> :bnext<CR>
nnoremap <silent> <S-Tab> :bprevious<CR>

" <Tab> == <C-I> so remap it
nnoremap <C-_> <C-O>
nnoremap <C-O> <C-I>

" ;space = nohighlight
nnoremap <silent> <leader><space> :noh<CR>

" cd to the directory of the current buffer
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>
nnoremap <leader>p :pwd<CR>

" toggle highlighting tabs and trailing spaces
nnoremap <silent> <leader>l :set list!<CR>

" toggle relative line numbers
nnoremap <leader>n :set rnu!<CR>

" strip trailing whitespace
nnoremap <leader>sw :call StripTrailWS()<CR>

" unbind Q (enter ex mode), its useless
nnoremap Q <Nop>

" map :write and :quit
nnoremap <silent> <leader>w :w<CR>
nnoremap <silent> QA :qa<CR>
nnoremap <silent> QW :xa<CR>

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>


"" SYNTAX HIGHLIGHTING
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    " Language specific syntax highlighting variables
    let c_curly_error = 1
    let c_syntax_for_h = 1
    let java_highlight_java_lang_ids = 1
    let java_ignore_javadoc = 1
    let java_highlight_debug = 1
    let perl_string_as_statement = 1
    let solarized_diffmode = "high"

    set hlsearch
    set colorcolumn=80
    syntax on

    if has("gui_running")
        colorscheme gruvbox
        set background=dark
        let g:airline_theme = 'gruvbox'
    else
        colorscheme solarized
        set background=dark
        let g:airline_theme = 'solarized'
    endif
endif
highlight StatusLine cterm=reverse,bold


"" AUTOCOMMANDS
" Only do this part when compiled with support for autocommands.
if has("autocmd")
    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on

    " Put these in an autocmd group, so that we can delete them easily.
    augroup vimrcEx
    au!
    " For all text files set 'textwidth' to 78 characters.
    autocmd FileType text setlocal textwidth=78

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    " Also don't do it when the mark is in the first line, that is the default
    " position when opening a file.
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif

    " Turn on omni syntax completion.
    if exists("+omnifunc")
        autocmd Filetype *
            \ if &omnifunc == "" |
            \   setlocal omnifunc=syntaxcomplete#Complete |
            \ endif
    endif

    " Use the special shellmenu.vim included in $VIMRUNTIME for shell scripts
    " edited using GVIM
    if has("gui_running")
        autocmd FileType sh runtime! macros/shellmenu.vim
    endif
    augroup END
else
    " if no filetype indenting then use smart and auto indenting
    set autoindent
    set smartindent
endif


"" COMMANDS AND FUNCTIONS
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
                     \ | wincmd p | diffthis
endif

" Command to delete trailing whitespace in the current buffer
if !exists(':StripTrail')
    command StripTrail exe 'normal mz' | %s/\s\+$//ge | exe 'normal `z'
                       \ | nohlsearch
endif


" vim: sw=4 sts=4 et
