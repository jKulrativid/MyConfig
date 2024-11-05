return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function() vim.fn["mkdp#util#install"]() end,
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  event = "VeryLazy",
  config = function()
    -- custom keymap --
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>md", "<cmd>MarkdownPreview<CR>", { desc = "open markdown preview" })
  end
}
