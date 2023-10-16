vim.cmd([[autocmd! BufWritePost init.lua source init.lua | echom "                         Reloaded init.lua"]])
require("daniels.remap")
require("daniels.set")


-- ----__----_-----___----__--__--_____--____---- --
--   / / `  / \   /  _\  / /.'." / __ ' / / `)    --
--  /  _ / / _ \ |   _  / _'.'  / __'  / __'.     --
-- /  /   / / \ \ \ __//_/ \\  /____. / /  \ \    --
-- ---------------------------------------------- --
-- Ensure thaat packer is installed in the system --
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        print("Installing and initializing PACKER plugin manager for you")
        print("    If you are seeing this for the first time, good")
        print("                     If NOT...")
        print("Then check your configurations, something's out of wack!")
            fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
            vim.cmd [[packadd packer.nvim]]
        print("happy coding / error hunting / head banging / teeth crunching")
        print("                                      yours, King Daniel")
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- --------------------------------------- --
-- then installs the plugins on the system --
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    -- My plugins are in packer.lua
    if packer_bootstrap then
	    require('packer').sync()
    end
end)

---- Autocommand that reloads neovim whenever you save the packer.lua file
--vim.cmd([[
--augroup packer_user_config
--autocmd!
--autocmd BufWritePost packer.lua source <afile> | PackerSync
--augroup end
--]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
    return
end
-- -------------------------------------------- --
-- ------ END PACKER AUTO INITIALIZER --------- --
-- -------------------------------------------- --


print("                         welcome back King Daniel")

