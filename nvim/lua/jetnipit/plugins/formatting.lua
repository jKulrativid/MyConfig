-- Function to check for deno.json
local function has_deno_json()
    -- Get the current buffer's path
    local bufnr = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    -- Find the root directory
    local root = vim.fn.fnamemodify(filepath, ":p:h")
    while root ~= "/" do
        local deno_json = root .. "/deno.json"
        if vim.fn.filereadable(deno_json) == 1 then
            return true
        end
        root = vim.fn.fnamemodify(root, ":h")
    end
    return false
end

return {
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local conform = require("conform")

            conform.setup({
                formatters_by_ft = {
                    svelte = { "prettierd" },
                    css = { "prettierd" },
                    html = { "prettierd" },
                    json = { "prettierd" },
                    yaml = { "prettierd" },
                    markdown = { "prettierd" },
                    graphql = { "prettierd" },
                    liquid = { "prettierd" },
                    lua = { "stylua" },
                    go = { "goimports-reviser", "golines" },
                    python = { "isort", "black" },
                    javascript = function()
                        if has_deno_json() then
                            return { "deno_fmt" }
                        end
                        return { "prettierd" }
                    end,
                    javascriptreact = function()
                        if has_deno_json() then
                            return { "deno_fmt" }
                        end
                        return { "prettierd" }
                    end,
                    typescript = function()
                        if has_deno_json() then
                            return { "deno_fmt" }
                        end
                        return { "prettierd" }
                    end,
                    typescriptreact = function()
                        if has_deno_json() then
                            return { "deno_fmt" }
                        end
                        return { "prettierd" }
                    end,
                    c = { "clang_format" },
                    cpp = { "clang_format" },
                },
                formatters = {
                    goimports_reviser = {
                        command = "goimports-reviser",
                        args = {
                            "-imports-order std,general,company,project,blanked,dotted",
                            "-company-prefixes",
                            "-format",
                            "$FILENAME",
                        },
                        stdin = false,
                    },
                    golines = {
                        command = "golines",
                        args = {
                            "--max-len=120"
                        }
                    },
                    clang_format = {
                        command = "clang-format",
                        prepend_args = { '--style=file', '--fallback-style=LLVM' },
                    }
                },
                format_on_save = {
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 1000,
                },
            })

            vim.keymap.set({ "n", "v" }, "<leader>mp", function()
                conform.format({
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 1000,
                })
            end, { desc = "Format file or range (in visual mode)" })
        end,
    },
    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        config = function()
            require("lsp_lines").setup()
        end,
    },
}
