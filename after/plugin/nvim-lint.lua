local lint = require("lint")

lint.linters_by_ft = {
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
    svelte = { "eslint_d" },
    python = { "pylint", "ruff", "bandit" },
    cpp = { "cpplint" },
    c = { "cpplint" },
    vim = { "vint" },
    php = { "phpstan", "phpcs" },
    yaml = { "yamllint" },
    html = { "htmlhint" },
    sh = { "shellcheck" },
    solidity = { "solhint" },
    env = { "dotenv-linter" },
    dart = { "dcm" },
}

-- SPECIAL CASE (PYLINT IS ANNOYING) --
lint.linters.pylint = require("lint.util").wrap(lint.linters.pylint, function(diagnostic)
    diagnostic.severity = vim.diagnostic.severity.HINT
    return diagnostic
end)

vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
    callback = function()
        -- try_lint without arguments runs the linters defined in `linters_by_ft`
        lint.try_lint()
    end,
})
