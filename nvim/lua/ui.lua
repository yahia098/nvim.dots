local which_key = require("which-key")
local colorizer = require("colorizer")
local lualine = require("lualine")

-- Colorscheme
vim.cmd.colorscheme("tokyonight-storm")

-- Keymap hints
which_key.setup({})

-- Highlight CSS colors (#RRGGBB, rgb(), rgba(), etc.)
colorizer.setup()

-- Statusline
lualine.setup({
	options = {
		theme = "tokyonight",
		globalstatus = true,
	},
})
