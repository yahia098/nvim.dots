-- lua/keymaps.lua
--
-- All keymaps live here. runner.lua must be loaded first so the Code Runner
-- configuration already exists.

local map = vim.keymap.set
local builtin = require("telescope.builtin")
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

-- Run a CMake project using scripts/cmake_targets.sh rather than cmake-tools.
-- The script configures the project's build/ directory, discovers executable
-- targets through CMake's File API, and builds/runs the selected target.
local function run_cmake_project()
	local cmake_file = find_upward({ "CMakeLists.txt" })
	if not cmake_file then
		return false
	end

	local root = vim.fs.dirname(cmake_file)
	local build_dir = vim.fs.joinpath(root, "build")
	local script = vim.fs.joinpath(vim.fn.stdpath("config"), "scripts", "cmake_targets.sh")

	if vim.fn.filereadable(script) == 0 then
		vim.notify("CMake target script not found: " .. script, vim.log.levels.ERROR)
		return true
	end

	-- The script prints one executable target name per line. systemlist uses
	-- an argv list, so project paths containing spaces are passed safely.
	local targets = vim.fn.systemlist({ "bash", script, "list", root, build_dir })
	local status = vim.v.shell_error

	if status ~= 0 then
		local details = table.concat(targets, "\n")
		vim.notify("CMake target discovery failed" .. (details ~= "" and ":\n" .. details or "."), vim.log.levels.ERROR)
		return true
	end

	if #targets == 0 then
		vim.notify("No executable CMake targets found", vim.log.levels.WARN)
		return true
	end

	vim.ui.select(targets, {
		prompt = "Run CMake target",
		format_item = function(target)
			return target
		end,
	}, function(target)
		if not target then
			return
		end

		local command = table.concat({
			"bash",
			vim.fn.shellescape(script),
			"run",
			vim.fn.shellescape(root),
			vim.fn.shellescape(build_dir),
			vim.fn.shellescape(target),
		}, " ")

		require("code_runner").run_from_fn(command)
	end)

	return true
end

-- Build or clean the nearest CMake project using CMake's CLI.
local function run_cmake_action(action)
	local cmake_file = find_upward({ "CMakeLists.txt" })
	if not cmake_file then
		vim.notify("No CMakeLists.txt found in this directory or its parents", vim.log.levels.WARN)
		return
	end

	local root = vim.fs.dirname(cmake_file)
	local build_dir = vim.fs.joinpath(root, "build")
	local configure = ("cmake -S %s -B %s"):format(vim.fn.shellescape(root), vim.fn.shellescape(build_dir))
	local build

	if action == "clean" then
		build = ("cmake --build %s --target clean"):format(vim.fn.shellescape(build_dir))
	else
		build = ("cmake --build %s"):format(vim.fn.shellescape(build_dir))
	end

	require("code_runner").run_from_fn(configure .. " && " .. build)
end

-- Helper: run a fixed target (e.g. `run`, `clean`) from the nearest
-- Makefile's directory, so relative paths like shaders/ keep working.
local function run_make_target(target)
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
	local command = ("make -C %s -- %s"):format(vim.fn.shellescape(root), vim.fn.shellescape(target))

	require("code_runner").run_from_fn(command)
end

-- Clean whichever build system belongs to the current project.
-- CMake projects take priority if both marker files are present.
local function clean_project()
	if find_upward({ "CMakeLists.txt" }) then
		run_cmake_action("clean")
		return
	end

	if find_upward({ "GNUmakefile", "Makefile", "makefile" }) then
		run_make_target("clean")
		return
	end

	vim.notify("No CMakeLists.txt or Makefile found in this directory or its parents", vim.log.levels.WARN)
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

-- Runner
--
-- <leader>rr: Run the project.
-- For CMake projects, select an executable target using cmake_targets.sh.
-- For Python files, run from the uv project root if there is one,
-- otherwise run the file itself with the filetype command.
-- For Makefile projects, run `make run` from the Makefile's directory.
-- For other projects, let Code Runner use root_markers.
--
-- <leader>rf: Run the current file using its filetype command.
-- This intentionally bypasses project-level detection.

map("n", "<leader>rr", function()
	-- CMake projects: discover executable targets and run the selected one.
	if run_cmake_project() then
		return
	end

	-- Python: uv project -> run from the project root; otherwise run the file
	-- itself with the filetype command.
	if vim.bo.filetype == "python" then
		local uv_marker = find_upward({ "uv.lock", "pyproject.toml" })

		if uv_marker then
			local root = vim.fs.dirname(uv_marker)
			local file = vim.fn.expand("%:p")

			require("code_runner").run_from_fn(
				("cd %s && uv run -- python -u %s"):format(vim.fn.shellescape(root), vim.fn.shellescape(file))
			)
		else
			vim.cmd("RunFile")
		end
		return
	end

	-- Makefile projects: `make run` from the Makefile's directory.
	if find_upward({ "GNUmakefile", "Makefile", "makefile" }) then
		run_make_target("run")
		return
	end

	-- Everything else: Code Runner's root_markers.
	vim.cmd("RunProject")
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

-- Consolidate project actions under <leader>r instead of a separate <leader>m group.
-- <leader>rr already runs `make run` for Makefile projects, so no separate
-- mapping is needed for the old <leader>mr action.
require("which-key").add({
	{ "<leader>r", group = "Run / Project" },
})

map("n", "<leader>rt", function()
	-- In CMake projects, choose and run an executable target.
	if run_cmake_project() then
		return
	end

	-- In Make projects, select a Make target and execute it.
	if find_upward({ "GNUmakefile", "Makefile", "makefile" }) then
		select_make_target()
		return
	end

	vim.notify("No CMakeLists.txt or Makefile found in this directory or its parents", vim.log.levels.WARN)
end, {
	desc = "Run: Select project target",
	silent = true,
})

map("n", "<leader>rc", clean_project, {
	desc = "Run: Clean project",
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
