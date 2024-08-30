return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.timeout = true
    vim.g.timeoutlen = 300
  end,
  opts = {
    -- your default cofig comes here
    -- or leaving it empty
  }
}

