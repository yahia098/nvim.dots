local which_key = require("which-key")
local lualine = require("lualine")
local snacks = require("snacks")
local telescope = require("telescope")
local barbar = require("barbar")

-- Colorscheme
vim.cmd.colorscheme("tokyonight-storm")

-- Keymap hints i need this to save me
which_key.setup({})

-- Highlight CSS colors (#RRGGBB, rgb(), rgba(), etc.)
-- it is a mess so left to defaults

-- Statusline
lualine.setup({
	options = {
		theme = "tokyonight",
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
		enabled = true,
	},

	styles = {
		esp32_terminal = {
			width = 0.9,
			height = 0.5,
			border = "rounded",
			position = "bottom",
		},
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

telescope.load_extension("fzf")

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
