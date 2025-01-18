function get_visual_selection()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg("v")
    vim.fn.setreg("v", {})

    text = string.gsub(text, "\n", "")
    if #text > 0 then
        return text
    else
        return ""
    end
end

return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    lazy = true,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "nvim-telescope/telescope-ui-select.nvim",
        "nvim-telescope/telescope-dap.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    -- stylua: ignore

    config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")

        -- Find group
        vim.keymap.set('n', '<leader>f', '', { desc = 'Find' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
        vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent Files' })

        local live_grep = function()
            builtin.live_grep({
                additional_args = function()
                    return { "--no-ignore-vcs", "--hidden", "--follow" }
                end
            })
        end

        -- Search group
        vim.keymap.set('n', '<leader>fs', live_grep, { desc = 'Search Words' })
        vim.keymap.set('x', '<leader>fs', function()
            local text = get_visual_selection()
            telescope.live_grep({ default_text = text })
        end, { desc = 'Search Selected Word' })

        vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Diagnostics' })

        -- Custom modified buffers finder
        vim.keymap.set('n', '<leader>fm', function()
            local action_state = require("telescope.actions.state")
            local actions = require("telescope.actions")

            require("telescope.pickers")
                .new({}, {
                    prompt_title = "Modified Buffers",
                    finder = require("telescope.finders").new_table({
                        results = vim.tbl_filter(function(buf)
                            return vim.bo[buf].modified
                        end, vim.api.nvim_list_bufs()),
                        entry_maker = function(buf)
                            local filename = vim.api.nvim_buf_get_name(buf)
                            filename = vim.fn.fnamemodify(filename, ":p:~:.")
                            return {
                                value = buf,
                                display = string.format("%d: %s", buf, filename),
                                ordinal = filename,
                            }
                        end,
                    }),
                    sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
                    attach_mappings = function(prompt_bufnr, _)
                        actions.select_default:replace(function()
                            local selection = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)
                            vim.api.nvim_set_current_buf(selection.value)
                        end)
                        return true
                    end,
                })
                :find()
        end, { desc = 'Modified Buffers' })

        -- Debugger Breakpoints
        vim.keymap.set('n', '<leader>fB', function()
            telescope.extensions.dap.list_breakpoints({})
        end, { desc = 'Breakpoints' })

        -- Git group
        vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git Status' })
        vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Checkout Branch' })
        vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Checkout Commit' })
        vim.keymap.set('n', '<leader>gC', builtin.git_bcommits, { desc = 'Checkout Commit (Current File)' })

        telescope.setup({
            defaults = {
                path_display = { "smart" },
                border = true,
                layout_config = {
                    horizontal = {
                        size = {
                            width = "90%",
                            height = "60%",
                        },
                    },
                    vertical = {
                        size = {
                            width = "90%",
                            height = "90%",
                        },
                    },
                },
            },

            extensions = {
                fzf = {
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown({}),
                },
            },
        })

        telescope.load_extension("fzf")
        telescope.load_extension("ui-select")
        telescope.load_extension("dap")
    end,
}
