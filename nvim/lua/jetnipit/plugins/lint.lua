return {
  "mfussenegger/nvim-lint",
  events = { "BufWritePost", "BufReadPre", "InsertLeave" },
  config = function()
    local lintconfig = require("lint")

    vim.g.lint_log_level = "debug"


    lintconfig.linters_by_ft = {
      javascript = { "eslint" },
      typescript = { "eslint" },
      javascriptreact = { "eslint" },
      typescriptreact = { "eslint" },
      svelte = { "eslint" },
      python = { "pylint" },
      go = { "golangcilint" },
      markdown = { "markdownlint-cli2" }
    }

    lintconfig.linters.golangcilint.args = {
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

    vim.api.nvim_create_user_command("Spellfile", function() vim.cmd.edit(vim.opt.spellfile) end, {
      desc = "open the spellfile for me to edit",
    })
    lintconfig.linters.codespell.args = {
      "--ignore-words=" .. vim.fn.stdpath('config') .. "/spell/en.utf-8.add",
      "--stdin-single-line",
      "-",
    }

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufReadPre", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("RunLinter", { clear = true }),
      callback = function()
        lintconfig.try_lint("codespell")
      end,
    })
  end,
  keys = {
    {
      "<leader>cl",
      function()
        if vim.diagnostic.is_enabled() then
          vim.diagnostic.enable(false)
        else
          vim.diagnostic.enable(true)
        end
      end,
      desc = "Lint",
    },
  },
}
