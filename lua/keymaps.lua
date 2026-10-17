local map = vim.keymap.set
local builtin = require("telescope.builtin")
local cmake = require("cmake-tools")
local snacks = require("snacks")
-- General
map("n", "<leader>w", "<cmd>w<CR>", {
	desc = "Save",
})
map("n", "<leader>q", "<cmd>q<CR>", {
	desc = "Quit",
})
map("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", {
	desc = "Clear search highlight",
})

-- Clipboard
map({ "n", "v" }, "y", '"+y', {
	desc = "Yank to system clipboard",
})
map({ "n", "v" }, "Y", '"+Y', {
	desc = "Yank lines to system clipboard",
})
map({ "n", "v" }, "<A-y>", '"+d', {
	desc = "Cut to system clipboard",
})

-- Oil
map("n", "<leader>fe", "<CMD>Oil<CR>", {
	desc = "Open Oil",
})

-- Telescope
map("n", "<leader>fb", builtin.buffers, {
	desc = "Find buffers",
})
map("n", "<leader>fh", builtin.help_tags, {
	desc = "Search help",
})
-- Telescope
map("n", "<leader>ff", function()
	builtin.find_files({
		cwd = vim.uv.cwd(),
		hidden = true,
	})
end, {
	desc = "Find files (cwd)",
})

map("n", "<leader>fg", function()
	builtin.live_grep({
		cwd = vim.uv.cwd(),
		additional_args = { "--hidden" },
	})
end, {
	desc = "Search text (cwd)",
})

-- Git: Gitsigns
local gitsigns = require("gitsigns")

map("n", "]c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		gitsigns.nav_hunk("next")
	end
end, { desc = "Git: Next hunk" })

map("n", "[c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		gitsigns.nav_hunk("prev")
	end
end, { desc = "Git: Previous hunk" })

map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Git: Preview hunk" })
map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Git: Stage hunk" })
map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Git: Reset hunk" })
map("n", "<leader>hb", gitsigns.blame_line, { desc = "Git: Blame line" })
-- CMake

map("n", "<leader>cg", cmake.generate, {
	desc = "CMake: Generate",
})

map("n", "<leader>cb", cmake.build, {
	desc = "CMake: Build",
})

map("n", "<leader>cc", cmake.clean, {
	desc = "CMake: Clean",
})

map("n", "<leader>cr", cmake.run, {
	desc = "CMake: Run",
})

map("n", "<leader>cd", cmake.select_build_type, {
	desc = "CMake: Select Build Type",
})

map("n", "<leader>ct", cmake.select_build_target, {
	desc = "CMake: Select Build Target",
})

map("n", "<leader>cl", cmake.select_launch_target, {
	desc = "CMake: Select Launch Target",
})

-- Buffers
map("n", "<leader>bn", "<Cmd>BufferNext<CR>", {
	desc = "Buffer: Next",
})

map("n", "<leader>bp", "<Cmd>BufferPrevious<CR>", {
	desc = "Buffer: Previous",
})

map("n", "<leader>bc", "<Cmd>BufferClose<CR>", {
	desc = "Buffer: Close",
})

map("n", "<leader>bo", "<Cmd>BufferCloseAllButCurrent<CR>", {
	desc = "Buffer: Close Others",
})

map("n", "<leader>br", "<Cmd>BufferRestore<CR>", {
	desc = "Buffer: Restore Closed",
})

map("n", "<leader>bt", "<Cmd>BufferPick<CR>", {
	desc = "Buffer: Pick",
})
-- Terminal Snacks
map("n", "<leader>tt", function()
	snacks.terminal()
end, { desc = "Toggle terminal" })
