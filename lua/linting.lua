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

vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	callback = function()
		lint.try_lint()
	end,
})

local group = vim.api.nvim_create_augroup("UserLinting", {
	clear = true,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	callback = function()
		lint.try_lint()
	end,
})
