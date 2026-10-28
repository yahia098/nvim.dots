local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local blink_plugin = require("blink.cmp")

mason.setup()
mason_lspconfig.setup({
	ensure_installed = {
		"basedpyright",
		"lua_ls",
		"lemminx",
		"glsl_analyzer",
		"jdtls",
		"jsonls",
		"cssls",
	},
	automatic_enable = false,
})

-- External tools used by conform.nvim, nvim-lint and clangd.
-- (clippy comes from rustup: `rustup component add clippy`)
require("mason-tool-installer").setup({
	ensure_installed = {
		"clangd",
		"clang-format",
		"stylua",
		"black",
		"prettierd",
		"shellcheck",
		"ruff",
		"selene",
	},
})

local capabilities = blink_plugin.get_lsp_capabilities()

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
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					vim.env.VIMRUNTIME,
				},
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
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

vim.lsp.config("cssls", {
	capabilities = capabilities,
	settings = {
		css = {
			lint = {
				unknownAtRules = "ignore",
			},
		},
		scss = {
			lint = {
				unknownAtRules = "ignore",
			},
		},
		less = {
			lint = {
				unknownAtRules = "ignore",
			},
		},
	},
})

local servers = {
	"clangd",
	"basedpyright",
	"lua_ls",
	"glsl_analyzer",
	"lemminx",
	"jsonls",
	"cssls",
}

vim.lsp.enable(servers)

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

		if vim.fn.executable(jdtls_cmd) ~= 1 and vim.fn.executable("jdtls") == 1 then
			jdtls_cmd = "jdtls" -- system-wide install
		end

		if vim.fn.executable(jdtls_cmd) ~= 1 then
			vim.notify("JDTLS executable not found: " .. jdtls_cmd, vim.log.levels.ERROR)
			return
		end

		local workspace_name = vim.fn.fnamemodify(root_dir, ":t") .. "-" .. vim.fn.sha256(root_dir):sub(1, 8)

		local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. workspace_name

		vim.fn.mkdir(workspace_dir, "p")

		local debug_path = packages .. "/java-debug-adapter"
		local bundles = vim.fn.glob(debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)

		-- Debugging needs nvim-dap, which isn't in plugins.lua. Only set up DAP (and
		-- nag about the debug adapter) when nvim-dap is actually installed.
		local has_dap = pcall(require, "dap")

		if has_dap and #bundles == 0 then
			vim.notify("Java debug adapter not found. Install java-debug-adapter through :Mason.", vim.log.levels.WARN)
		end

		local java_capabilities = blink_plugin.get_lsp_capabilities()

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
				if has_dap and #bundles > 0 then
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

-- LSP keymaps and symbol highlighting
-- Buffer-local, set only when a server attaches.
local map = vim.keymap.set
local lsp_group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_group,
	callback = function(ev)
		local function lmap(mode, lhs, rhs, desc)
			map(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
		end

		lmap("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
		lmap("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
		lmap("n", "gy", vim.lsp.buf.type_definition, "LSP: Go to type definition")
		lmap("n", "<leader>ls", vim.lsp.buf.signature_help, "LSP: Signature help")
		lmap("n", "<leader>lr", vim.lsp.buf.rename, "LSP: Rename")
		lmap({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, "LSP: Code action")
		lmap({ "n", "x" }, "<leader>lf", function()
			vim.lsp.buf.format({ async = true })
		end, "LSP: Format")
		lmap("n", "<leader>lR", vim.lsp.buf.references, "LSP: References")
		lmap("n", "<leader>li", vim.lsp.buf.implementation, "LSP: Implementation")

		lmap("n", "<leader>lc", vim.lsp.buf.incoming_calls, "LSP: Incoming calls")
		lmap("n", "<leader>lC", vim.lsp.buf.outgoing_calls, "LSP: Outgoing calls")
		lmap("n", "<C-LeftMouse>", "<LeftMouse><cmd>lua vim.lsp.buf.definition()<CR>", "LSP: Go to definition")

		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- Fold by the language server's own structure (functions, blocks, ...).
		if client and client:supports_method("textDocument/foldingRange") then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldmethod = "expr"
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end
		if client and client:supports_method("textDocument/inlayHint") then
			lmap("n", "<leader>lh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
			end, "LSP: Toggle inlay hints")
		end

		-- Highlight other uses of the symbol under the cursor while idle.
		if client and client:supports_method("textDocument/documentHighlight") then
			local hl = vim.api.nvim_create_augroup("UserLspHighlight" .. ev.buf, { clear = true })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = hl,
				buffer = ev.buf,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				group = hl,
				buffer = ev.buf,
				callback = vim.lsp.buf.clear_references,
			})
		end
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
