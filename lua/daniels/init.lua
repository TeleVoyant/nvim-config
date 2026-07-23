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

-- ---- Autocommand that reloads neovim whenever you save the packer.lua file
-- vim.api.nvim_create_autocmd("BufWritePost", {
--     desc = "Reload neovim whenever you save the packer.lua file",
--     group = vim.api.nvim_create_augroup("packer_user_config", { clear = true }),
--     pattern = "packer.lua",
--     callback = function()
--         vim.cmd("source <afile> | PackerSync")
--     end,
-- })

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Reload & PackerSync packer.lua on save, but only if the meaningful content
-- actually changed. Fail-safe: the file is sourced FIRST, and the content
-- hash is only committed (and PackerSync only run) if that succeeds — so a
-- save with a typo never gets marked as "already synced".

local opts = {
    notify = true, -- set false to silence notifications
    sync_cmd = "PackerSync", -- swap for "PackerCompile" if you prefer
    debounce_ms = 150, -- collapse bursts of rapid saves
}

local HASH_PATTERN = "^%-%-§(.*)§%-%-$"
local function hash_line(hash)
    return "--§" .. hash .. "§--"
end

local _reloading = false -- true only while we're doing our own synthetic write
local _generation = 0 -- debounce token, bumped on every save event

local function notify(msg, level)
    if opts.notify then
        vim.notify(msg, level or vim.log.levels.INFO, { title = "packer.lua" })
    end
end

-- ── hashing — reads straight from the buffer, no disk IO / race ──────────
local function compute_hash(bufnr)
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, -1, false)
    if not ok then
        notify("could not read buffer: " .. tostring(lines), vim.log.levels.ERROR)
        return nil
    end
    local filtered = {}
    for i, line in ipairs(lines) do
        if i == 1 and line:match(HASH_PATTERN) then
            goto continue
        end
        local no_comment = line:gsub("%-%-.*$", "")
        no_comment = no_comment:match("^%s*(.-)%s*$")
        if no_comment ~= "" then
            table.insert(filtered, no_comment)
        end
        ::continue::
    end
    return vim.fn.sha256(table.concat(filtered, "\n"))
end

local function read_stored_hash(bufnr)
    local ok, first = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, 1, false)
    if not ok or not first[1] then
        return nil
    end
    return first[1]:match(HASH_PATTERN)
end

-- Writes the hash line into the BUFFER, then persists with `noautocmd write`.
-- This fixes a real bug from the previous version: writing the hash straight
-- to disk via vim.fn.writefile() left the in-memory buffer stale, so your
-- very next real save would silently clobber the hash line again. Editing
-- the buffer + noautocmd write keeps buffer and disk identical, and can't
-- recurse, since autocmds are suppressed for the duration of this write.
local function commit_hash(bufnr, hash)
    local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
    if first and first:match(HASH_PATTERN) then
        vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { hash_line(hash) })
    else
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { hash_line(hash) })
    end

    _reloading = true
    local ok, err = pcall(vim.cmd, "noautocmd write")
    _reloading = false

    if not ok then
        notify("failed to persist hash line: " .. tostring(err), vim.log.levels.ERROR)
        return false
    end
    return true
end

-- ── core flow: source FIRST, only commit + sync if that succeeds ─────────
local function sync(bufnr, file)
    local ok, err = pcall(vim.cmd, "source " .. vim.fn.fnameescape(file))
    if not ok then
        notify("source failed, packer.lua left un-synced:\n" .. tostring(err), vim.log.levels.ERROR)
        return -- old hash stays put, so the next save retries instead of skipping
    end

    local new_hash = compute_hash(bufnr)
    if not new_hash or not commit_hash(bufnr, new_hash) then
        return
    end

    if vim.fn.exists(":" .. opts.sync_cmd) ~= 2 then
        notify(opts.sync_cmd .. " not found (is packer.nvim loaded?)", vim.log.levels.WARN)
        return
    end

    local sync_ok, sync_err = pcall(vim.cmd, opts.sync_cmd)
    if not sync_ok then
        notify(opts.sync_cmd .. " failed: " .. tostring(sync_err), vim.log.levels.ERROR)
        return
    end

    notify("packer.lua changed — " .. opts.sync_cmd .. " triggered")
end

local function process(bufnr)
    if _reloading or not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end
    local new_hash = compute_hash(bufnr)
    if not new_hash then
        return
    end

    if new_hash == read_stored_hash(bufnr) then
        notify("packer.lua saved — no content change detected", vim.log.levels.DEBUG)
        return
    end

    sync(bufnr, vim.api.nvim_buf_get_name(bufnr))
end

-- ── autocmd: debounced entry point ────────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePost", {
    desc = "Reload packer only if packer.lua content hash changed",
    group = vim.api.nvim_create_augroup("packer_user_config", { clear = true }),
    pattern = "packer.lua",
    callback = function(args)
        if _reloading then
            return
        end
        local bufnr = args.buf
        _generation = _generation + 1
        local my_generation = _generation
        vim.defer_fn(function()
            if my_generation == _generation then
                process(bufnr)
            end
        end, opts.debounce_ms)
    end,
})

-- ── manual escape hatch ────────────────────────────────────────────────────
vim.api.nvim_create_user_command("PackerHashForceSync", function()
    local bufnr = vim.api.nvim_get_current_buf()
    sync(bufnr, vim.api.nvim_buf_get_name(bufnr))
end, { desc = "Force-source packer.lua and PackerSync, ignoring the stored hash" })

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
