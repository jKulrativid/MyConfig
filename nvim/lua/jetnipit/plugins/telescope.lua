function vim.getVisualSelection()
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
  keys = {
    { "<leader>f",  "",                                   desc = "Find" },
    { "<leader>fb", require("telescope.builtin").buffers, desc = "Buffers" },
    {
      "<leader>fm",
      function()
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
      end,
      desc = "Modified buffers",
    },
    { "<leader>ff", require("telescope.builtin").find_files, desc = "File" },
    { "<leader>fr", require("telescope.builtin").oldfiles,   desc = "Recent files" },
    { "<leader>fs", require("telescope.builtin").live_grep,  desc = "word" },
    {
      "<leader>fs",
      function()
        local text = vim.getVisualSelection()
        require("telescope.builtin").live_grep({ default_text = text })
      end,
      desc = "word",
      mode = "x"
    },
    { "<leader>fd", require("telescope.builtin").diagnostics,                                desc = "Diagnostics" },
    { "<leader>fB", function() require("telescope").extensions.dap.list_breakpoints({}) end, desc = "Breakpoints" },

    { "<leader>gs", require("telescope.builtin").git_status,                                 desc = "Git status" },
    { "<leader>gb", require("telescope.builtin").git_branches,                               desc = "Checkout branch" },
    { "<leader>gc", require("telescope.builtin").git_commits,                                desc = "Checkout commit" },
    { "<leader>gC", require("telescope.builtin").git_bcommits,                               desc = "Checkout commit(for current file)" },
  },
  config = function()
    local telescope = require("telescope")

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
