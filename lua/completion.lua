local blink = require("blink.cmp")
local autopairs = require("nvim-autopairs")

if not blink.library_available() then
	blink.build():pwait()
end

blink.setup({
	-- Arrow keys are left alone (they just move the cursor).
	-- Tab / Shift-Tab walk through the menu, Enter accepts the selected item.
	keymap = {
		preset = "none",
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		["<CR>"] = { "accept", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "hide", "fallback" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
	},

	completion = {
		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},

		documentation = {
			auto_show = true,
			auto_show_delay_ms = 300,
			window = {
				border = "rounded",
				max_width = 80,
				max_height = 20,
			},
		},

		ghost_text = {
			enabled = false,
		},

		accept = {
			auto_brackets = {
				enabled = true,
			},
		},
	},

	signature = {
		enabled = true,
		window = {
			border = "rounded",
			max_width = 80,
			max_height = 12,
		},
	},

	sources = {
		default = {
			"lsp",
			"path",
			"snippets",
			"buffer",
		},
	},

	fuzzy = {
		implementation = "rust",
	},
})

autopairs.setup({})
