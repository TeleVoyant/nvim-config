local cloak = require("cloak")

cloak.setup({
    enabled = true,
    cloak_character = "⁑",
    -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
    highlight_group = "Comment",
    -- Applies the length of the replacement characters for all matched
    -- patterns, defaults to the length of the matched pattern.
    cloak_length = nil, -- Provide a number if you want to hide the true length of the value.
    -- Wether it should try every pattern to find the best fit or stop after the first.
    -- try_all_patterns = true,
    -- Set to true to cloak Telescope preview buffers. (Required feature not in 0.1.x)
    cloak_telescope = true,
    -- Re-enable cloak when a matched buffer leaves the window.
    cloak_on_leave = false,
    patterns = {
        {
            -- Match any file starting with '.env'.
            -- This can be a table to match multiple file patterns.
            file_pattern = { ".env*", ".yaml" },
            -- Match an equals sign and any character after it.
            -- This can also be a table of patterns to cloak,
            -- example: cloak_pattern = { ':.+', '-.+' } for yaml files.
            cloak_pattern = { "=.+", ":.+", "-.+" },
            -- A function, table or string to generate the replacement.
            -- The actual replacement will contain the 'cloak_character'
            -- where it doesn't cover the original text.
            -- If left emtpy the legacy behavior of keeping the first character is retained.
            replace = nil,
        },
    },
})

-- ------------------------ --
-- --- cloaking keymaps --- --
vim.keymap.set("n", "<leader>ct", cloak.toggle)
vim.keymap.set("n", "<leader>cp", cloak.uncloak_line)
