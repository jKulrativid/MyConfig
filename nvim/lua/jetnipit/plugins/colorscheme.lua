return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		local theme = require("catppuccin")
		theme.setup({
			flavour = "macchiato",
			transparent_background = false,
			dim_inactive = {
				enabled = true,
				shade = "dark",
				percentage = 0.25,
			},
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				loops = { "italic" },
				functions = { "italic" },
				keywords = { "italic" },
				strings = {},
				variables = {},
				numbers = {},
				booleans = {},
				properties = {},
				types = {},
				operators = {},
			},
			integrations = {
				mason = true,
				gitsigns = true,
				nvimtree = true,
				which_key = true,
				treesitter = true,
				telescope = {
					enabled = true,
					style = "nvchad",
				},
			},
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
