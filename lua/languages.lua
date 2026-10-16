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
		"jdtls",
		"jsonls",
	},
	automatic_enable = false,
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

vim.lsp.config("jsonls", {
	capabilities = capabilities,
})

vim.lsp.enable({
	"clangd",
	"basedpyright",
	"lua_ls",
	"glsl_analyzer",
	"lemminx",
	"jsonls",
})

-- Java: nvim-jdtls
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("JavaLSP", { clear = true }),
	pattern = "java",
	callback = function()
		local jdtls = require("jdtls")

		local root_markers = {
			"gradlew",
			"mvnw",
			"pom.xml",
			"build.gradle",
			"build.gradle.kts",
			"settings.gradle",
			"settings.gradle.kts",
			"build.xml",
			".git",
		}

		local root_dir = vim.fs.root(0, root_markers) or vim.fn.expand("%:p:h")

		local packages = vim.fn.stdpath("data") .. "/mason/packages"
		local jdtls_cmd = packages .. "/jdtls/bin/jdtls"

		if vim.fn.executable(jdtls_cmd) ~= 1 then
			vim.notify("Mason JDTLS executable not found: " .. jdtls_cmd, vim.log.levels.ERROR)
			return
		end

		local workspace_name = vim.fn.fnamemodify(root_dir, ":t") .. "-" .. vim.fn.sha256(root_dir):sub(1, 8)

		local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. workspace_name

		vim.fn.mkdir(workspace_dir, "p")

		local debug_path = packages .. "/java-debug-adapter"
		local bundles = vim.fn.glob(debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)

		if #bundles == 0 then
			vim.notify("Java debug adapter not found. Install java-debug-adapter through :Mason.", vim.log.levels.WARN)
		end

		local java_capabilities = blink.get_lsp_capabilities()
		java_capabilities.textDocument.completion.completionItem.snippetSupport = false

		local config = {
			cmd = {
				jdtls_cmd,
				"-data",
				workspace_dir,
			},
			root_dir = root_dir,
			capabilities = java_capabilities,
			settings = {
				java = {
					signatureHelp = {
						enabled = true,
					},
					configuration = {
						updateBuildConfiguration = "interactive",
					},
				},
			},
			init_options = {
				bundles = bundles,
			},
			on_attach = function()
				if #bundles > 0 then
					jdtls.setup_dap({
						hotcodereplace = "auto",
					})
				end

				jdtls.setup.add_commands()
			end,
		}

		jdtls.start_or_attach(config)
	end,
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "arduino",
	callback = function()
		require("Arduino-Nvim").setup({})
	end,
})

if vim.env.IDF_PATH then
	require("esp")
end
