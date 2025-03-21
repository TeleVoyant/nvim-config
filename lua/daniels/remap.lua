-- leader key <space>
vim.g.mapleader = " "

-- netexplorer launcher
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- nvim-tree launcher
vim.keymap.set("n", "<leader>w", vim.cmd.NvimTreeOpen)

-- moves highlighted group-of-source codes [VISUAL-MODE]
-- towards the botton
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- or to the top
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Enforces the cursor to remain on the same place
vim.keymap.set("n", "J", "mzJ`z")

-- Enforces the cursor to stay in the middle when
-- jumping to the bottom
vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- or to the top
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Enforces cursor and the search-terms to stay in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- -- Plugin vim-with-me
-- vim.keymap.set("n", "<leader>vwm", function()
--     require("vim-with-me").StartVimWithMe()
-- end)
-- vim.keymap.set("n", "<leader>svwm", function()
--     require("vim-with-me").StopVimWithMe()
-- end)
-- -- end plugin vim-with-me

-- "greatest remap ever" says the primeagen
-- prevents ALTERNING of copied buffer to the replaced contents
-- by deleting the replaced contents into "the null void"
vim.keymap.set("x", "<leader>p", '"_dP')

-- next greatest remap ever : asbjornHaland
-- toggles the system clipboard, for pasting outside neovim
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')
-- or you could just use plane "y" for using only inside neovim (text buffer)
-- beautiful flexibity

-- this also deletes selected contents into "the null void"
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

-- This is an alternative to <ESC> key
-- <ESC> is a bit out of reach!
vim.keymap.set("i", "<C-c>", "<Esc>")

-- using tmux to switch between projects
-- you need tmux for this!
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set("n", "<leader>=", function()
    vim.lsp.buf.format()
end)

-- advanced search and replace word shortcut
-- grabs the contents under the cursor and initiates replace action
vim.keymap.set("n", "<leader>sw", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
vim.keymap.set("v", "<leader>sw", ":s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- advanced search and replace selected chars shortcut
-- does not grab anything, but gives you the frexibility to replace anything!
vim.keymap.set("n", "<leader>sc", ":%s/\\\\+/___/g<Left><Left><Left><Left><Left><Left><Left><Left>")
vim.keymap.set("v", "<leader>sc", ":s/\\\\+/___/g<Left><Left><Left><Left><Left><Left><Left><Left>")

-- makes scripts executable ( using command chmod +x $filename.$fileext )
vim.keymap.set("n", "<leader>mx", "<cmd>!chmod +x %<CR>", { silent = true })

-- Undo and redo just like back and fwd from browser vimium c
-- more of the vimium c tab management remaps are done in barbar.lua
vim.keymap.set("n", "<A-h>", vim.cmd.undo)
vim.keymap.set("n", "<A-l>", vim.cmd.redo)

-- invisibility cloak toggle
vim.keymap.set("n", "<leader>H", ":CloakToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>h", ":CloakPreviewLine<CR>", { silent = true })

-- adaptive jumps silently
vim.keymap.set("n", "<C-j>", ":lua vim.cmd(string.format('normal! %dj', JumpAmount('j', 'n')))<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", ":lua vim.cmd(string.format('normal! %dk', JumpAmount('k', 'n')))<CR>", { silent = true })
vim.keymap.set("n", "<C-h>", ":lua vim.cmd(string.format('normal! %dh', JumpAmount('h', 'n')))<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", ":lua vim.cmd(string.format('normal! %dl', JumpAmount('l', 'n')))<CR>", { silent = true })
-- jump with selection towards the botton
vim.keymap.set("v", "<C-j>", ':lua vim.cmd(":\'<,\'>m .+" .. JumpAmount("j", "v"))<CR>gv=gv', { silent = true })
-- or towards the top with the selection
vim.keymap.set("v", "<C-k>", ':lua vim.cmd(":\'<,\'>m .-" .. JumpAmount("k", "v")-1)<CR>gv=gv', { silent = true })

----------------------------------------------------------
---- CUSTOM FUNCTIONS THAT GO WITH THE ABOVE MAPPINGS ----
----------------------------------------------------------

-- JUMPING DIST CALCULATOR --
--- Jumps depending on mode, window height and width
---@param key string: determines direction of jump (h, j, k, l)
---@param mode string: determines if we are in normal mode or visual
---@return integer: returns precalculated jump amount
function JumpAmount(key, mode)
    local dist
    local befDist = vim.fn.line("'<") -- btn Top and 'start of selection'
    local aftDist = vim.api.nvim_buf_line_count(0) - vim.fn.line("'>") -- btn 'end of selection' and Bot
    if key == "j" then -- vertical down
        dist = vim.api.nvim_win_get_height(0)
        -- check if we're jumping in visual mode
        -- and dist exceeds jumpable interval, why 4? it just worked!
        if mode == "v" and dist > aftDist + 4 then
            dist = aftDist + 4
        end
    elseif key == "k" then --vertical up
        dist = vim.api.nvim_win_get_height(0)
        -- check if we're jumping in visual mode
        -- and dist exceeds jumpable interval, why 3? because 4-1 :)
        if mode == "v" and dist > befDist + 3 then
            dist = befDist + 3
        end
    elseif key == "h" or key == "l" then -- horizontal left right
        dist = vim.api.nvim_win_get_width(0)
    else
        return 0 -- unknown direction, dont jump
    end
    return math.floor(dist / 1.5)
end

-- end JUMPING DIST CALCULATOR --
