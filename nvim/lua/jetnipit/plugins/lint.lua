return {
    "mfussenegger/nvim-lint",
    events = { "BufWritePost", "BufReadPre", "InsertLeave" },
    config = function()
        local lint_config = require("lint")

        vim.g.lint_log_level = "debug"

        lint_config.linters_by_ft = {
            javascript = { "eslint", "cspell" },
            typescript = { "eslint", "cspell" },
            javascriptreact = { "eslint", "cspell" },
            typescriptreact = { "eslint", "cspell" },
            lua = { "cspell" },
            svelte = { "eslint", "cspell" },
            python = { "pylint", "cspell" },
            go = { "golangcilint", "cspell" },
            markdown = { "markdownlint-cli2", "cspell" }
        }

        lint_config.linters.cspell = require("lint.util").wrap(lint_config.linters.cspell, function(diagnostic)
            diagnostic.severity = vim.diagnostic.severity.HINT
            return diagnostic
        end)

        lint_config.linters.golangcilint.args = {
            "run",
            "--out-format=json",
            "--show-stats=false",
            "--print-issued-lines=false",
            "--print-linter-name=false",
            "--presets=bugs,error,format,style,performance,sql",
            "--disable=gochecknoglobals,importas,paralleltest,gci,depguard,tagliatelle,mnd",
            function()
                return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
            end,
        }

        vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
            callback = function()
                require('lint').try_lint()
            end,
        })
    end,
    keys = {
        {
            "<leader>cl",
            function()
                local bufnr = vim.api.nvim_get_current_buf()
                if vim.api.nvim_buf_is_valid(bufnr) then
                    if vim.diagnostic.is_enabled() then
                        vim.diagnostic.enable(false)
                    else
                        vim.diagnostic.enable(true)
                    end
                end
            end,
            desc = "Lint",
        },
    },
}
