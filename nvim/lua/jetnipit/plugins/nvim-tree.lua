local HEIGHT_RATIO = 0.8
local WIDTH_RATIO = 0.5

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    local function open_nvim_tree(data)
      local directory = vim.fn.isdirectory(data.file) == 1
      if not directory then
        return
      end
      vim.cmd.cd(data.file)
      require("nvim-tree.api").tree.open()
    end

    vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

    nvimtree.setup({
      view = {
        number = true,
        relativenumber = true,
        float = {
          enable = true,
          open_win_config = function()
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            local window_w = screen_w * WIDTH_RATIO
            local window_h = screen_h * HEIGHT_RATIO
            local window_w_int = math.floor(window_w)
            local window_h_int = math.floor(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
            return {
              relative = "editor",
              row = center_y,
              col = center_x,
              width = window_w_int,
              height = window_h_int,
            }
          end,
        },
        width = function()
          return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
        end,
      },
      renderer = {
        indent_markers = {
          enable = true,
        },
        highlight_git = "icon",
        icons = {
          git_placement = "after",
          diagnostics_placement = "after",
          glyphs = {
            default = "",
            symlink = "",
            bookmark = "󰆤",
            modified = "●",
            hidden = "󰜌",
            folder = {
              arrow_closed = "",
              arrow_open = "",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "(unstage)",
              staged = "(stage)",
              unmerged = "(unmerged)",
              renamed = "(rename)",
              untracked = "(untrack)",
              deleted = "(delete)",
              ignored = "(ignored)",
            },
          },
        },
      },
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      git = {
        ignore = false,
      },
    })
  end,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>",         desc = "File explorer" },
    { "<leader>E", "<cmd>NvimTreeFindFileToggle<CR>", desc = "Toggle file explorer on current file" },
  },
}
