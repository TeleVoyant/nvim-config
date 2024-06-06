local dap = require("dap")
local dapui = require("dapui")
local dapVT = require("nvim-dap-virtual-text")

-- setup dap ui
dapui.setup()

-- setup dap virtual text
dapVT.setup({
    enabled = true, -- enable this plugin (the default)
    enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    show_stop_reason = true, -- show stop reason when stopped for exceptions
    commented = false, -- prefix virtual text with comment string
    only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
    all_references = false, -- show virtual text on all all references of the variable (not only definitions)
    clear_on_continue = false, -- clear virtual text on "continue" (might cause flickering when stepping)
    --- A callback that determines how a variable is displayed or whether it should be omitted
    --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
    --- @param buf number
    --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
    --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
    --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
    --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed

    -- This just tries to mitigate the chance that I leak secret tokens here.
    display_callback = function(variable, buf, stackframe, node, options)
        local name = string.lower(variable.name)
        local value = string.lower(variable.value)
        if options.virt_text_pos == "inline" then
            if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
                return "*****"
            else
                if #variable.value > 15 then
                    return " " .. string.sub(variable.value, 1, 15) .. "... "
                else
                    return " = " .. value
                end
            end
        else
            if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
                return name .. " = " .. "*****"
            else
                if #variable.value > 15 then
                    return name .. " = " .. string.sub(value, 1, 15) .. "... "
                else
                    return name .. " = " .. value
                end
            end
        end
    end,

    -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
    virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",

    -- experimental features:
    all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
    virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
    -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
})

dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
end
dapui.float_element({ "width", 50 }, { "height", "30" })

--------------------------------------------
-- -------- keymaps are set here -------- --
--------------------------------------------
vim.keymap.set("n", "<leader>tb", dap.toogle_breakpoint)
vim.keymap.set("n", "<leader>tB", dap.toogle_breakpoint)
-- eval under cursor
vim.keymap.set("n", "<leader>T", function()
    dapui.eval(nil, { enter = true })
end)

vim.keymap.set("n", "<leader>tx", dap.step_back)
vim.keymap.set("n", "<leader>tc", dap.continue)
vim.keymap.set("n", "<leader>tv", dap.restart)
vim.keymap.set("n", "<leader>tn", dap.step_into)
vim.keymap.set("n", "<leader>tm", dap.step_over)
vim.keymap.set("n", "<leader>t,", dap.step_out)
