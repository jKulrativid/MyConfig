return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            {
                "theHamsta/nvim-dap-virtual-text",
                config = function()
                    require("nvim-dap-virtual-text").setup({
                        display_callback = function(variable, _, _, _, options)
                            local function truncate(str, max_length)
                                if #str > max_length then
                                    return str:sub(1, max_length) .. "..."
                                end
                                return str
                            end

                            -- Clean up the value by replacing multiple whitespace characters with a single space
                            local cleaned_value = variable.value:gsub("%s+", " ")

                            -- Truncate the cleaned value to 20 characters
                            local truncated_value = truncate(cleaned_value, 20)

                            if options.virt_text_pos == "inline" then
                                return " = " .. truncated_value
                            else
                                return variable.name .. " = " .. truncated_value
                            end
                        end,
                    })
                end,
            },
        },

        config = function()
            local dap = require("dap")
            dap.adapters.delve = function(callback, _)
                callback({
                    type = "server",
                    port = "${port}",
                    executable = {
                        command = "dlv",
                        args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
                        detached = vim.fn.has("win32") == 0,
                    },
                })
            end
        end,
        -- stylua: ignore
        keys = {
            { "<leader>d",  "",                                                desc = "Debug" },
            { "<leader>dc", function() require("dap").continue() end,          desc = "Continue" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<leader>dB", function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoint" },
            { "<leader>dL", function() require("dap").run_to_cursor() end,     desc = "Run to Cursor" },
            { "<leader>dg", function() require("dap").goto_() end,             desc = "Go to Line (No Execute)" },
            { "<leader>di", function() require("dap").step_into() end,         desc = "Step Into" },
            { "<leader>dj", function() require("dap").down() end,              desc = "Down" },
            { "<leader>dk", function() require("dap").up() end,                desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end,          desc = "Run Last" },
            { "<leader>do", function() require("dap").step_out() end,          desc = "Step Out" },
            { "<leader>dn", function() require("dap").step_over() end,         desc = "Step Over" },
            { "<leader>dp", function() require("dap").pause() end,             desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end,       desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end,           desc = "Session" },
            { "<leader>dx", function() require("dap").terminate() end,         desc = "Terminate" },
        },
    },
    {
        "leoluz/nvim-dap-go",
        url = "https://github.com/mcoqzeug/nvim-dap-go",
        branch = "set-cwd-for-dlv",
        config = function()
            require("dap-go").setup({
                verbose = true,
                root_dir = get_go_root_dir,
            })
        end,
        -- stylua: ignore
        keys = {
            {
                "<leader>dt",
                function()
                    require("dap-go").debug_test()
                end,
                desc = "Debug Test",
            },
        },
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        lazy = false,
        config = function()
            require("dapui").setup({
                floating = {
                    border = "none",
                    mappings = {
                        close = { "q", "<Esc>" },
                    },
                },
                render = {
                    indent = 4,
                    max_value_lines = 100,
                },
            })
        end,
        -- stylua: ignore
        keys = {
            { "<leader>v", function() require("dapui").float_element("scopes", { enter = true }) end,  desc = "Debug variables", },
            { "<leader>s", function() require("dapui").float_element("stacks", { enter = true }) end,  desc = "Debug stacks", },
            { "<leader>w", function() require("dapui").float_element("watches", { enter = true }) end, desc = "Debug watches", },
        },
    },
    {
        "daic0r/dap-helper.nvim",
        dependencies = { "rcarriga/nvim-dap-ui", "mfussenegger/nvim-dap" },
        config = function()
            require("dap-helper").setup()
        end,
    },
}
