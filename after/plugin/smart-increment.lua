require("smart-increment").setup({
    register = '"', -- register to track (default: unnamed)
    linewise_paste = false, -- force linewise paste (default: follows register type)
    similarity_threshold = 0.5, -- similarity threshold for Search & replace (default: 0.5)
    sr_multi_report = false, -- true to show detailed report after S&R multi
    keymaps = {
        increment_paste = "<leader>ss", -- set to false to disable
        reset = "<leader>sS", -- set to false to disable
    },
})
