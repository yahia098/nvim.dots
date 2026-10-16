local dap = require("dap")
local dapui = require("dapui")
local runner = require("code_runner")
local map = vim.keymap.set
local builtin = require("telescope.builtin")

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
map("n", "<leader>ff", builtin.find_files, {
	desc = "Find files",
})
map("n", "<leader>fg", builtin.live_grep, {
	desc = "Search text",
})
map("n", "<leader>fb", builtin.buffers, {
	desc = "Find buffers",
})
map("n", "<leader>fh", builtin.help_tags, {
	desc = "Search help",
})

-- Debug: execution
map("n", "<F5>", dap.continue, {
	desc = "Debug: Start / Continue",
})
map("n", "<S-F5>", dap.terminate, {
	desc = "Debug: Terminate",
})
map("n", "<F10>", dap.step_over, {
	desc = "Debug: Step Over",
})
map("n", "<F11>", dap.step_into, {
	desc = "Debug: Step Into",
})
map("n", "<F12>", dap.step_out, {
	desc = "Debug: Step Out",
})
map("n", "<leader>dp", dap.pause, {
	desc = "Debug: Pause",
})
map("n", "<leader>dl", dap.run_last, {
	desc = "Debug: Run Last Configuration",
})

-- Debug: breakpoints
map("n", "<leader>b", dap.toggle_breakpoint, {
	desc = "Debug: Toggle Breakpoint",
})
map("n", "<leader>B", function()
	local condition = vim.fn.input("Breakpoint condition: ")
	if condition ~= "" then
		dap.set_breakpoint(condition)
	end
end, {
	desc = "Debug: Conditional Breakpoint",
})
map("n", "<leader>dc", dap.clear_breakpoints, {
	desc = "Debug: Clear All Breakpoints",
})

-- Debug: inspection
map("n", "<leader>du", dapui.toggle, {
	desc = "Debug: Toggle UI",
})
map("n", "<leader>dr", dap.repl.open, {
	desc = "Debug: Open REPL",
})
map({ "n", "v" }, "<leader>de", function()
	dapui.eval()
end, {
	desc = "Debug: Evaluate Expression",
})

-- Code Runner
map("n", "<leader>r", runner.run_code, {
	desc = "Run: Execute Code",
})
map("n", "<leader>R", runner.run_filetype, {
	desc = "Run: Current File",
})
map("n", "<leader>P", runner.run_project, {
	desc = "Run: Current Project",
})
map("n", "<leader>X", runner.run_close, {
	desc = "Run: Close Runner",
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
