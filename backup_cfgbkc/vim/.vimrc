call plug#begin()

" vim 启动屏幕，可显示最近打开的文件
Plug 'mhinz/vim-startify'
" vim 主题
Plug 'NLKNguyen/papercolor-theme'
" Plug 'cocopon/iceberg.vim'
" Plug 'joshdick/onedark.vim'
" vim 图标
Plug 'ryanoasis/vim-devicons'
" vim 底部状态栏增强
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" vim 目录树
Plug 'preservim/nerdtree'
" vim 撤销树
Plug 'mbbill/undotree'
" vim 展示文件整体结构
Plug 'preservim/tagbar'
" vim git插件
Plug 'tpope/vim-fugitive'
" vim 括号自动补全
Plug 'jiangmiao/auto-pairs'
" vim 快速模糊搜索
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
" vim 分割线
Plug 'Yggdroot/indentLine'
" vim 代码自动补全
Plug 'ycm-core/YouCompleteMe'
" vim 代码块
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" vim 代码模板
Plug 'chxuan/prepare-code'
" vim 快速注释
" Plug 'scrooloose/nerdcommenter'

call plug#end()

" 语法高亮
syntax enable
" 启用256色
set t_Co=256
set background=dark
" 配置主题
colorscheme PaperColor
" colorscheme iceberg
" colorscheme onedark
" airline 配置
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1           " enable airline tabline
let g:airline#extensions#tabline#show_close_button = 0 " remove 'X' at the end of the tabline                                            
let g:airline#extensions#tabline#tabs_label = ''       " can put text here like BUFFERS to denote buffers (I clear it so nothing is shown)
let g:airline#extensions#tabline#buffers_label = ''    " can put text here like TABS to denote tabs (I clear it so nothing is shown)      
let g:airline#extensions#tabline#fnamemod = ':t'       " disable file paths in the tab
let g:airline#extensions#tabline#show_tab_count = 0    " dont show tab numbers on the right
let g:airline#extensions#tabline#show_buffers = 0      " dont show buffers in the tabline
let g:airline#extensions#tabline#tab_min_count = 2     " minimum of 2 tabs needed to display the tabline
let g:airline#extensions#tabline#show_splits = 0       " disables the buffer name that displays on the right of the tabline
let g:airline#extensions#tabline#show_tab_nr = 0       " disable tab numbers
let g:airline#extensions#tabline#show_tab_type = 0     " disables the weird ornage arrow on the tabline

" set nocompatible                " 关闭兼容模式,启用更多功能特性
set encoding=utf-8              " 指定使用utf-8
filetype plugin on              " 文件类型检测
set number                      " 开启行号
set cursorline                  " 高亮显示当前行
set linebreak                   " 只有遇到指定符号才换行
set laststatus=2                " 显示状态栏
set virtualedit=block,onemore   " 允许光标出现在最后一个字符的后面
set backspace=indent,eol,start  " 设置backspace可在INSERT模式下删除
" set cmdheight=2                 " 设置命令行的高度
set showcmd                     " 在命令行显示输入的命令
set ttimeoutlen=0               " 设置<ESC>键响应时间
" 在命令模式下启用命令补全
set wildmenu
set wildmode=longest:list,full

set autoindent                  " 设置自动缩进
set smartindent                 " 智能选择对齐方式
set expandtab                   " 将制表符扩展为空格
set tabstop=4                   " 设置tab=4空格
set shiftwidth=4                " 设置缩进为4空格
set smarttab                    " 在行和段开始处使用制表符

set hlsearch                    " 高亮显示搜索结果
set incsearch                   " 开启实时搜索功能

set nobackup                    " 设置不备份
set noswapfile                  " 禁止生成临时文件
set autowrite                   " 设置自动保存
set autoread                    " 自动重新文件更改
set confirm                     " 在处理未保存或只读文件的时候，弹出确认

" 保留撤销历史
if !isdirectory($HOME."/.vim")
    call mkdir($HOME."/.vim", "", 0700)
endif
if !isdirectory($HOME."/.vim/.undo")
    call mkdir($HOME."/.vim/.undo", "", 0700)
endif
set undodir=~/.vim/.undo//
set undofile

" 设置记录的历史操作次数
set history=1000
" 当重新打开文件时光标回到上一次所在位置
if has('viminfo')
    autocmd BufWinLeave ?* mkview              " 在离开缓冲区时保存视图
    autocmd BufWinEnter ?* silent loadview     " 在进入缓冲区时加载视图
endif

" 自定义映射
" 定义<leader>键
let mapleader = ","

" 快速注释
let g:NERDSpaceDelims=1
let g:NERDCommentEmptyLines = 1
let g:NERDCustomDelimiters = { 'c': { 'left': '// ','right': '' } }

" 开启目录树
nnoremap <C-n> :NERDTreeToggle<CR>
" 开启撤销树
nnoremap <F5> :UndotreeToggle<CR>
" 开启文件视图
nnoremap <C-m> :TagbarToggle<CR>
" 配置 U 为重做
nnoremap U <C-r>
" 修改连按kj为ESC
inoremap kj <ESC>

" pwn
nnoremap <leader><leader>r :!%:p<CR>
nnoremap <leader><leader>g :!%:p GDB<CR>
nnoremap <leader><leader>x :!chmod +x %:p<CR><CR>
nnoremap <leader><leader><leader>r :!%:p REMOTE<CR>

" 代码块相关
let g:UltiSnipsExpandTrigger="<C-g>"
let g:UltiSnipsJumpForwardTrigger="<C-f>"
let g:UltiSnipsJumpBackwardTrigger="<C-b>"

" 代码模板相关
let g:prepare_code_plugin_path = expand($HOME . "/.vim/plugged/prepare-code")

