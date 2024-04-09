local lint = require("lint")

lint.linters_by_ft = {
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
    svelte = { "eslint_d" },
    python = { "pylint" },
    cpp = { "cpplint" },
    c = { "cpplint" },
    vim = { "vint" },
}

vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
    callback = function()
        -- try_lint without arguments runs the linters defined in `linters_by_ft`
        lint.try_lint()
    end,
})
