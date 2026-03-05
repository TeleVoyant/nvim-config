local codecompanion = require("codecompanion")

-- ---------------------------------------- --
-- -- CODECOMPANION - FIDGET INTEGRATION -- --
-- Fidget doesn't have a built-in way to
-- listen to custom events, so we use
-- Neovim's autocmd system to update the progress
-- based on CodeCompanion's events.
-- We create a single fidget task that we update as
-- CodeCompanion sends events about the request status.
-- When the request finishes, we complete the fidget task.
local progress = require("fidget.progress")
local handles = {}

vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanion*",
    group = vim.api.nvim_create_augroup("CodeCompanionFidget", { clear = true }),
    callback = function(e)
        local data = e.data or {}
        local id = data.id

        -- Events that don't have an id use bufnr as fallback
        local key = id or data.bufnr or "global"

        local event = e.match:gsub("^CodeCompanion", "")

        if e.match == "CodeCompanionRequestStarted" then
            local a = data.adapter or {}
            local adapter_name = a.formatted_name or a.name or "Unknown"
            local model = a.model or "default"

            handles[key] = {
                handle = progress.handle.create({
                    title = adapter_name .. " (" .. model .. ")",
                    message = "󱜚  Request started",
                    lsp_client = { name = "CodeCompanion" },
                }),
                events = { "RequestStarted" },
                strategy = data.strategy or "chat",
                adapter = adapter_name,
                model = model,
                start_time = vim.uv.hrtime(),
            }
        elseif e.match == "CodeCompanionRequestStreaming" then
            local h = handles[key]
            if h then
                table.insert(h.events, "Streaming")
                h.handle.message = "󱜚  󰔰  Streaming response..."
            end
        elseif e.match == "CodeCompanionRequestFinished" then
            local h = handles[key]
            if h then
                table.insert(h.events, "Finished")
                local elapsed = h.start_time and string.format("%.1fs", (vim.uv.hrtime() - h.start_time) / 1e9) or ""
                local status_icon = data.status == "success" and "" or data.status == "error" and "" or "󰜺"
                local status_text = data.status == "success" and "Complete"
                    or data.status == "error" and "Error"
                    or "Cancelled"

                h.handle.title = h.adapter .. " (" .. h.model .. ") • " .. h.strategy
                h.handle.message = status_icon
                    .. " "
                    .. status_text
                    .. " in "
                    .. elapsed
                    .. " Events: "
                    .. table.concat(h.events, " → ")
                h.handle:finish()
                handles[key] = nil
            end
        elseif e.match == "CodeCompanionRequestError" then
            local h = handles[key]
            if h then
                table.insert(h.events, "Error")
                local status_icon = data.status == "error" and "" or "󰜺"
                local err_msg = data.error or "Unknown error"
                h.handle.title = h.adapter .. " (" .. h.model .. ") • " .. h.strategy
                h.handle.message = status_icon .. "  " .. err_msg .. " Events: " .. table.concat(h.events, " → ")
                vim.defer_fn(function()
                    if handles[key] then
                        h.handle:finish()
                        handles[key] = nil
                    end
                end, 3000)
            end

        -- Track other CodeCompanion events for visibility
        elseif e.match == "CodeCompanionChatCreated" then
            local h = handles[key]
            if h then
                table.insert(h.events, "ChatCreated")
            end
        elseif e.match == "CodeCompanionChatSubmitted" then
            local h = handles[key]
            if h then
                table.insert(h.events, "Submitted")
                h.handle.message = "󰸇  Submitting..."
            end
        elseif e.match == "CodeCompanionInlineStarted" then
            local h = handles[key]
            if h then
                table.insert(h.events, "InlineStarted")
                h.handle.message = "󰧮  󰔰  󱜚  Inline transformation..."
            end
        elseif e.match == "CodeCompanionInlineFinished" then
            local h = handles[key]
            if h then
                table.insert(h.events, "InlineFinished")
            end
        elseif e.match == "CodeCompanionAgentStarted" then
            local h = handles[key]
            if h then
                table.insert(h.events, "AgentStarted")
                h.handle.message = "󱜚  󰔰    Agent working..."
            end
        elseif e.match == "CodeCompanionToolExecuting" then
            local h = handles[key]
            if h then
                local tool_name = data.tool or "tool"
                table.insert(h.events, "Tool:" .. tool_name)
                h.handle.message = "󱜚  󰔰  󱑟  Executing " .. tool_name .. "..."
            end
        end
    end,
})
-- ---------------------------------------- --

-- --------------------------------- --
-- ---- CONFIGURE CODECOMPANION ---- --
-- This is a basic configuration that
-- sets up the Copilot adapter (separate)
-- and codecompanion-history extension (built-in).
codecompanion.setup({
    adapters = {
        copilot = function()
            return require("codecompanion.adapters").extend("copilot", {})
        end,
    },
    strategies = {
        chat = { adapter = "copilot", model = "gpt-4o" },
        inline = { adapter = "copilot", model = "gpt-4o" },
    },
    opts = {
        log_level = "DEBUG",
    },
    extensions = {
        mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
                make_vars = true,
                make_slash_commands = true,
                show_result_in_chat = true,
            },
        },
        history = {
            enabled = true,
            opts = {
                -- Keymap to open history from chat buffer (default: gh)
                keymap = "<leader>M",
                -- Keymap to save the current chat manually (when auto_save is disabled)
                save_chat_keymap = "<leader>Ms",
                -- Save all chats by default (disable to save only manually using 'sc')
                auto_save = true,
                -- Number of days after which chats are automatically deleted (0 to disable)
                expiration_days = 0,
                -- Picker interface (auto resolved to a valid picker)
                picker = "telescope", --- ("telescope", "snacks", "fzf-lua", or "default")
                ---Optional filter function to control which chats are shown when browsing
                chat_filter = nil, -- function(chat_data) return boolean end
                -- Customize picker keymaps (optional)
                picker_keymaps = {
                    rename = { n = "r", i = "<M-r>" },
                    delete = { n = "d", i = "<M-d>" },
                    duplicate = { n = "<C-y>", i = "<C-y>" },
                },
                ---Automatically generate titles for new chats
                auto_generate_title = true,
                title_generation_opts = {
                    ---Adapter for generating titles (defaults to current chat adapter)
                    adapter = nil, -- "copilot"
                    ---Model for generating titles (defaults to current chat model)
                    model = nil, -- "gpt-4o"
                    ---Number of user prompts after which to refresh the title (0 to disable)
                    refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
                    ---Maximum number of times to refresh the title (default: 3)
                    max_refreshes = 3,
                    format_title = function(original_title)
                        -- this can be a custom function that applies some custom
                        -- formatting to the title.
                        return original_title
                    end,
                },
                ---On exiting and entering neovim, loads the last chat on opening chat
                continue_last_chat = false,
                ---When chat is cleared with `gx` delete the chat from history
                delete_on_clearing_chat = false,
                ---Directory path to save the chats
                dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
                ---Enable detailed logging for history extension
                enable_logging = false,

                -- Summary system
                summary = {
                    -- Keymap to generate summary for current chat (default: "gcs")
                    create_summary_keymap = "gcs",
                    -- Keymap to browse summaries (default: "gbs")
                    browse_summaries_keymap = "gbs",

                    generation_opts = {
                        adapter = nil, -- defaults to current chat adapter
                        model = nil, -- defaults to current chat model
                        context_size = 90000, -- max tokens that the model supports
                        include_references = true, -- include slash command content
                        include_tool_outputs = true, -- include tool execution results
                        system_prompt = nil, -- custom system prompt (string or function)
                        format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
                    },
                },

                -- Memory system (requires VectorCode CLI)
                memory = {
                    -- Automatically index summaries when they are generated
                    auto_create_memories_on_summary_generation = true,
                    -- Path to the VectorCode executable
                    vectorcode_exe = "vectorcode",
                    -- Tool configuration
                    tool_opts = {
                        -- Default number of memories to retrieve
                        default_num = 10,
                    },
                    -- Enable notifications for indexing progress
                    notify = true,
                    -- Index all existing memories on startup
                    -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
                    index_on_startup = false,
                },
            },
        },
    },
})

-- dedicated keymaps for codecompanion actions and chat
-- sacrificed key `m` for "m"odel and "m"enu, but it felt appropriate
vim.keymap.set({ "n", "v" }, "<C-m>", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<S-m>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>m", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "gm", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
-- --------------------------------- --
