require("color-picker").setup({ -- for changing icons & mappings
    -- ["icons"] = { "ﱢ", "" },
    -- ["icons"] = { "ﮊ", "" },
    -- ["icons"] = { "", "ﰕ" },
    -- ["icons"] = { "", "" },
    -- ["icons"] = { "", "" },
    ["icons"] = { "ﱢ", "" },
    ["border"] = "rounded", -- none | single | double | rounded | solid | shadow
    ["keymap"] = { -- mapping example:
        ["U"] = "<Plug>ColorPickerSlider5Decrease",
        ["O"] = "<Plug>ColorPickerSlider5Increase",
    },
    ["background_highlight_group"] = "Normal", -- default
    ["border_highlight_group"] = "FloatBorder", -- default
    ["text_highlight_group"] = "Normal", --default
})

-- if you don't want weird border background colors around the popup.
vim.cmd([[hi FloatBorder guibg=NONE]])

-- ------------------- --
-- remappings for this --
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>pc", "<cmd>PickColor<cr>", opts)
-- ------------------- --
