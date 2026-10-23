local which_key = require("which-key")
local lualine = require("lualine")
local snacks = require("snacks")
local telescope = require("telescope")
local barbar = require("barbar")
local colorer = require("colorizer")
-- Colorscheme
require("matugen").setup({
	colors_path = "~/.config/matugen/templates/colors-nvim.json",
})
vim.cmd.colorscheme("matugen")
-- Keymap hints i need this to save me
which_key.setup({})

-- Highlight CSS colors (#RRGGBB, rgb(), rgba(), etc.)
-- it is a mess so left to defaults

-- Statusline
lualine.setup({
	options = {
		globalstatus = true,
	},
})

--snacks stuff
--
snacks.setup({
	notifier = {
		enabled = true,
		timeout = 3000,
	},
	picker = {
		enabled = true,
	},

	explorer = {
		enabled = false,
	},

	terminal = {
		win = {
			style = "terminal",
			position = "float",
			width = 0.85,
			height = 0.75,
			border = "single",
		},
	},
	styles = {
		esp32_terminal = {
			width = 0.9,
			height = 0.5,
			border = "rounded",
			position = "bottom",
		},
	},
	dashboard = {
		enabled = true,
		width = 72,
		preset = require("dashboard").preset,
		sections = require("dashboard").sections,
	},
})

require("gitsigns").setup({
	current_line_blame = false,
	signcolumn = true,
	numhl = false,
	word_diff = false,
})

telescope.setup({
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})

-- pcall: the native library may not be built yet (first launch or failed build).
pcall(telescope.load_extension, "fzf")

barbar.setup({
	animation = true,
	auto_hide = false,
	clickable = true,
	icons = {
		filetype = {
			enabled = true,
		},
		button = "×",
		diagnostics = {
			[vim.diagnostic.severity.ERROR] = {
				enabled = true,
				icon = "●",
			},
		},
	},
})

colorer.setup({
	user_default_options = {
		names = false,
		RGB = true,
		RGBA = true,
		RRGGBB = true,
		RRGGBBAA = true,
		AARRGGBB = true,
		rgb_fn = true,
		hsl_fn = true,
		css = true,
		css_fn = true,
		mode = "background",
	},
})
