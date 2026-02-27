-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local lga_actions = require("telescope-live-grep-args.actions")

telescope.setup({
    extensions = {
        fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        },

        live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = { -- extend mappings
                i = {
                    ["<C-y>"] = lga_actions.quote_prompt(),
                    ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                    -- freeze the current list and start a fuzzy search in the frozen list
                    ["<C-space>"] = lga_actions.to_fuzzy_refine,
                },
            },
            -- ... also accepts theme settings, for example:
            -- theme = "dropdown", -- use dropdown theme
            -- theme = { }, -- use own theme spec
            -- layout_config = { mirror=true }, -- mirror preview pane
        },
    },
})
-- To get fzf, live_grep and others loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
telescope.load_extension("fzf")
telescope.load_extension("live_grep_args")

vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>fk", builtin.keymaps, {})
vim.keymap.set("n", "<leader>fp", builtin.git_files, {})
vim.keymap.set("n", "<leader>fG", function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
