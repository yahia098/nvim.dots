local blink = require("blink.cmp")
local autopairs = require("nvim-autopairs")
local lsp_signature = require("lsp_signature")

blink.setup({
	enabled = function()
		return next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil
	end,

	keymap = {
		preset = "none",

		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },

		["<CR>"] = { "accept", "fallback" },

		["<C-Space>"] = {
			"show",
			"show_documentation",
			"hide_documentation",
		},

		["<Esc>"] = { "hide", "fallback" },
	},

	appearance = {
		nerd_font_variant = "mono",
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
		},

		ghost_text = {
			enabled = false,
		},
	},
})

autopairs.setup({})

lsp_signature.setup({
	bind = true,
	floating_window = false,
	floating_window_above_cur_line = false,
	hint_enable = true,

	handler_opts = {
		border = "rounded",
	},

	toggle_key = "<M-x>",

	max_height = 12,
	max_width = 80,
})
