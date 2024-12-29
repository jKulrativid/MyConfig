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
