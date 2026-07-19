local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local blink = require("blink.cmp")

mason.setup()

mason_lspconfig.setup({
	ensure_installed = {
		"basedpyright",
		"lua_ls",
		"lemminx",
		"glsl_analyzer",
	},
})

local capabilities = blink.get_lsp_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false

vim.lsp.config("clangd", {
	capabilities = capabilities,
})

vim.lsp.config("basedpyright", {
	capabilities = capabilities,
	settings = {
		basedpyright = {
			analysis = {
				autoSearchPaths = true,
			},
		},
	},
})

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
})

vim.lsp.config("glsl_analyzer", {
	capabilities = capabilities,
})

vim.lsp.config("lemminx", {
	capabilities = capabilities,
})

vim.lsp.config("json-lsp", {
	capabilities = capabilities,
})

vim.lsp.enable({
	"clangd",
	"basedpyright",
	"lua_ls",
	"glsl_analyzer",
	"lemminx",
	"json-lsp",
})

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		spacing = 2,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
	},
})
