-- this file will set all necessary options required
-- obviously
vim.opt.termguicolors = true

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

vim.opt.scrolloff = 9

-- extra column before 'nu' (for warnings, errors labels)
vim.opt.signcolumn = "yes"

vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "100"

-- Enable 'list' mode to show invisible characters
vim.opt.list = true

-- Set custom symbols for various invisible characters
vim.opt.listchars = {
    tab = "→ ", -- Tabs will be shown as '→ '
    -- space = "·", -- Spaces will appear as dots
    trail = "·", -- Trailing spaces shown as bullet
    eol = "¬", -- End of line shown as '¬'
    extends = "»", -- Wrap indicator: line continues beyond right
    precedes = "«", -- Wrap indicator: line continues before left
    nbsp = "␣", -- Non-breaking space shown as open box
}
