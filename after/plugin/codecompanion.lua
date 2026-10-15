-- CodeCompanion.nvim - Z.ai, DeepSeek, ChatGPT Codex ACP, optional Claude ACP
-- Fill in the two keys below. No shell environment variables required.
-- Keep this file PRIVATE: never commit a file containing real API keys.
-- Codex uses ChatGPT login, NOT your OpenAI API key.

-- ================== PASTE YOUR API KEYS HERE ================== --
local ZAI_API_KEY = "PASTE_YOUR_ZAI_KEY_HERE"
local DEEPSEEK_API_KEY = "PASTE_YOUR_DEEPSEEK_KEY_HERE"

-- Z.ai: "standard" for regular pay-as-you-go API;
--       "coding" only if your key has access to the GLM Coding Plan.
local ZAI_API_MODE = "standard"

-- Optional for a supported Claude Code ACP subscription workflow.
-- Leave blank if you are not using it.
local CLAUDE_CODE_OAUTH_TOKEN = ""
-- =============================================================== --

local codecompanion = require("codecompanion")
local adapters = require("codecompanion.adapters")

-- Adjust these two values if you want different launch defaults.
-- ACP cannot be used for inline requests, so inline always uses HTTP.
local DEFAULT_CHAT_ADAPTER = "codex"
local DEFAULT_INLINE_ADAPTER = "zai"

-- Distinct endpoint paths prevent Coding Plan and standard API mixups.
local zai_mode = ZAI_API_MODE
if zai_mode ~= "standard" and zai_mode ~= "coding" then
    error("Invalid ZAI_API_MODE: expected 'standard' or 'coding'")
end
local zai_prefix = zai_mode == "coding" and "/api/coding/paas/v4" or "/api/paas/v4"

-- ---------------------------------------- --
-- -- CODECOMPANION - FIDGET INTEGRATION -- --
-- Uses the request ID whenever possible to avoid mixing concurrent requests.
-- Current CodeCompanion event: data.interaction (rather than data.strategy).
local ok_fidget, progress = pcall(require, "fidget.progress")
if ok_fidget then
    local handles = {}

    local function event_key(e)
        local data = e.data or {}
        return data.id or data.bufnr or e.buf or "global"
    end

    local function add_event(h, name)
        if h and #h.events < 30 then
            table.insert(h.events, name)
        end
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanion*",
        group = vim.api.nvim_create_augroup("CodeCompanionFidget", { clear = true }),
        callback = function(e)
            local data = e.data or {}
            local key = event_key(e)
            local event = e.match
            local h = handles[key]

            if event == "CodeCompanionRequestStarted" then
                -- Do not leave a previous task dangling when an ID is reused.
                if h then
                    h.handle:finish()
                end

                local adapter = data.adapter or {}
                local adapter_name = tostring(adapter.formatted_name or adapter.name or "Unknown")
                local model = adapter.model or "agent/default"
                if type(model) ~= "string" and type(model) ~= "number" then
                    model = "agent/default"
                end
                model = tostring(model)
                local interaction = tostring(data.interaction or data.strategy or "chat")
                handles[key] = {
                    handle = progress.handle.create({
                        title = adapter_name .. " (" .. model .. ")",
                        message = "󱜚  Request started",
                        lsp_client = { name = "CodeCompanion" },
                    }),
                    events = { "RequestStarted" },
                    interaction = interaction,
                    adapter = adapter_name,
                    model = model,
                    start_time = vim.uv.hrtime(),
                }
                return
            end

            if not h then
                return
            end

            if event == "CodeCompanionRequestStreaming" then
                if not h.streaming then
                    add_event(h, "Streaming")
                    h.streaming = true
                end
                h.handle.message = "󱜚  󰔰  Streaming response..."
            elseif event == "CodeCompanionRequestFinished" then
                add_event(h, "Finished")
                local elapsed = string.format("%.1fs", (vim.uv.hrtime() - h.start_time) / 1e9)
                local status = tostring(data.status or "success")
                local icon = status == "success" and "" or status == "error" and "" or "󰜺"
                local label = status == "success" and "Complete"
                    or status == "error" and "Error"
                    or "Finished (" .. status .. ")"
                h.handle.title = h.adapter .. " (" .. h.model .. ") • " .. h.interaction
                h.handle.message = icon
                    .. " "
                    .. label
                    .. " in "
                    .. elapsed
                    .. " Events: "
                    .. table.concat(h.events, " → ")
                h.handle:finish()
                handles[key] = nil

            -- Compatibility with older integrations emitting this event.
            elseif event == "CodeCompanionRequestError" then
                add_event(h, "Error")
                local err_msg = tostring(data.error or "Unknown error")
                h.handle.message = "  " .. err_msg:sub(1, 180)
                h.handle:finish()
                handles[key] = nil
            elseif event == "CodeCompanionChatSubmitted" then
                add_event(h, "Submitted")
                h.handle.message = "󰸇  Submitting..."
            elseif event == "CodeCompanionInlineStarted" then
                add_event(h, "InlineStarted")
                h.handle.message = "󰧮  󰔰  Inline transformation..."
            elseif event == "CodeCompanionInlineFinished" then
                add_event(h, "InlineFinished")
            elseif event == "CodeCompanionToolStarted" or event == "CodeCompanionToolExecuting" then
                local tool = data.tool
                local tool_name = type(tool) == "table" and (tool.name or tool.id)
                    or type(tool) == "string" and tool
                    or "tool"
                tool_name = tostring(tool_name)
                add_event(h, "Tool:" .. tool_name)
                h.handle.message = "󱜚  󰔰  󱑟  Executing " .. tool_name .. "..."
            elseif event == "CodeCompanionToolFinished" then
                add_event(h, "ToolFinished")
            end
        end,
    })
end
-- ---------------------------------------- --

-- --------------------------------- --
-- ---- CONFIGURE CODECOMPANION ---- --
codecompanion.setup({
    adapters = {
        http = {
            -- Keep the previous Copilot provider available if authenticated.
            copilot = function()
                return adapters.extend("copilot", {})
            end,

            -- Z.ai: either standard paid API or Coding Plan, selected via env.
            -- Static choices prevent accidentally querying an incompatible
            -- /models endpoint or borrowing another provider's cached models.
            zai = function()
                return adapters.extend("openai_compatible", {
                    name = "zai",
                    formatted_name = "Z.ai GLM (" .. zai_mode .. ")",
                    env = {
                        -- Function returns the literal key, not an env var name.
                        api_key = function()
                            return ZAI_API_KEY
                        end,
                        url = "https://api.z.ai",
                        chat_url = zai_prefix .. "/chat/completions",
                        models_endpoint = zai_prefix .. "/models",
                    },
                    opts = {
                        stream = true,
                        tools = true,
                        -- Image input support varies by GLM model/endpoint.
                        vision = false,
                    },
                    schema = {
                        model = {
                            default = "glm-5.3-flash",
                            choices = { "glm-5.3-flash", "glm-5.3", "glm-5.2" },
                        },
                    },
                })
            end,

            -- The native DeepSeek adapter knows its reasoning/tool protocol.
            -- DeepSeek V4.1 Flash's current public model ID is deepseek-flash.
            deepseek = function()
                return adapters.extend("deepseek", {
                    env = {
                        api_key = function()
                            return DEEPSEEK_API_KEY
                        end,
                    },
                    schema = {
                        model = {
                            default = "deepseek-flash",
                            choices = {
                                ["deepseek-flash"] = {
                                    formatted_name = "DeepSeek V4.1 Flash",
                                    meta = { context_window = 1048576 },
                                    opts = { can_reason = true, can_use_tools = true },
                                },
                            },
                        },
                        -- Low-cost default for short questions and history titles.
                        -- Can be enabled per chat via the debug/model options.
                        ["thinking.type"] = { default = "disabled" },
                    },
                })
            end,
        },

        acp = {
            extend = {
                -- ChatGPT subscription: NO OpenAI API key required.
                codex = {
                    defaults = {
                        auth_method = "chat-gpt",
                        -- Agent itself picks a supported default model.
                    },
                    env = {
                        -- Built-in Codex preset defaults to OPENAI_API_KEY.
                        -- When unset, CodeCompanion may forward that *literal*
                        -- text as a key. Override it, and any inherited key,
                        -- so codex-acp uses the ChatGPT login instead.
                        OPENAI_API_KEY = "",
                        CODEX_API_KEY = "",
                    },
                },

                -- Optional: install claude-agent-acp and authenticate using
                -- a permitted Claude Agent SDK subscription credential.
                -- Explicitly avoid forwarding the literal string
                -- "CLAUDE_CODE_OAUTH_TOKEN" if the token is absent.
                claude_code = {
                    env = {
                        CLAUDE_CODE_OAUTH_TOKEN = function()
                            return CLAUDE_CODE_OAUTH_TOKEN ~= "" and CLAUDE_CODE_OAUTH_TOKEN
                                or (vim.env.CLAUDE_CODE_OAUTH_TOKEN or "")
                        end,
                    },
                },
            },
        },
    },

    interactions = {
        -- Compaction and built-in background tasks need an HTTP adapter.
        background = { adapter = "deepseek" },
        chat = { adapter = DEFAULT_CHAT_ADAPTER },
        inline = { adapter = DEFAULT_INLINE_ADAPTER },
        -- Command generation is an HTTP interaction as well.
        cmd = { adapter = "deepseek" },
    },

    opts = {
        -- Avoid persisting sensitive request content in verbose DEBUG logs.
        -- Change to DEBUG temporarily when troubleshooting.
        log_level = "ERROR",
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
                keymap = "<leader>M",
                save_chat_keymap = "<leader>Ms",
                auto_save = true,
                expiration_days = 0,
                picker = "telescope",
                chat_filter = nil,
                picker_keymaps = {
                    rename = { n = "r", i = "<M-r>" },
                    delete = { n = "d", i = "<M-d>" },
                    duplicate = { n = "<C-y>", i = "<C-y>" },
                },
                auto_generate_title = true,
                title_generation_opts = {
                    -- ACP agents are not HTTP models. Use a cheap HTTP model
                    -- for background title generation rather than Codex/Claude.
                    adapter = "deepseek",
                    model = "deepseek-flash",
                    refresh_every_n_prompts = 0,
                    max_refreshes = 3,
                    format_title = function(original_title)
                        return original_title
                    end,
                },
                continue_last_chat = false,
                delete_on_clearing_chat = false,
                dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
                enable_logging = false,

                summary = {
                    create_summary_keymap = "gcs",
                    browse_summaries_keymap = "gbs",
                    generation_opts = {
                        adapter = "deepseek",
                        model = "deepseek-flash",
                        context_size = 90000,
                        include_references = true,
                        include_tool_outputs = true,
                        system_prompt = nil,
                        format_summary = nil,
                    },
                },

                memory = {
                    auto_create_memories_on_summary_generation = true,
                    vectorcode_exe = "vectorcode",
                    tool_opts = { default_num = 10 },
                    notify = true,
                    index_on_startup = false,
                },
            },
        },
    },
})

-- Original keymaps retained.
vim.keymap.set({ "n", "v" }, "<C-m>", "<cmd>CodeCompanion<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<S-m>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>m", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "gm", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line.
vim.cmd([[cab cc CodeCompanion]])
-- --------------------------------- --
