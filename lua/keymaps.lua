-- lua/keymaps.lua
--
-- All keymaps live here. runner.lua must be loaded first so the
-- Code Runner and CMake Tools configurations already exist.

local map = vim.keymap.set
local builtin = require("telescope.builtin")
local cmake = require("cmake-tools")
local snacks = require("snacks")

-- Helper: find a file by searching upward from the current buffer.
-- This lets source files inside src/ find project files in ../.
local function find_upward(names)
	return vim.fs.find(names, {
		path = vim.fn.expand("%:p:h"),
		upward = true,
		type = "file",
	})[1]
end

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
end, {
	desc = "Git: Next hunk",
})

map("n", "[c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		gitsigns.nav_hunk("prev")
	end
end, {
	desc = "Git: Previous hunk",
})

map("n", "<leader>hp", gitsigns.preview_hunk, {
	desc = "Git: Preview hunk",
})

map("n", "<leader>hs", gitsigns.stage_hunk, {
	desc = "Git: Stage hunk",
})

map("n", "<leader>hr", gitsigns.reset_hunk, {
	desc = "Git: Reset hunk",
})

map("n", "<leader>hb", gitsigns.blame_line, {
	desc = "Git: Blame line",
})

-- CMake
-- cmake-tools handles configuration, build targets, and launching.

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

-- Runner
--
-- <leader>rr: Run the project.
-- For CMake projects, run the selected CMake launch target.
-- For other projects, let Code Runner use root_markers.
--
-- <leader>rf: Run the current file using its filetype command.
-- This intentionally bypasses project-level detection.

map("n", "<leader>rr", function()
	if find_upward("CMakeLists.txt") then
		cmake.run()
	else
		vim.cmd("RunProject")
	end
end, {
	desc = "Run project",
	silent = true,
})

map("n", "<leader>rf", "<cmd>RunFile<CR>", {
	desc = "Run current file",
	silent = true,
})

-- Make: dynamically list targets from the nearest Makefile.
--
-- `make -qp` prints Make's database in query mode.
-- Exit code 0 means targets are up to date.
-- Exit code 1 means a target would need rebuilding; this is normal.
-- Exit codes greater than 1 indicate an error.
--
-- Query mode doesn't execute ordinary target recipes, although
-- Makefile parsing can still evaluate constructs such as $(shell ...).

local special_make_targets = {
	[".PHONY"] = true,
	[".SUFFIXES"] = true,
	[".DEFAULT"] = true,
	[".PRECIOUS"] = true,
	[".INTERMEDIATE"] = true,
	[".SECONDARY"] = true,
	[".SECONDEXPANSION"] = true,
	[".DELETE_ON_ERROR"] = true,
	[".IGNORE"] = true,
	[".LOW_RESOLUTION_TIME"] = true,
	[".SILENT"] = true,
	[".EXPORT_ALL_VARIABLES"] = true,
	[".NOTPARALLEL"] = true,
	[".ONESHELL"] = true,
	[".POSIX"] = true,
	[".WAIT"] = true,
}

local function select_make_target()
	-- Start in the current file's directory, then search parents.
	-- For a file such as project/src/main.cpp, this finds project/Makefile.
	local makefile = find_upward({
		"GNUmakefile",
		"Makefile",
		"makefile",
	})

	if not makefile then
		vim.notify("No Makefile found in this directory or its parents", vim.log.levels.WARN)
		return
	end

	local root = vim.fs.dirname(makefile)

	-- Passing an argv list avoids shell quoting problems with the path.
	local output = vim.fn.systemlist({
		"make",
		"-qp",
		"-C",
		root,
	})

	local status = vim.v.shell_error

	-- GNU Make uses status 1 in query mode when something needs rebuilding.
	if status > 1 then
		local details = table.concat(output, "\n")
		vim.notify(
			"make -qp failed with exit status " .. status .. (details ~= "" and ":\n" .. details or ""),
			vim.log.levels.ERROR
		)
		return
	end

	-- The database's # Files section contains target records.
	-- Ignore records explicitly marked "# Not a target:", comments,
	-- recipe lines, variable assignments, and pattern rules.
	local targets = {}
	local seen = {}
	local in_files = false
	local not_target = false

	for _, line in ipairs(output) do
		if line == "# Files" then
			in_files = true
		elseif in_files and (line:match("^# VPATH Search Paths") or line:match("^# Finished Make database")) then
			break
		elseif in_files and line == "# Not a target:" then
			not_target = true
		elseif in_files and line:match("^%S") and not line:match("^#") then
			-- Real target declarations start at column one.
			-- `:=` and `::=` are variable assignments, not target rules.
			local colon = line:find(":", 1, true)

			if colon then
				local lhs = line:sub(1, colon - 1)
				local is_assignment = line:match("^[^:]+:%s*=") or line:match("^[^:]+::=")

				if not is_assignment and not lhs:find("=", 1, true) and not not_target then
					-- A rule can declare multiple targets on its left side.
					for target in lhs:gmatch("%S+") do
						local is_pattern = target:find("%", 1, true) ~= nil

						if
							target ~= ""
							and not is_pattern
							and not special_make_targets[target]
							and not seen[target]
						then
							seen[target] = true
							table.insert(targets, target)
						end
					end
				end
			end

			-- The "# Not a target:" comment applies to the next
			-- top-level record, not to subsequent target declarations.
			not_target = false
		end
	end

	table.sort(targets)

	if #targets == 0 then
		vim.notify("No Make targets found", vim.log.levels.WARN)
		return
	end

	-- Use Neovim's built-in selector; no picker plugin is required.
	vim.ui.select(targets, {
		prompt = "Make target",
		format_item = function(target)
			return "make " .. target
		end,
	}, function(target)
		-- nil means the selection was cancelled.
		if not target then
			return
		end

		-- Always execute from the Makefile's directory, not src/.
		-- `--` ends option processing before the selected target.
		local command = ("make -C %s -- %s"):format(vim.fn.shellescape(root), vim.fn.shellescape(target))

		require("code_runner").run_from_fn(command)
	end)
end

-- Register the group so Which-Key labels these mappings as Make.
require("which-key").add({
	{ "<leader>m", group = "Make" },
})

map("n", "<leader>mt", select_make_target, {
	desc = "Make: Select target",
	silent = true,
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

-- Terminal: Snacks
map("n", "<leader>t", function()
	snacks.terminal()
end, {
	desc = "Toggle terminal",
})
