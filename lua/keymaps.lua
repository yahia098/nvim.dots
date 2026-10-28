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
		vim.notify(
			"CMake target discovery failed" .. (details ~= "" and ":\n" .. details or "."),
			vim.log.levels.ERROR
		)
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

-- Run a build-system command from the nearest project root.
local function run_project_command(root, command)
	require("code_runner").run_from_fn(("cd %s && %s"):format(vim.fn.shellescape(root), command))
end

-- Build or clean the nearest supported project using its native build tool.
local function project_action(action)
	local cmake_file = find_upward({ "CMakeLists.txt" })
	local cargo_file = find_upward({ "Cargo.toml" })
	local pom_file = find_upward({ "pom.xml" })
	local gradle_file = find_upward({ "build.gradle", "build.gradle.kts" })
	local makefile = find_upward({ "GNUmakefile", "Makefile", "makefile" })
	local root, command

	if cmake_file then
		root = vim.fs.dirname(cmake_file)
		local build_dir = vim.fs.joinpath(root, "build")
		command = action == "clean"
			and ("cmake -S %s -B %s && cmake --build %s --target clean"):format(
				vim.fn.shellescape(root), vim.fn.shellescape(build_dir), vim.fn.shellescape(build_dir)
			)
			or ("cmake -S %s -B %s && cmake --build %s"):format(
				vim.fn.shellescape(root), vim.fn.shellescape(build_dir), vim.fn.shellescape(build_dir)
			)
	elseif cargo_file then
		root = vim.fs.dirname(cargo_file)
		command = action == "clean" and "cargo clean" or "cargo build"
	elseif pom_file then
		root = vim.fs.dirname(pom_file)
		command = action == "clean" and "mvn clean" or "mvn package"
	elseif gradle_file then
		root = vim.fs.dirname(gradle_file)
		local wrapper = vim.fs.joinpath(root, "gradlew")
		local gradle = vim.fn.executable(wrapper) == 1 and "./gradlew" or "gradle"
		command = gradle .. (action == "clean" and " clean" or " build")
	elseif makefile then
		root = vim.fs.dirname(makefile)
		command = "make" .. (action == "clean" and " clean" or "")
	else
		vim.notify("No supported project build file found", vim.log.levels.WARN)
		return
	end

	run_project_command(root, command)
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

-- Project runner
-- Keep run, file, target selection, build, and clean together under <leader>r.
require("which-key").add({
	{ "<leader>r", group = "Run / Project" },
})

map("n", "<leader>rr", function()
	-- CMake: choose an executable target and build/run it.
	if run_cmake_project() then
		return
	end

	local filetype = vim.bo.filetype
	local file = vim.fn.expand("%:p")

	if filetype == "python" then
		local marker = find_upward({ "uv.lock", "pyproject.toml" })
		if marker then
			local root = vim.fs.dirname(marker)
			run_project_command(root, "uv run -- python -u " .. vim.fn.shellescape(file))
		else
			require("code_runner").run_from_fn("python -u " .. vim.fn.shellescape(file))
		end
		return
	end

	-- Cargo projects use Cargo; standalone .rs files use the rustc file command.
	if filetype == "rust" then
		local marker = find_upward({ "Cargo.toml" })
		if marker then
			run_project_command(vim.fs.dirname(marker), "cargo run")
		else
			vim.cmd("RunFile")
		end
		return
	end

	-- Maven/Gradle projects use their project runner; plain Java files use javac/java.
	if filetype == "java" then
		local pom = find_upward({ "pom.xml" })
		local gradle_file = find_upward({ "build.gradle", "build.gradle.kts" })
		if pom then
			run_project_command(vim.fs.dirname(pom), "mvn compile exec:java")
		elseif gradle_file then
			local root = vim.fs.dirname(gradle_file)
			local wrapper = vim.fs.joinpath(root, "gradlew")
			local gradle = vim.fn.executable(wrapper) == 1 and "./gradlew" or "gradle"
			run_project_command(root, gradle .. " run")
		else
			vim.cmd("RunFile")
		end
		return
	end

	-- Make projects keep their own run target; other project types use Code Runner.
	if find_upward({ "GNUmakefile", "Makefile", "makefile" }) then
		run_make_target("run")
		return
	end

	vim.cmd("RunProject")
end, {
	desc = "Run project",
	silent = true,
})

map("n", "<leader>rf", function()
	local file = vim.fn.expand("%:p")
	if vim.bo.filetype == "python" then
		local marker = find_upward({ "uv.lock", "pyproject.toml" })
		if marker then
			run_project_command(vim.fs.dirname(marker), "uv run -- python -u " .. vim.fn.shellescape(file))
		else
			require("code_runner").run_from_fn("python -u " .. vim.fn.shellescape(file))
		end
		return
	end

	vim.cmd("RunFile")
end, {
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

map("n", "<leader>rt", function()
	if run_cmake_project() then
		return
	end
	if find_upward({ "GNUmakefile", "Makefile", "makefile" }) then
		select_make_target()
		return
	end
	vim.notify("No CMakeLists.txt or Makefile found in this project", vim.log.levels.WARN)
end, {
	desc = "Run: Select target",
	silent = true,
})

map("n", "<leader>rb", function()
	project_action("build")
end, {
	desc = "Run: Build project",
	silent = true,
})

map("n", "<leader>rc", function()
	project_action("clean")
end, {
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

-- Moving around windows
map("n", "<C-h>", "<C-w>h", { desc = "Window: left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window: down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window: up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window: right" })

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Window: taller" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Window: shorter" })
map("n", "<C-Left>", "<cmd>vertical resize -3<CR>", { desc = "Window: narrower" })
map("n", "<C-Right>", "<cmd>vertical resize +3<CR>", { desc = "Window: wider" })

-- Splits
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split: vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split: horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Split: equalize" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Split: close" })

-- Saving
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save file" })
map("n", "<leader>W", "<cmd>wa<CR>", { desc = "Save all" })

-- Keep the cursor centered while scrolling and searching
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- Keep the cursor in place when joining lines
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Visual mode: keep the selection after indenting
map("x", "<", "<gv", { desc = "Indent left (keep selection)" })
map("x", ">", ">gv", { desc = "Indent right (keep selection)" })

-- Move lines / selections up and down
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("x", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("x", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Move by visual line when a line is wrapped (but keep counts like 5j exact)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down (wrap aware)" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up (wrap aware)" })

-- Clipboard behaviour:
--   * y / Y / <A-y> already go to the system clipboard (above).
--   * d, c and x never touch a register, so deleting something can't clobber
--     what you copied. Use <A-y> when you actually want to cut.
--   * p / P always paste the system clipboard (falls back to the normal
--     register where no clipboard provider exists).
local paste_reg = vim.fn.has("clipboard") == 1 and '"+' or '"'
for _, key in ipairs({ "d", "D", "c", "C", "x", "X" }) do
	map({ "n", "x" }, key, '"_' .. key, { desc = "Delete without yanking" })
end
map({ "n", "x" }, "p", paste_reg .. "p", { desc = "Paste" })
map({ "n", "x" }, "P", paste_reg .. "P", { desc = "Paste before" })

-- Select the whole file
map("n", "<leader>a", "ggVG", { desc = "Select all" })

-- Search for the selected text
map("x", "*", [[y/\V<C-r>=escape(@", '/\')<CR><CR>]], { desc = "Search selection" })

-- Replace the word under the cursor in the whole file
map("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word in file" })

-- Make a script executable
map("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { desc = "chmod +x current file", silent = true })

-- Terminal: leave terminal mode and move between windows from inside it
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: normal mode" })
map("t", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Window: left" })
map("t", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Window: down" })
map("t", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Window: up" })
map("t", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Window: right" })

-- Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic: float" })
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostic: list (buffer)" })
map("n", "<leader>dq", vim.diagnostic.setqflist, { desc = "Diagnostic: list (project)" })
map("n", "<leader>dt", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Diagnostic: toggle" })

-- Quickfix
map("n", "<leader>co", "<cmd>copen<CR>", { desc = "Quickfix: open" })
map("n", "<leader>cc", "<cmd>cclose<CR>", { desc = "Quickfix: close" })

-- Telescope extras
map("n", "<leader>fr", builtin.oldfiles, { desc = "Find recent files" })
map("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })
map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find symbols (file)" })
map("n", "<leader>fS", builtin.lsp_dynamic_workspace_symbols, { desc = "Find symbols (project)" })
map("n", "<leader>fw", builtin.grep_string, { desc = "Search word under cursor" })
map("n", "<leader>fk", builtin.keymaps, { desc = "Find keymaps" })
map("n", "<leader>fR", builtin.resume, { desc = "Resume last search" })
map("n", "<leader>fz", builtin.current_buffer_fuzzy_find, { desc = "Search in current buffer" })
map("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search in current buffer" })

-- Which-key group names for the keymaps above
require("which-key").add({
	{ "<leader>s", group = "Split / Replace" },
	{ "<leader>l", group = "LSP" },
	{ "<leader>d", group = "Diagnostics" },
	{ "<leader>c", group = "Code / Quickfix" },
})

-- ── Moving around a large codebase ─────────────────────────────────────────
local root_markers = {
	"Cargo.toml",
	"CMakeLists.txt",
	"Makefile",
	"package.json",
	"pyproject.toml",
	"go.mod",
	"pom.xml",
	"build.gradle",
	"build.gradle.kts",
	"compile_commands.json",
}

-- The repository root, else the nearest project marker, else the cwd.
local function project_root()
	return vim.fs.root(0, { ".git" }) or vim.fs.root(0, root_markers) or vim.uv.cwd()
end

local function file_dir()
	local dir = vim.fn.expand("%:p:h")
	return vim.fn.isdirectory(dir) == 1 and dir or vim.uv.cwd()
end

vim.api.nvim_create_user_command("Root", function()
	local root = project_root()
	vim.cmd.cd(vim.fn.fnameescape(root))
	vim.notify("cwd: " .. root)
end, { desc = "cd to the project root" })

map("n", "<leader>cr", "<cmd>Root<CR>", { desc = "cd to project root" })
map("n", "<leader>cd", function()
	vim.cmd.cd(vim.fn.fnameescape(file_dir()))
	vim.notify("cwd: " .. file_dir())
end, { desc = "cd to this file's directory" })

-- Search from the project root or from the current file's folder, no matter
-- where Neovim was started.
map("n", "<leader>fp", function()
	builtin.find_files({ cwd = project_root() })
end, { desc = "Find files (project root)" })
map("n", "<leader>fP", function()
	builtin.live_grep({ cwd = project_root() })
end, { desc = "Grep (project root)" })
map("n", "<leader>f.", function()
	builtin.find_files({ cwd = file_dir() })
end, { desc = "Find files (this folder)" })
map("n", "<leader>f,", function()
	builtin.live_grep({ cwd = file_dir() })
end, { desc = "Grep (this folder)" })
map("n", "<leader>fO", function()
	builtin.live_grep({ grep_open_files = true })
end, { desc = "Grep (open buffers)" })

map("n", "<leader>fj", builtin.jumplist, { desc = "Jump list" })
map("n", "<leader>fm", builtin.marks, { desc = "Marks" })
map("n", "<leader>fq", builtin.quickfix, { desc = "Quickfix list" })

-- Git pickers (built into telescope)
map("n", "<leader>gf", builtin.git_files, { desc = "Git files" })
map("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
map("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
map("n", "<leader>gC", builtin.git_bcommits, { desc = "Git commits (this file)" })
map("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })

-- Jumping between files and buffers
map("n", "<leader><leader>", "<C-^>", { desc = "Alternate file" })
map("n", "<leader><Tab>", "<C-w>w", { desc = "Next window" })
map("n", "<leader>z", "<cmd>wincmd _ | wincmd |<CR>", { desc = "Maximize window (<leader>se restores)" })
map("n", "<A-,>", "<cmd>BufferPrevious<CR>", { desc = "Previous buffer" })
map("n", "<A-.>", "<cmd>BufferNext<CR>", { desc = "Next buffer" })
map("n", "<A-<>", "<cmd>BufferMovePrevious<CR>", { desc = "Move buffer left" })
map("n", "<A->>", "<cmd>BufferMoveNext<CR>", { desc = "Move buffer right" })
map("n", "<A-c>", "<cmd>BufferClose<CR>", { desc = "Close buffer" })
map("n", "<A-p>", "<cmd>BufferPin<CR>", { desc = "Pin buffer" })
for i = 1, 9 do
	map("n", "<A-" .. i .. ">", "<cmd>BufferGoto " .. i .. "<CR>", { desc = "Go to buffer " .. i })
end
map("n", "<A-0>", "<cmd>BufferLast<CR>", { desc = "Go to last buffer" })

-- Mouse back / forward buttons walk the jump list
map("n", "<X1Mouse>", "<C-o>", { desc = "Jump back" })
map("n", "<X2Mouse>", "<C-i>", { desc = "Jump forward" })

-- Neovide: zoom, fullscreen and paste (Neovide has no terminal paste, so
-- Ctrl+Shift+V is wired to the system clipboard).
if vim.g.neovide then
	local function zoom(delta)
		vim.g.neovide_scale_factor = math.max(0.5, vim.g.neovide_scale_factor + delta)
	end
	map({ "n", "i", "x" }, "<C-=>", function()
		zoom(0.1)
	end, { desc = "Zoom in" })
	map({ "n", "i", "x" }, "<C-->", function()
		zoom(-0.1)
	end, { desc = "Zoom out" })
	map({ "n", "i", "x" }, "<C-0>", function()
		vim.g.neovide_scale_factor = 1.0
	end, { desc = "Reset zoom" })
	map("n", "<F11>", function()
		vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
	end, { desc = "Toggle fullscreen" })

	map({ "i", "c" }, "<C-S-v>", "<C-r>+", { desc = "Paste from system clipboard" })
	map("t", "<C-S-v>", [[<C-\><C-n>"+pi]], { desc = "Paste from system clipboard" })
end
