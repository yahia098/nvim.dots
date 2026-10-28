-- lua/tools.lua
--
-- Project-wide helpers: Trouble (lists for diagnostics / references / symbols)
-- and grug-far (search and replace across the project with a live preview).
-- grug-far needs ripgrep (`rg`) installed.

local map = vim.keymap.set

require("trouble").setup({})
local grug = require("grug-far")
grug.setup({})

-- Trouble
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Trouble: diagnostics (project)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Trouble: diagnostics (buffer)" })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", { desc = "Trouble: symbols" })
map("n", "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", { desc = "Trouble: LSP references" })
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", { desc = "Trouble: location list" })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Trouble: quickfix list" })

-- grug-far: search & replace. Tip: run <leader>cr first to start from the
-- project root.
map("n", "<leader>sg", function()
	grug.open({ transient = true })
end, { desc = "Search & replace (project)" })
map("x", "<leader>sg", function()
	grug.with_visual_selection({ transient = true })
end, { desc = "Search & replace selection" })
map("n", "<leader>sw", function()
	grug.open({ transient = true, prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Search & replace word" })
map("n", "<leader>sf", function()
	grug.open({ transient = true, prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search & replace (this file)" })

require("which-key").add({
	{ "<leader>x", group = "Trouble" },
})
