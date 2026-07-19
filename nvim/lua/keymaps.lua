vim.g.mapleader = " "

local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", {
	desc = "Clear search highlight",
})

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

map({ "n", "v" }, "y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<A-y>", '"+d', { desc = "Cut to system clipboard" })

map("n", "<leader>ff", "<CMD>Oil<CR>", {
	desc = "Open Oil",
})
