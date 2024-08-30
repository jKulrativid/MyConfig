return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			ensure_installed = {
				"rust_analyzer",
				"tsserver",
				"html",
				"cssls",
				"tailwindcss",
				"lua_ls",
				"graphql",
				"pyright",
				"emmet_ls",
				"prismals",
				"gopls",
				"yamlls",
				"terraformls",
				"taplo",
				"sqlls",
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"cspell",
				"prettier",
				"stylua",
				"isort",
				"black",
				"tflint",
			},
		})
	end,
}
