local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		cpp = { "clang_format" },
		c = { "clang_format" },
		lua = { "stylua" },
		python = { "black" },
		json = { "prettierd" },
		jsonc = { "prettierd" },
		yaml = { "prettierd" },
		markdown = { "prettierd" },
		html = { "prettierd" },
		css = { "prettierd" },
	},

	format_on_save = {
		timeout_ms = 2000,
		lsp_fallback = true,
	},
})
