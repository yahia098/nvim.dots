local which_key = require("which-key")
local colorizer = require("colorizer")
local lualine = require("lualine")
local snacks = require("snacks")
-- Colorscheme
vim.cmd.colorscheme("tokyonight-storm")

-- Keymap hints i need this to save me
which_key.setup({})

-- Highlight CSS colors (#RRGGBB, rgb(), rgba(), etc.)
-- it is a mess so left to defaults
colorizer.setup()

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
        enabled = true,
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
