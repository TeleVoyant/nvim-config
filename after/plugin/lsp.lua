-- reserve space for diagnostic icons
-- vim.opt.signcolumn = "yes"

-- ------------------------------------- --
-- lsp-zero configurations are down here --
-- ------------------------------------- --
local lsp = require("lsp-zero").preset({})

-- ---------------------------------------- --
-- lsp notifications will be processed here --
require("fidget").setup({
    progress = {
        -- how LSP progress messages are displayed as notifications
        display = {
            render_limit = 9, -- How many LSP messages to show at once
            done_ttl = 2, -- How long a message should persist after completion
        },
    },

    notification = {
        -- Options related to how notifications are rendered as text
        view = {
            group_separator_hl = "Comment",
        },
        -- Options related to the notification window and buffer
        window = {
            normal_hl = "Comment", -- Base highlight group in the notification window
            winblend = 0, -- Background color opacity in the notification window (zero to follow neovim theme)
        },
    },
})
-- ---------------------------------------- --

-- ---------------------------------- --
-- mason configurations are down here --
-- ---------------------------------- --
-- make sure this servers are installed
-- see :help lsp-zero-guide.customize-nvim-cmp
require("mason").setup({
    PATH = "prepend", -- "skip" seems to cause the spawning error

    ui = {
        ---@since 1.0.0
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        -- border = "none",
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },

        ---@since 1.0.0
        -- Width of the window. Accepts:
        -- - Integer greater than 1 for fixed width.
        -- - Float in the range of 0-1 for a percentage of screen width.
        width = 0.8,

        ---@since 1.0.0
        -- Height of the window. Accepts:
        -- - Integer greater than 1 for fixed height.
        -- - Float in the range of 0-1 for a percentage of screen height.
        height = 0.8,

        icons = {
            ---@since 1.0.0
            -- The list icon to use for installed packages.
            package_installed = "◍",
            ---@since 1.0.0
            -- The list icon to use for packages that are installing, or queued for installation.
            package_pending = "◍",
            ---@since 1.0.0
            -- The list icon to use for packages that are not installed.
            package_uninstalled = "◍",
        },
    },
})
require("mason-tool-installer").setup({
    ensure_installed = {
        "prettierd",
        "stylua",
        "isort",
        "black",
        "codespell",
        "goimports",
        "eslint_d",
        "phpcbf",
        "phpstan",
        "phpcs",
        "pylint",
        "cpplint",
        "yamllint",
        "htmlhint",
        "shellcheck",
        "clang-format",
        "vint",
        "xmlformatter",
        "shfmt",
        "solhint",
        "asmfmt",
    },
})
require("mason-lspconfig").setup({
    -- Replace the language servers listed here
    -- with the ones you want to install
    ensure_installed = {
        "zls",
        "sqlls",
        "rust_analyzer",
        "gopls",
        "lua_ls",
        "vimls",
        "emmet_language_server",
        "intelephense",
        "dockerls",
        "docker_compose_language_service",
        "bashls",
        "elixirls",
        "erlangls",
        "lemminx",
        "pyright",
        "jdtls",
        "jsonls",
        "ts_ls",
        "solidity_ls_nomicfoundation",
        "solidity_ls",
        "asm_lsp",
    },
    handlers = {
        lsp.default_setup,
        lua_ls = function()
            -- Configure lua language server for neovim
            require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
        end,
    },
})

-- ---------------------------------- --
-- --------- LSP-ZERO SETUP --------- --
-- ---------------------------------- --
local cmp_action = require("lsp-zero").cmp_action()

lsp.on_attach(function(foobar, bufnr)
    -- -------------------------------------------------------------- --
    -- Display language server(s) that are loaded, on the prompt-line --
    local function get_active_lsps()
        local clients = vim.lsp.get_clients()
        local total_clients = ""
        local count = 0
        if #clients > 0 then -- if there is at least one client
            for _, client in ipairs(clients) do
                -- grab clients active (yes, there may be more than one per file, per noevim session)
                if count == 0 then
                    total_clients = total_clients .. " 󰂓 " .. client.name:gsub("_", " ") -- append
                else
                    total_clients = total_clients .. ", 󰂓 " .. client.name:gsub("_", " ") -- append
                end
                count = count + 1
            end
            -- display captured language servers appropriately
            if count < 2 then -- if there is one active
                return total_clients .. " server active"
            elseif count > 4 then -- if they are five or more active, collapse the list. display two only
                return total_clients:sub(1, total_clients:find(",", 1, true))
                    .. total_clients:sub(
                        total_clients:find(",", 1, true) + 1,
                        total_clients:find(",", total_clients:find(",", 1, true) + 1, true) - 1
                    )
                    .. " and "
                    .. count - 2
                    .. " other servers active"
            else -- if there is more than one active
                return total_clients .. " servers active"
            end
        else -- if there is no client
            return " No LSP Server Active"
        end
    end
    -- only notify once, and on new language server detection
    vim.notify_once(get_active_lsps(), vim.log.levels.INFO, { silent = true })
    -- -------------------------------------------------------------- --

    -- lsp keymaps
    local opts = { buffer = bufnr, remap = false }
    vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
    end, opts)
    vim.keymap.set("n", "gi", function()
        vim.lsp.buf.implementation()
    end, opts)
    vim.keymap.set("n", "gD", function()
        vim.lsp.buf.declaration()
    end, opts)
    vim.keymap.set("n", "gr", function()
        vim.lsp.buf.references()
    end, opts)
    vim.keymap.set("n", "J", function()
        vim.lsp.buf.hover()
    end, opts)
    vim.keymap.set("n", "K", function()
        vim.lsp.buf.signature_help()
    end, opts)
    vim.keymap.set("n", "L", function()
        vim.lsp.buf.type_definition()
    end, opts)
    vim.keymap.set("n", "<leader>vws", function()
        vim.lsp.buf.workspace_symbol()
    end, opts)
    vim.keymap.set("n", "<leader>vd", function()
        vim.diagnostic.open_float()
    end, opts)
    vim.keymap.set("n", "[d", function()
        vim.diagnostic.goto_prev()
    end, opts)
    vim.keymap.set("n", "]d", function()
        vim.diagnostic.goto_next()
    end, opts)
    vim.keymap.set({ "n", "v" }, "<leader>vca", function()
        vim.lsp.buf.code_action()
    end, opts)
    vim.keymap.set("n", "<leader>vrf", function()
        vim.lsp.buf.references()
    end, opts)
    vim.keymap.set("n", "<leader>vrn", function()
        vim.lsp.buf.rename()
    end, opts)
    vim.keymap.set("i", "<C-i>", function()
        vim.lsp.buf.signature_help()
    end, opts)
end)

-- Highlight entire line for errors
-- Highlight the line number for warnings
-- to show icons on the error column instead of E, W, H, I
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "ⓘ",
            [vim.diagnostic.severity.HINT] = "",
        },
        linehl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
        },
        numhl = {
            [vim.diagnostic.severity.WARN] = "WarningMsg",
        },
    },
})

-- extend lsp to nvim-cmp
lsp.extend_cmp()

-- --------------------------------------------- --
-- ---- AUTO-COMPLETE DIALOG CONFIGURATION ----- --
-- nvim-cmp configurations follow after lsp-zero --
-- --------------------------------------------- --
require("cmp_git").setup() -- initialize cmp_git
local cmp = require("cmp")
local types = require("cmp.types")
local str = require("cmp.utils.str")
local neogen = require("neogen")

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- snippets section
local luasnip = require("luasnip")

-- Do not jump to snippet if i'm outside of it
-- https://github.com/L3MON4D3/LuaSnip/issues/78
luasnip.config.setup({
    region_check_events = "CursorMoved",
    delete_check_events = "TextChanged",
})

local lspkind = require("lspkind")

cmp.setup({
    window = {
        completion = { winhighlight = "Normal:CmpNormal" },
        documentation = { winhighlight = "Normal:CmpDocNormal" },
    },
    -- formatings of nvim-cmp
    formatting = {
        fields = {
            cmp.ItemField.Kind,
            cmp.ItemField.Abbr,
            cmp.ItemField.Menu,
        },
        format = require("lspkind").cmp_format({
            mode = "symbol",
            before = function(entry, vim_item)
                -- Get the full snippet (and only keep first line)
                local word = entry:get_insert_text()
                word = str.oneline(word)

                -- concatenates the string
                local max = 50
                if string.len(word) >= max then
                    local before = string.sub(word, 1, math.floor((max - 3) / 2))
                    word = before .. "..."
                end

                if
                    entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet
                    and string.sub(vim_item.abbr, -1, -1) == "~"
                then
                    word = word .. "~"
                end
                vim_item.abbr = word

                return vim_item
            end,
        }),
    },
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },

    -- mappings for nvim-cmp, with fallback protection when inactive
    mapping = {

        ["<C-j>"] = cmp.mapping(function(fallback)
            -- fallback() should release the key if completion is not visible
            if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior, count = 1 })
            -- for neogen auto completion
            elseif neogen.jumpable() then
                neogen.jump_next()
            else
                fallback()
            end
        end),

        ["<C-k>"] = cmp.mapping(function(fallback)
            -- fallback() should release the key if completion is not visible
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior, count = 1 })
            -- for neogen auto completion
            elseif neogen.jumpable(true) then
                neogen.jump_prev()
            else
                fallback()
            end
        end),

        ["<C-l>"] = cmp.mapping(function(fallback)
            -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
            if cmp.visible() then
                local entry = cmp.get_selected_entry()
                if not entry then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior, count = 1 })
                end
                cmp.confirm()
            else
                fallback()
            end
        end),

        ["<C-Space>"] = cmp.mapping(function(fallback)
            -- fallback() should release the key if completion is not visible
            if cmp.visible() and cmp.visible_docs() then
                cmp.close_docs()
            elseif cmp.visible() and not cmp.visible_docs() then
                cmp.abort()
            elseif not cmp.visible() then
                cmp.complete()
            else
                fallback()
            end
        end),
    },

    -- You should specify your *installed* sources.
    sources = {
        { name = "luasnip" },
        { name = "nvim_lsp" },
        { name = "buffer", keyword_length = 5, max_item_count = 5 },
        { name = "path" },
        { name = "git" },
    },

    experimental = {
        -- dnt knw what this is.. oh, found out; ghost texts appear as you type
        -- didn't like it, turned it to false
        ghost_text = false,
    },
})

require("cmp").setup.cmdline(":", {
    sources = {
        { name = "cmdline", keyword_length = 2 },
    },
})
