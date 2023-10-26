-- reserve space for diagnostic icons
vim.opt.signcolumn = 'yes'

-- ------------------------------------- --
-- lsp-zero configurations are down here --
-- ------------------------------------- --
local lsp = require('lsp-zero').preset({})

-- make sure this servers are installed
-- see :help lsp-zero-guide.customize-nvim-cmp
require('mason').setup({})
require('mason-lspconfig').setup({
    -- Replace the language servers listed here
    -- with the ones you want to install
    ensure_installed = {'tsserver', 'rust_analyzer', 'eslint'},
    handlers = {
        lsp.default_setup,
        lua_ls = function()
            -- (Optional) Configure lua language server for neovim
            require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
        end,
    },
})

local cmp_action = require('lsp-zero').cmp_action()

lsp.on_attach(function(client, bufnr)
    print("LSP active")
    local opts = { buffer = bufnr, remap = false }
    -- lsp keymaps
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gD", function() vim.lsp.buf.implementation() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-i>", function() vim.lsp.buf.signature_help() end, opts)
end)
-- extend lsp to nvim-cmp
lsp.extend_cmp()



-- --------------------------------------------- --
-- --------------------------------------------- --
-- nvim-cmp configurations follow after lsp-zero --
-- --------------------------------------------- --
-- --------------------------------------------- --
local cmp = require("cmp")
local types = require("cmp.types")
local str = require("cmp.utils.str")

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local luasnip = require("luasnip")

-- Do not jump to snippet if i'm outside of it
-- https://github.com/L3MON4D3/LuaSnip/issues/78
luasnip.config.setup({
    region_check_events = "CursorMoved",
    delete_check_events = "TextChanged",
})

local lspkind = require("lspkind")

cmp.setup({
    -- formatings of nvim-cmp
    formatting = {
        fields = {
            cmp.ItemField.Kind,
            cmp.ItemField.Abbr,
            cmp.ItemField.Menu,
        },
        format = require('lspkind').cmp_format({
            mode = 'symbol',
            before = function(entry, vim_item)
                -- Get the full snippet (and only keep first line)
                local word = entry:get_insert_text()
                if entry.completion_item.insertTextFormat == types.lsp.InsertTextFormat.Snippet then
                    word = vim.lsp.util.parse_snippet(word)
                end
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
            else
                fallback()
            end
        end
        ),

        ["<C-k>"] = cmp.mapping(function(fallback)
            -- fallback() should release the key if completion is not visible
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior, count = 1 })
            else
                fallback()
            end
        end
        ),

        ["<Enter>"] = cmp.mapping(function(fallback)
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
        end
        ),

        ["<C-l>"] = cmp.mapping(function(fallback)
            -- fallback() should release the key if completion is not visible
            if cmp.visible() then
                if luasnip.expand_or_jumpable() then
                    vim.fn.feedkeys(t("<Plug>luasnip-expand-or-jump"), "")
                end
            else
                fallback()
            end
        end
        ),

        ["<C-h>"] = cmp.mapping(function(fallback)
            -- fallback() should release the key if completion is not visible
            if cmp.visible() then
                if luasnip.jumpable(-1) then
                    vim.fn.feedkeys(t("<Plug>luasnip-jump-prev"), "")
                end
            else
                fallback()
            end
        end
        ),

        ['<C-Space>'] = cmp.mapping(function(fallback)
            -- fallback() should release the key if completion is not visible
            if cmp.visible() then
                if cmp.visible_docs() then
                    cmp.close_docs()
                else
                    cmp.open_docs()
                end
            else
                fallback()
            end
        end
        ),

    },

    -- You should specify your *installed* sources.
    sources = {
        { name = "luasnip" },
        { name = "nvim_lsp" },
        { name = "buffer", keyword_length = 5, max_item_count = 5 },
        --{ name = "cmp_git" },
        --{ name = "path" },
        --{ name = "neorg" },
    },

    experimental = {
        -- dnt knw what this is..
        ghost_text = false,
    },
})


require("cmp").setup.cmdline(":", {
    sources = {
        { name = "cmdline", keyword_length = 2 },
    },
})


