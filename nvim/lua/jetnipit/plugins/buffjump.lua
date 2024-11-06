return {
  "kwkarlwang/bufjump.nvim",
  config = function()
    require("bufjump").setup({ on_success = nil })
  end,

  -- stylua: ignore
  keys = {
    { "<leader>i", function() require("bufjump").forward() end,  desc = "Jump to next buffer" },
    { "<leader>o", function() require("bufjump").backward() end, desc = "Jump to previous buffer" },
  },
}
