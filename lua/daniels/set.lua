-- this file will set all necessary options required

-- space as leader key
vim.g.mapleader = " "

vim.opt.guicursor = ""

-- number line configuration
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.conceallevel = 2

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- do not HighLight search, disgusting
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- obviously
vim.opt.termguicolors = true

vim.opt.scrolloff = 9

-- extra column before 'nu' (for warnings, errors labels)
vim.opt.signcolumn = "yes"

vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "100"
