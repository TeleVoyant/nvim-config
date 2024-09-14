require("hex").setup({
    -- cli command used to dump hex data
    dump_cmd = "xxd -g 1 -u",

    -- cli command used to assemble from hex data
    assemble_cmd = "xxd -r",

    -- function that runs on BufReadPre to determine if it's binary or not
    is_buf_binary_pre_read = function()
        -- logic that determines if a buffer contains binary data or not
        -- must return a bool
    end,

    -- function that runs on BufReadPost to determine if it's binary or not
    is_buf_binary_post_read = function()
        -- logic that determines if a buffer contains binary data or not
        -- must return a bool
    end,
})

---------------
-- Remappings--
---------------
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>hx", "<Cmd>HexToggle<CR>", opts)
vim.keymap.set("n", "<leader>hd", "<Cmd>HexDump<CR>", opts)
vim.keymap.set("n", "<leader>ha", "<Cmd>HexAssemble<CR>", opts)
