vim.g.mapleader = " "

local map = vim.keymap.set
local builtin = require('telescope.builtin')


map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

map({ "n", "v" }, "y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<A-y>", '"+d', { desc = "Cut to system clipboard" })

map("n", "<leader>fe", "<CMD>Oil<CR>", {
    desc = "Open Oil",
})
map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
map("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", {
    desc = "Clear search highlight",
})
