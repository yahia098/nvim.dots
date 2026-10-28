local lint = require("lint")

lint.linters_by_ft = {
	-- C / C++
	c = { "cppcheck" },
	cpp = { "cppcheck" },

	-- Shell
	sh = { "shellcheck" },
	bash = { "shellcheck" },

	-- Python
	python = { "ruff" },

	-- Lua
	lua = { "selene" },

	-- Rust
	rust = { "clippy" },
}

local group = vim.api.nvim_create_augroup("UserLinting", {
	clear = true,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	callback = function()
		-- Skip linters whose program isn't installed instead
		-- of erroring on every save.
		local ok, names = pcall(lint._resolve_linter_by_ft, vim.bo.filetype)
		if not ok then
			return lint.try_lint()
		end
		local available = vim.tbl_filter(function(name)
			local linter = lint.linters[name]
			if type(linter) == "function" then
				linter = linter()
			end
			local cmd = linter and linter.cmd
			if type(cmd) == "function" then
				cmd = cmd()
			end
			return cmd == nil or vim.fn.executable(cmd) == 1
		end, names)
		if #available > 0 then
			lint.try_lint(available)
		end
	end,
})
