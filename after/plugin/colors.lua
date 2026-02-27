-- --------------------------- --
-- -- Auto-Dark-Mode Config -- --
-- --------------------------- --
require("auto-dark-mode").setup({
    update_interval = 300,
    set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        ColorMyPencils()
    end,
    set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        ColorMyPencils()
    end,
    fallback = "light",
})

-- --------------------------- --
-- ----- Rose-Pine Config ---- --
-- --------------------------- --
require("rose-pine").setup({
    disable_background = true,
    disable_float_background = false,

    -- force darktheme, as parrot does not support theme switching
    variant = "moon", -- auto, main, moon, or dawn
    dark_variant = "moon", -- main, moon, or dawn
    dim_inactive_windows = true,
    extend_background_behind_borders = true,

    enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
        migrations = true, -- Handle deprecated options automatically
    },

    styles = {
        bold = true,
        italic = true,
        transparency = true,
    },

    groups = {
        border = "muted",
        link = "iris",
        panel = "surface",

        error = "love",
        hint = "iris",
        info = "foam",
        note = "pine",
        todo = "rose",
        warn = "gold",

        git_add = "foam",
        git_change = "rose",
        git_delete = "love",
        git_dirty = "rose",
        git_ignore = "muted",
        git_merge = "iris",
        git_rename = "pine",
        git_stage = "iris",
        git_text = "rose",
        git_untracked = "subtle",

        h1 = "iris",
        h2 = "foam",
        h3 = "rose",
        h4 = "gold",
        h5 = "pine",
        h6 = "foam",
    },

    highlight_groups = {
        -- Comment = { fg = "foam" },
        StatusLine = { fg = "love", bg = "love", blend = 5 },
        -- VertSplit = { fg = "muted", bg = "muted" },
        -- Visual = { fg = "base", bg = "text", inherit = false },
    },

    before_highlight = function(group, highlight, palette)
        -- Disable all undercurls
        -- if highlight.undercurl then
        --     highlight.undercurl = false
        -- end
        --
        -- Change palette colour
        -- if highlight.fg == palette.pine then
        --     highlight.fg = palette.foam
        -- end
    end,
})

-- Gets called from the packer plugin initalizer
function ColorMyPencils(color)
    color = color or "rose-pine"
    vim.cmd.colorscheme(color)

    -- i know i should throw these into lsp.lua, but they work flawless here!
    -- got no time to figure out why. if it works, dont touch it.
    vim.api.nvim_set_hl(0, "CmpItemKind", { fg = "#c678dd" })
    vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#e06c75" })
    vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = "#e5c07b" })
    vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#56b6c2" })
    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
end

ColorMyPencils()
