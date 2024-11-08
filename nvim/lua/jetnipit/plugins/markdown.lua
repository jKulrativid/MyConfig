return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  -- Don't forget "brew install mdp. If this doesn't work, type `:call mkdp#util#install()` in the normal mode."
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
