require("conform").setup({
    -- Map of filetype to formatters
    formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        lua = { "stylua" },
        python = { "isort", "black" },
        go = { "goimports", "gofmt" },
        cpp = { "clang-format" },
        c = { "clang-format" },
        java = { "clang-format" },
        php = { "phpcbf" },
        -- Use the "*" filetype to run formatters on all filetypes.
        ["*"] = { "trim_whitespace" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        -- ["_"] = { "trim_whitespace" },
    },
    -- If this is set, Conform will run the formatter asynchronously after save.
    -- It will pass the table to conform.format().
    -- This can also be a function that returns the table.
    format_after_save = {
        lsp_fallback = true,
    },
    -- Conform will notify you when a formatter errors
    notify_on_error = true,
})
