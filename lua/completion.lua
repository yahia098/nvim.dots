local blink = require("blink.cmp")
local autopairs = require("nvim-autopairs")
local lsp_signature = require("lsp_signature")
if not blink.library_available() then
	blink.build():pwait()
end
blink.setup({
	keymap = {
		preset = "default",
		["<Tab>"] = { "accept", "snippet_forward", "fallback" },
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
lsp_signature.setup({
	bind = true,
	floating_window = true,
	floating_window_above_cur_line = true,
	hint_enable = false,

	handler_opts = {
		border = "rounded",
	},
	toggle_key = "<M-x>",
	max_height = 12,
	max_width = 80,
})
