" Necessary for lots of cool vim things
set nocompatible

" Support modelines in files that are open
set modeline

" Show what you are typing as a command
set showcmd

" Allow switching buffers without writing out first
set hidden

" Enable filetype detection, plugins, and syntax highlighting
filetype on
filetype plugin indent on
syntax on

" Go into paste mode to avoid e.g. autoindent
nnoremap <F3> :set paste!<CR>:set paste?<CR>

" Automatically indent new lines
set autoindent

" Uses spaces instead of tabs
set expandtab
set copyindent
set preserveindent
set softtabstop=0
set shiftwidth=4
set tabstop=4
"set cindent
"set cinoptions=(0,u0,U0

" Allow changing tabbing using F6 & F7

function! ChangeTabbing(newtab)
   let &shiftwidth = a:newtab
   let &softtabstop = a:newtab
   if &shiftwidth == 8
      set noexpandtab
   else
      set expandtab
   endif
   set softtabstop?
endfunction

nnoremap <F6> :call ChangeTabbing(&shiftwidth - 1)<CR>
nnoremap <F7> :call ChangeTabbing(&shiftwidth + 1)<CR>

" Use tabbing of 2 for yaml
autocmd BufRead,BufNewFile *.yaml,*.yml silent! :call ChangeTabbing(2)

" Don't care about casing when the query is all lowercase
set ignorecase
set smartcase

" Remaps kj/jk combinations in Insert Mode to <ESC>
inoremap kj <Esc>
inoremap kJ <Esc>
inoremap KJ <Esc>
inoremap Kj <Esc>

" Highlight search results
set hlsearch

" Always display a status bar
set laststatus=2

" Retrieves the number of buffers available
" This is used in the statusline after
" From http://superuser.com/questions/345520
" May delete if we don't use it in the statusline
function! NrBufs()
    let i = bufnr('$')
    let j = 0
    while i > 0
        if buflisted(i)
            let j += 1
        endif
        let i -= 1
    endwhile
    return j
endfunction

" Formatting of the status bar
" set statusline=%F%m%r%h%w%<\ {%Y}\ %=[%l,%v][%p%%][%n/%{NrBufs()}]
set statusline=%F%m%r%h%w%<\ {%Y}\ %=[%l,%v][%p%%]
"set statusline=%F%m%r%h%w%<\ {%Y}\ %=%{fugitive#statusline()}[%l,%v][%p%%]

" Start searching as we type
set incsearch

" Show relative line numbers black on grey
set number " Shows absolute line number at cursor pos
set relativenumber " Shows relative line number elsewhere
highlight LineNr ctermfg=black ctermbg=grey

" Characters to use when :set list is turned on to display hidden chars
set listchars=tab:>-,trail:~,extends:>,precedes:<

" Start with list on
set list

" Show/hide hidden characters
nnoremap <F2> :set list!<CR>:set list?<CR>

" Keep cursor within 3 lines of top or bottom line when scrolling
set scrolloff=3

" Show visual mode selection with green background
highlight Visual ctermbg=Green

" This clears highlighting from a previous pattern search
" (But it does NOT clear the search pattern, so 'n' would
" still keep searching!)
nnoremap <silent> <CR> :noh<CR><CR>

" This actually clears the 'last search term' register so
" the advantage is that it does not move the cursor
map <silent> <C-N> :let @/=""<CR>

" Enable mouse support for all modes
set mouse=a

" Buffer switcher
noremap <F5> :buffers<CR>:buffer<Space>
nnoremap <C-J> :bnext<CR>
nnoremap <C-K> :bprev<CR>
nnoremap <C-H> :bd<CR>

" Switch between 0, 60, 80, and 92 textwidth
function! ChangeTextWidth()
   if &textwidth == 0
      set textwidth=60
   elseif &textwidth == 60
      set textwidth=72
   elseif &textwidth == 72
      set textwidth=80
   elseif &textwidth == 80
      set textwidth=92
   else
      set textwidth=0
   endif
   if &textwidth == 0
      set colorcolumn=
   else
      set colorcolumn=+1
   endif
   set textwidth?
endfunction

noremap <F4> :call ChangeTextWidth()<CR>

" If we're editing code, automatically turn on the 80 width
autocmd BufNewFile,BufRead *.js,*.java,*.c,*.cpp,*.cxx,*.yaml,*.yml set textwidth=80
autocmd BufNewFile,BufRead *.py set textwidth=79

" It defaults to ELF otherwise (wtf??)
autocmd BufNewFile,BufRead *.am setf automake

" File types that don't necessarily have an extension
autocmd FileType bash,sh set textwidth=80
autocmd FileType python set textwidth=79

" Turn on coloured column (won't actually be on unless textwidth != 0)
set colorcolumn=+1

" Turn on/off highlighting of column textwidth+1
nnoremap <leader>l :set colorcolumn=+1<CR>
nnoremap <leader>L :set colorcolumn=<CR>

" Move by screen lines, not by real lines
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk

" Insert new line without exiting normal mode
nnoremap <silent> <leader>o o<ESC>
nnoremap <silent> <leader>O O<ESC>

" Reselect visual block after indent/outdent
xnoremap < <gv
xnoremap > >gv

" Commands to open .vimrc and source it
command! VIMRC :e $MYVIMRC
command! SOURCE source $MYVIMRC

" Make :W analogous to :w
command! W :w

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" Toggle the NERDTree
nnoremap <F8> :NERDTreeToggle<CR>

" Remember undo history
set undofile
set undodir=$HOME/.vim/undo
set undolevels=10000
set undoreload=100000

" Make backing up and swapping happen in centralized location
set backup
set backupdir=$HOME/.vim/backup//
set directory=$HOME/.vim/swap//
set writebackup

" Create dirs if they don't already exist
silent !mkdir -p $HOME/.vim/{undo,backup,swap} > /dev/null 2>&1

" Make text 60 chars wide for reports and markdown
autocmd BufRead,BufNewFile *.rpt set textwidth=60
autocmd BufRead,BufNewFile *.md set textwidth=60
autocmd BufRead,BufNewFile *.doc set textwidth=72

" For compabitily with tmux's xterm-style keys
if &term =~ '^screen'
   execute "set <xUp>=\e[1;*A"
   execute "set <xDown>=\e[1;*B"
   execute "set <xRight>=\e[1;*C"
   execute "set <xLeft>=\e[1;*D"
endif

" Start with no folding enabled so that when a file is
" opened it's never folded. It will get reenabled as soon as
" we zc a fold.
set nofoldenable

" Allow local projects to override settings
" https://andrew.stwrt.ca/posts/project-specific-vimrc/
set exrc
set secure

" Always put a vsplit on the right of current
set splitright

" Always put an hsplit under current
set splitbelow

" Rebuild cscope database with F9
nnoremap <silent> <F9> :!cs $(cat ~/.cscope/current)<CR>:cs reset<CR><CR>

command! Cnext try | cnext | catch | cfirst | endtry
command! Cprev try | cprev | catch | clast | endtry

" Easy quickfix navigation
nnoremap <silent> ]q :Cnext<CR>
nnoremap <silent> [q :Cprev<CR>

" Same for tags
nnoremap <silent> ]t :tn<CR>
nnoremap <silent> [t :tp<CR>

command! Lnext try | lnext | catch | lfirst | endtry
command! Lprev try | lprev | catch | llast | endtry

" And for locations
nnoremap <silent> ]e :Lnext<CR>
nnoremap <silent> [e :Lprev<CR>

" Keep going up dirs looking for a tags file
set tags+=tags;$HOME

" Trim trailing spaces in whole document
nnoremap <silent> <F10> :%s/\s\+$//e<CR>

" The default is "menu,preview", which will open up a
" preview window with extra info when auto-completing in
" insert mode. The annoyance is that it doesn't auto-close,
" and the dropdown menu already has all the info we want
" anyway.
set completeopt=menu

function! SetGrepPrg()
    let l:bufdir = expand('%:p:h')
    let l:gitroot = system("git -C " . l:bufdir . " rev-parse --show-toplevel")
    if v:shell_error
        " still use --exclude-dir; it might've failed because we don't even
        " have git
        let &grepprg = "grep -nr --color=never --exclude-dir=.git $* " . l:bufdir
    else
        " XXX: need to set this somewhere else, because the grepprg is already
        " set by then... when opening the buffer maybe?
        " XXX: use word separation
        " XXX: add mapping
        let &grepprg = "git grep -n --color=never $* -- " . gitroot
    endif
endfunction

autocmd BufRead,BufNewFile * call SetGrepPrg()

nnoremap <silent> gr :silent grep! '\b<cword>\b'<CR>:cw<CR>:redraw!<CR>

" Now plugin configurations
if filereadable(expand("~/.vim/autoload/pathogen.vim"))

    execute pathogen#infect()
    execute pathogen#helptags()

    " EXTENSION: https://github.com/sheerun/vim-polyglot
    if isdirectory(expand("~/.vim/bundle/vim-polyglot"))

        " Disable YAML because it doesn't highlight e.g. XXX, TODO
        " https://github.com/sheerun/vim-polyglot/issues/157
        let g:polyglot_disabled = ['yaml']

    endif

    " EXTENSION: https://github.com/vimwiki/vimwiki
    if isdirectory(expand("~/.vim/bundle/vimwiki"))

        let g:vimwiki_folding = 'expr'

        " disable url shortening
        let g:vimwiki_url_maxsave=0
        let g:vimwiki_list = [{'path': '~/.vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]

    endif

    " EXTENSION: https://github.com/ctrlpvim/ctrlp.vim
    if isdirectory(expand("~/.vim/bundle/ctrlp.vim"))

        " if a file is already open in a buffer, don't switch to the buffer, open the
        " file again in the current buffer
        let g:ctrlp_switch_buffer = 0

        " default to find buffer mode instead of file
        let g:ctrlp_cmd = 'CtrlPBuffer'

        " include current file in matches
        let g:ctrlp_match_current_file = 1

    endif

    " EXTENSION: https://github.com/ludovicchabant/vim-gutentags
    if isdirectory(expand("~/.vim/bundle/vim-gutentags"))

        " Only regen tags for files tracked by git
        let g:gutentags_file_list_command = 'git ls-files'

        " Be able to tell when Gutentags is regenerating tags
        set statusline+=%{gutentags#statusline('[',']')}

        " But force a status line refresh otherwise it won't go away
        augroup RefreshStatusLine
            autocmd!
            autocmd User GutentagsUpdating redrawstatus!
            autocmd User GutentagsUpdated redrawstatus!
        augroup END

    endif

    " EXTENSION: https://github.com/wincent/command-t
    if isdirectory(expand("~/.vim/bundle/command-t"))

        " use git to get the list of files, fall back to find
        let g:CommandTFileScanner = 'git'
        let g:CommandTMaxFiles=400000

        let g:CommandTAlwaysShowDotFiles = 1

        " default, though good to know in case I want to change it
        " controls whether submodules should be scanned
        let g:CommandTGitScanSubmodules = 0

        " default, though good to know in case I want to change it
        " controls whether untracked files should be scanned
        let g:CommandTGitIncludeUntracked = 0

        " find files in vim's current dir instead
        " this is helpful when you cscope away to some lib file, but still want
        " Command-T to only list files from your original project
        let g:CommandTTraverseSCM = 'dir'

        " allow changing the IncludeUntracked setting when pressing <C-r> in the prompt
        " but needs custom patch applied: https://github.com/wincent/command-t/issues/290
        function! CommandTControlRCallback()
          let g:CommandTGitIncludeUntracked=!get(g:, 'CommandTGitIncludeUntracked', 0)
          call commandt#Flush()
          call commandt#Refresh()
        endfunction

        let g:CommandTCustomMappings={
              \   '<C-r>': ':call CommandTControlRCallback()<cr>'
              \ }

    endif

    " EXTENSION: https://github.com/w0rp/ale
    if isdirectory(expand("~/.vim/bundle/ale"))

        " Don't lint when changing the text (it will then only lint
        " when we open the file and when we save it).
        let g:ale_lint_on_text_changed = 0
        let g:ale_lint_on_enter = 1 " default
        let g:ale_lint_on_save = 1 " default

        " Only report actual errors
        let g:ale_python_pylint_options = '-E'
        let g:ale_yaml_yamllint_options = '-d relaxed'

        " A horrendously hacky linter that uses `make -n`, but it works!
        " There's a `g:ale_c_parse_makefile` intended for e.g. clang/gcc, but
        " it doesn't use the command verbatim, only for extracting flags. This
        " fails for e.g. libtool commands.
        let g:ale_linters = {'c': ['maken']}
        let g:ale_c_parse_makefile = 1 " needed for our hack

    endif
endif
