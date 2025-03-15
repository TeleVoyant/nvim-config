local dap = require("dap")
local dapui = require("dapui")
local dapVT = require("nvim-dap-virtual-text")
local dapGo = require("dap-go")
local dapPython = require("dap-python")
-- local nio = require("nio")

-- setup dap ui
dapui.setup()

-- setup nio
-- nio.run()

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

    -- ---------- CUSTOM FUNCTION --------------- --
    -- This just tries to mitigate the chance that I leak secret tokens while streaming.
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
    -- --------------------------------------- --

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
-- dapui.float_element({ { "width", 50 }, { "height", "30" } })

--------------------------------------------
-- -------- keymaps are set here -------- --
--------------------------------------------
vim.keymap.set("n", "<leader>tb", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>tB", dap.set_breakpoint)
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
vim.keymap.set({ "n", "v" }, "<Leader>th", function()
    require("dap.ui.widgets").hover()
end)
vim.keymap.set({ "n", "v" }, "<Leader>tp", function()
    require("dap.ui.widgets").preview()
end)
vim.keymap.set("n", "<Leader>tf", function()
    local widgets = require("dap.ui.widgets")
    widgets.centered_float(widgets.frames)
end)
vim.keymap.set("n", "<Leader>ts", function()
    local widgets = require("dap.ui.widgets")
    widgets.centered_float(widgets.scopes)
end)
-- -------------------------------------- --

-- -------------------------------------- --
-- ----- PER-LANGUAGE DEBUG ADAPTERS ---- --
-- -------------------------------------- --

-- ---------------------------------- --
-- ---- Python DAP configuration ---- --
dapPython.setup("python")
-- If using the above, then `python -m debugpy --version` must work in the shell

-- ---------------------------------- --
-- ---- Golang DAP configuration ---- --
dapGo.setup({
    -- Additional dap configurations can be added.
    -- dap_configurations accepts a list of tables where each entry
    -- represents a dap configuration. For more details do:
    -- :help dap-configuration
    dap_configurations = {
        {
            -- Must be "go" or it will be ignored by the plugin
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
        },
    },
    -- delve configurations
    delve = {
        -- the path to the executable dlv which will be used for debugging.
        -- by default, this is the "dlv" executable on your PATH.
        path = "dlv",
        -- time to wait for delve to initialize the debug session.
        -- default to 20 seconds
        initialize_timeout_sec = 20,
        -- a string that defines the port to start delve debugger.
        -- default to string "${port}" which instructs nvim-dap
        -- to start the process in a random available port.
        -- if you set a port in your debug configuration, its value will be
        -- assigned dynamically.
        port = "${port}",
        -- additional args to pass to dlv
        args = {},
        -- the build flags that are passed to delve.
        -- defaults to empty string, but can be used to provide flags
        -- such as "-tags=unit" to make sure the test suite is
        -- compiled during debugging, for example.
        -- passing build flags using args is ineffective, as those are
        -- ignored by delve in dap mode.
        -- avaliable ui interactive function to prompt for arguments get_arguments
        build_flags = {},
        -- whether the dlv process to be created detached or not. there is
        -- an issue on Windows where this needs to be set to false
        -- otherwise the dlv server creation will fail.
        -- avaliable ui interactive function to prompt for build flags: get_build_flags
        detached = vim.fn.has("win32") == 0,
        -- the current working directory to run dlv from, if other than
        -- the current working directory.
        cwd = nil,
    },
    -- options related to running closest test
    tests = {
        -- enables verbosity when running the test.
        verbose = false,
    },
})

-- ------------------------- --
-- --- PHP debug adapter --- --
dap.adapters.php = {
    type = "executable",
    command = "node",
    args = { "~/.local/share/nvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
}
dap.configurations.php = {
    {
        type = "php",
        request = "launch",
        name = "Listen for Xdebug",
        port = 9000,
    },
}

-- ---------------------------- --
-- --- Elixir debug adapter --- --
dap.adapters.mix_task = {
    type = "executable",
    command = "~/.local/share/nvim/mason/packages/elixir-ls/debug_adapter.sh", -- debug_adapter.bat for windows
    args = {},
}
dap.configurations.elixir = {
    {
        type = "mix_task",
        name = "mix test",
        task = "test",
        taskArgs = { "--trace" },
        request = "launch",
        startApps = true, -- for Phoenix projects
        projectDir = "${workspaceFolder}",
        requireFiles = {
            "test/**/test_helper.exs",
            "test/**/*_test.exs",
        },
    },
}

-- ------------------------------------------ --
-- --- C/C++/Rust debug adapter (via GDB) --- --
dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "-i", "dap" },
}
dap.configurations.c = {
    {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
    },
}

-- -------------------------- --
-- --- Bash debug adapter --- --
dap.adapters.bashdb = {
    type = "executable",
    command = vim.fn.stdpath("data") .. "~/.local/share/nvim/mason/packages/bash-debug-adapter/bash-debug-adapter",
    name = "bashdb",
}
dap.configurations.sh = {
    {
        type = "bashdb",
        request = "launch",
        name = "Launch file",
        showDebugOutput = true,
        pathBashdb = vim.fn.stdpath("data")
            .. "~/.local/share/nvim/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
        pathBashdbLib = vim.fn.stdpath("data")
            .. "~/.local/share/nvim/mason/packages/bash-debug-adapter/extension/bashdb_dir",
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        env = {},
        terminalKind = "integrated",
    },
}

-- ---------------------------- --
-- ---- Dart debug adapter ---- --
dap.configurations.dart = {
    {
        type = "dart",
        request = "launch",
        name = "Launch dart",
        dartSdkPath = "/run/current-system/sw/bin/dart", -- ensure this is correct
        flutterSdkPath = "/run/current-system/sw/bin/flutter", -- ensure this is correct
        program = "${workspaceFolder}/lib/main.dart", -- ensure this is correct
        cwd = "${workspaceFolder}",
    },
    {
        type = "flutter",
        request = "launch",
        name = "Launch flutter",
        dartSdkPath = "/run/current-system/sw/bin/dart", -- ensure this is correct
        flutterSdkPath = "/run/current-system/sw/bin/flutter", -- ensure this is correct
        program = "${workspaceFolder}/lib/main.dart", -- ensure this is correct
        cwd = "${workspaceFolder}",
    },
}

-- ---------------------------- --
-- ---- Java debug adapter ---- --
-- dap.adapters.java = function(callback)
--     -- FIXME:
--     -- Here a function needs to trigger the `vscode.java.startDebugSession` LSP command
--     -- The response to the command must be the `port` used below
--     callback({
--         type = "server",
--         host = "127.0.0.1",
--         port = port,
--     })
-- end
-- dap.configurations.java = {
--     {
--         -- You need to extend the classPath to list your dependencies.
--         -- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
--         classPaths = {},
--
--         -- If using multi-module projects, remove otherwise.
--         projectName = "yourProjectName",
--
--         javaExec = "/path/to/your/bin/java",
--         mainClass = "your.package.name.MainClassName",
--
--         -- If using the JDK9+ module system, this needs to be extended
--         -- `nvim-jdtls` would automatically populate this property
--         modulePaths = {},
--         name = "Launch YourClassName",
--         request = "launch",
--         type = "java",
--     },
-- }
