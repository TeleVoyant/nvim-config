local neogen = require("neogen")

neogen.setup({
    -- Enables Neogen capabilities
    enabled = true,

    -- Go to annotation after insertion, and change to insert mode
    input_after_comment = true,

    -- Configuration for default languages
    -- languages = {},

    -- Use a snippet engine to generate annotations.
    snippet_engine = "luasnip",

    -- Enables placeholders when inserting annotation
    enable_placeholders = true,

    -- Placeholders used during annotation expansion
    placeholders_text = {
        ["description"] = "[TODO:description]",
        ["tparam"] = "[TODO:tparam]",
        ["parameter"] = "[TODO:parameter]",
        ["return"] = "[TODO:return]",
        ["class"] = "[TODO:class]",
        ["throw"] = "[TODO:throw]",
        ["varargs"] = "[TODO:varargs]",
        ["type"] = "[TODO:type]",
        ["attribute"] = "[TODO:attribute]",
        ["args"] = "[TODO:args]",
        ["kwargs"] = "[TODO:kwargs]",
    },

    -- Placeholders highlights to use. If you don't want custom highlight, pass "None"
    placeholders_hl = "DiagnosticHint",
})

-- --- mappings for neogen --- --
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<Leader>nd", neogen.generate, opts)
