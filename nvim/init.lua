---- These settings configure the general behvaiour of Neovim
local opt = vim.opt

-- enable line numbers and relative numbers
opt.number = true -- show absolute line numbers
opt.relativenumber = true -- show relative line numbers
opt.numberwidth = 4 -- Width of the number column

-- Tabs and indentation
opt.tabstop = 2 -- Number of spaces a tab counts for
opt.autoindent = true -- Copy indent from current line when starting new line
opt.smartindent = true -- Smart autoindentation when starting a new line

-- Line wrapping
opt.wrap  = false
opt.linebreak = true

-- Search settings
opt.ignorecase = true -- Ignore case when searching
-- opt.smartcase = true -- Override ignorecase if search contains uppercase
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Show search matches as you type

-- Appearance
opt.termguicolors = true -- Enable 24 bit RGB colours
opt.background = "dark" -- Use dark backgroud
opt.signcolumn = "yes" -- Always show sign columns (prevent test shift)
opt.cursorline = true -- Highlight current line
-- opt.colorcolumn = "80" --Show vertical line at 80 characters (optional)

-- Behaviour
opt.mouse = "a" --Enable mouse support for all nodes
opt.clipboard = "unnamedplus" -- Use system clipboard (like vscode)
opt.splitbelow = true -- vertical splits open to below
opt.splitright = true -- horizontal splits open to right
opt.iskeyword:append("-") -- treat dash separated words as one word

-- File handling
opt.swapfile = false -- disable swap files
opt.backup = false -- disable backup files
opt.undofile = true -- enable persistent undo
opt.undodir = os.getenv("HOME") .. "/.vim/undodir" --undo directory

-- Completion
opt.completeopt = "menu,menuone,noselect" -- Better completion exp
opt.pumheight = 10 -- max number of items in the popup menu

-- Performance
opt.updatetime = 300 -- Faster completion (default is 4000ms)
opt.timeoutlen = 500 -- Time to wait for mapped sequence (ms)

-- Scrolling
-- opt.scrolloff = 8 -- Minimum line to keep above/below cursor
-- opt.sidescrolloff = 8 -- Minimum columns to keep left/right of cursor

-- Command Line
opt.cmdheight = 1 -- Height of command line
opt.showcmd = true -- Show command is status line
opt.showmode = false -- Dont show mode (well use status line plugin)

-- Folding (using Treesitter)
opt.foldmethod = "expr" -- use expression for folding
opt.foldexpr = "nvim_treesitter#foldexpr()" -- use treesitter for folding
opt.foldenable = false -- Dont fold by default

-- Speacial characters
vim.keymap.set("n","-", vim.cmd.Ex)

-- the default leader key is \ but using space bar is way more convenient
vim.g.mapleader = "<CR>"
vim.g.maplocalleader = "<CR>"
--print("hello")

-- Python provider
-- Set python provider (adjust path to your python installation)
-- vim.g.python3_host_prog = '/usr/bin/python3' -- uncomment and adjust if needed
require("config.lazy")
require("config.keymaps")
