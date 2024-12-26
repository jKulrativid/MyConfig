vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 4    -- 4 spaces for tab
opt.shiftwidth = 4 -- 4 space for indent width
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

-- terminal integration
opt.termguicolors = true -- turn on termguicolors
opt.background = "dark"  -- colorschemes that can be light or dark will be dark
opt.signcolumn = "yes"   -- show the sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line, or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split window
opt.splitright = true -- split vertical window on the right
opt.splitbelow = true -- split horizontal window on the bottom

vim.diagnostic.config({
    virtual_text = false,
})
