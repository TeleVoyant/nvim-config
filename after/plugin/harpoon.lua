local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function()
    harpoon:list():add()
end)
vim.keymap.set("n", "<leader>e", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<leader>t", function()
    harpoon:list():select(1)
end)
vim.keymap.set("n", "<leader>g", function()
    harpoon:list():select(2)
end)
vim.keymap.set("n", "<leader>b", function()
    harpoon:list():select(3)
end)

-- Toggle previous & next buffers stored within Harpoon list
-- vim.keymap.set("n", "<A-y>", function()
--     harpoon:list():prev()
-- end)
-- vim.keymap.set("n", "<A-n>", function()
--     harpoon:list():next()
-- end)
