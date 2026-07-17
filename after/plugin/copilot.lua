local status, copilot = pcall(require, "copilot")
if not status then
    return
end

copilot.setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
    copilot_model = "gpt-41-copilot",

    nes = {
        enabled = true,
        keymap = {
            accept_and_goto = "<leader>ac",
            accept = false,
            dismiss = "<Esc>",
        },
    },
})
