-- vim.cmd([[autocmd FileType markdown let g:indentLine_enabled=0]])
require("daniels.remap")
require("daniels.set")

-- ----__----_-----___----__--__--_____--____---- --
--   / / `  / \   /  _\  / /.'." / __ / / / `)    --
--  /  _ / / _ \ |  |_  / _'.'  / __'  / __'.     --
-- /_/    /_/ \_\ \__/ /_/ \\  /____/ / /  \ \    --
-- ---------------------------------------------- --
-- Ensure that packer is installed in the system --
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        print("Installing and initializing PACKER plugin manager for you")
        print("    If you are seeing this for the first time, good")
        print("                     If NOT...")
        print("Then check your configurations, something's out of wack!")
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd([[packadd packer.nvim]])
        print("       Packer was successfully cloned and installed")
        print("happy coding / error hunting / head banging / teeth crunching")
        print("    PS: restart neovim for all changes to take effect")
        print("                                      yours, King Daniel")
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- --------------------------------------- --
-- then installs the plugins on the system --
require("packer").startup(function(use)
    use("wbthomason/packer.nvim")
    -- My plugins are in packer.lua
    if packer_bootstrap then
        require("packer").sync()
    end
end)

---- Autocommand that reloads neovim whenever you save the packer.lua file
vim.api.nvim_create_autocmd("BufWritePost", {
    desc = "Reload neovim whenever you save the packer.lua file",
    group = vim.api.nvim_create_augroup("packer_user_config", { clear = true }),
    pattern = "packer.lua",
    callback = function()
        vim.cmd("source <afile> | PackerSync")
    end,
})

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- -------------------------------------------- --
-- ------ END PACKER AUTO INITIALIZER --------- --
-- -------------------------------------------- --

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank({ timeout = "30" })
    end,
})

print("                         welcome back King Daniel")
