local function get_vscode_settings()
    local settings_file = vim.fn.getcwd() .. '/.vscode/settings.json'
    if vim.fn.filereadable(settings_file) == 1 then
        local contents = vim.fn.readfile(settings_file)
        local settings = vim.fn.json_decode(table.concat(contents, '\n'))
        return settings
    end
    return {}
end

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp", "b0o/schemastore.nvim",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim",                   opts = {} },
    },
    config = function()
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")

        -- import cmp-nvim-lsp plugin
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        -- used to enable autocompletion (assign to every lsp server config)
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Change the Diagnostic symbols in the sign column (gutter)
        -- (not in youtube nvim video)
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        local vscode_settings = get_vscode_settings()
        if vscode_settings == nil then
            vscode_settings = {}
        end

        lspconfig.lua_ls.setup({
            capabilities = capabilities,
            on_init = function(client)
                if client.workspace_folders then
                    local path = client.workspace_folders[1].name
                    if vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc") then
                        return
                    end
                end

                client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                    runtime = {
                        -- Tell the language server which version of Lua you're using
                        version = "LuaJIT",
                        -- Setup your lua path
                        path = vim.split(package.path, ";"),
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { "vim" },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                        checkThirdParty = false,
                    },
                    telemetry = { enable = false },
                })
            end,
            settings = {
                Lua = {},
            },
        })

        local gopls_settings = vscode_settings["gopls"] or {}

        lspconfig.gopls.setup {
            cmd = { "gopls" },
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
            settings = {
                gopls = {
                    analyses = gopls_settings["analyses"] or {
                        nilness = true,
                        unusedwrite = true,
                        useany = true,
                        unreachable = true,
                        unusedparams = true,
                        unusedvariable = true,
                    },
                    buildFlags = gopls_settings["buildFlags"] or {},
                    env = gopls_settings["env"] or {},
                    directoryFilters = gopls_settings["directoryFilters"] or {},
                    staticcheck = true,
                    gofumpt = true,
                    experimentalPostfixCompletions = true,
                }
            }
        }

        lspconfig.html.setup({
            capabilities = capabilities,
        })

        lspconfig.cssls.setup({
            capabilities = capabilities,
        })

        lspconfig.cssmodules_ls.setup({
            capabilities = capabilities,
        })

        lspconfig.eslint.setup({
            on_attach = function(_, bufnr)
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = bufnr,
                    command = "EslintFixAll",
                })
            end,
        })

        lspconfig.ts_ls.setup({
            capabilities = capabilities,
        })

        lspconfig.rust_analyzer.setup {
            capabilities = capabilities,
        }

        local haskell_capabilities = cmp_nvim_lsp.default_capabilities()
        haskell_capabilities.textDocument.semanticsToken = nil
        lspconfig.hls.setup({
            capabilities = haskell_capabilities,
            filetypes = { 'haskell', 'lhaskell', 'cabal' },
        })

        lspconfig.jsonls.setup({
            capabilities = capabilities,
        })

        lspconfig.yamlls.setup({
            capabilities = capabilities,
            settings = {
                yaml = {
                    schemaStore = {
                        enable = false,
                        url = "",
                    },
                    schemas = require("schemastore").yaml.schemas(),
                },
            },
        })

        -- key binding config --

        local keymap = vim.keymap -- for conciseness

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf, silent = true }

                -- set keybinds
                opts.desc = "Show LSP references"
                keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

                opts.desc = "Go to declaration"
                keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

                opts.desc = "Show LSP definitions"
                keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

                opts.desc = "Show LSP implementations"
                keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

                opts.desc = "Show LSP type definitions"
                keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

                -- opts.desc = "See available code actions"
                -- keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

                opts.desc = "Smart rename"
                keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

                -- opts.desc = "Show buffer diagnostics"
                -- keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

                opts.desc = "Show line diagnostics"
                keymap.set("n", "<leader>wx", vim.diagnostic.open_float, opts) -- show diagnostics for line

                -- opts.desc = "Go to previous diagnostic"
                -- keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

                -- opts.desc = "Go to next diagnostic"
                -- keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

                opts.desc = "Show documentation for what is under cursor"
                keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

                opts.desc = "Restart LSP"
                keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
            end,
        })

        vim.api.nvim_create_augroup('haskell_settings', { clear = true })
        vim.api.nvim_create_autocmd('FileType', {
            group = 'haskell_settings',
            pattern = { 'haskell', 'lhaskell' },
            callback = function()
                vim.opt_local.tabstop = 2
                vim.opt_local.shiftwidth = 2
                vim.opt_local.expandtab = true
            end,
        })
    end,
}
