-- Set tab width
vim.opt.tabstop = 4         -- Number of spaces tabs count for
vim.opt.softtabstop = 4         -- Number of spaces tabs count for
vim.opt.shiftwidth = 4      -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true    -- Use spaces instead of tabs

vim.opt.smartindent = true

vim.opt.wrap = false

-- Backups handled by undotree
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.g.mapleader = " "

-- Enable relative line numbers
vim.opt.number = true         -- Enable absolute line number on the current line
vim.opt.relativenumber = true -- Enable relative line numbers on all other lines


