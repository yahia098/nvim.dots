vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name

		if name ~= "telescope-fzf-native.nvim" then
			return
		end

		-- Don't try to build when the plugin is being deleted.
		if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
			return
		end

		local path = ev.data.path

		if vim.fn.executable("cmake") ~= 1 then
			vim.notify("telescope-fzf-native not built: cmake is not installed", vim.log.levels.WARN)
			return
		end

		local commands = {
			{
				"cmake",
				"-S.",
				"-Bbuild",
				"-DCMAKE_BUILD_TYPE=Release",
			},
			{
				"cmake",
				"--build",
				"build",
				"--config",
				"Release",
				"--target",
				"install",
			},
		}

		for _, command in ipairs(commands) do
			local result = vim.system(command, {
				cwd = path,
				text = true,
			}):wait()

			if result.code ~= 0 then
				local output = result.stderr or ""

				if output == "" then
					output = result.stdout or ""
				end

				vim.notify("telescope-fzf-native build failed:\n" .. output, vim.log.levels.ERROR)

				return
			end
		end

		vim.notify("telescope-fzf-native built successfully", vim.log.levels.INFO)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
	end,
})

-- Makefiles require real tab characters
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "make" },
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 0
	end,
})

-- Usability autocommands
local map = vim.keymap.set
local group = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

-- Flash the text you just yanked
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})

-- Reopen files at the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	callback = function(ev)
		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		local lines = vim.api.nvim_buf_line_count(ev.buf)
		if mark[1] > 0 and mark[1] <= lines and vim.bo[ev.buf].buftype == "" then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Reload files that changed on disk (e.g. after git checkout or a formatter)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = group,
	command = "checktime",
})

-- Keep splits equal when the terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = group,
	command = "tabdo wincmd =",
})

-- Create missing parent directories when saving a new file
vim.api.nvim_create_autocmd("BufWritePre", {
	group = group,
	callback = function(ev)
		if ev.match:match("^%w%w+:[\\/][\\/]") then
			return -- skip URLs such as oil:// and scp://
		end
		vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ":p:h"), "p")
	end,
})

-- Press q to close read-only helper windows
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "notify", "startuptime" },
	callback = function(ev)
		vim.bo[ev.buf].buflisted = false
		map("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true, desc = "Close window" })
	end,
})

-- Prose files: wrap lines and spell check
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Terminals: no line numbers, start in insert mode
vim.api.nvim_create_autocmd("TermOpen", {
	group = group,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.list = false
		vim.cmd.startinsert()
	end,
})
