
local highlight = {
    "iblIndent1",
    "iblIndent2",
    "iblIndent3",
    "iblIndent4",
    "iblIndent5",
    "iblIndent6",
    "iblIndent7",
    "iblIndent8",
    "iblIndent9",
    "iblIndent10",
    "iblIndent11",
    "iblIndent12",
    "iblIndent13",
    "iblIndent14",
    "iblIndent15",
    "iblIndent16",
}
local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "iblIndent1", { fg = "#4d0000" })
    vim.api.nvim_set_hl(0, "iblIndent2", { fg = "#4d3300" })
    vim.api.nvim_set_hl(0, "iblIndent3", { fg = "#1a4d1a" })
    vim.api.nvim_set_hl(0, "iblIndent4", { fg = "#003333" })
    vim.api.nvim_set_hl(0, "iblIndent5", { fg = "#003366" })
    vim.api.nvim_set_hl(0, "iblIndent6", { fg = "#330033" })
    vim.api.nvim_set_hl(0, "iblIndent7", { fg = "#00004d" })
    vim.api.nvim_set_hl(0, "iblIndent8", { fg = "#004d4d" })
    vim.api.nvim_set_hl(0, "iblIndent9", { fg = "#003300" })
    vim.api.nvim_set_hl(0, "iblIndent10", { fg = "#4d4d1a" })
    vim.api.nvim_set_hl(0, "iblIndent11", { fg = "#4d1a33" })
    vim.api.nvim_set_hl(0, "iblIndent12", { fg = "#003366" })
    vim.api.nvim_set_hl(0, "iblIndent13", { fg = "#330000" })
    vim.api.nvim_set_hl(0, "iblIndent14", { fg = "#000033" })
    vim.api.nvim_set_hl(0, "iblIndent15", { fg = "#004d4d" })
    vim.api.nvim_set_hl(0, "iblIndent16", { fg = "#003300" })
end)

vim.g.rainbow_delimiters = { highlight = highlight }
require("ibl").setup {
    indent = {
        char = "ᐧ"
    },
    scope = {
        highlight = highlight
    }
}

hooks.register(
hooks.type.SCOPE_HIGHLIGHT,
hooks.builtin.scope_highlight_from_extmark
)

