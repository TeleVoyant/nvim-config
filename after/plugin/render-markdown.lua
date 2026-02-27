require("render-markdown").setup({
    enabled = true,
    debounce = 100,

    file_types = {
        "markdown",
        "codecompanion",
        "codecompanion-chat",
        "codecompanion-output",
    },

    win_options = {
        conceallevel = {
            default = vim.api.nvim_get_option_value("conceallevel", {}),
            rendered = 3,
        },
        concealcursor = {
            default = vim.api.nvim_get_option_value("concealcursor", {}),
            rendered = "",
        },
    },
})
