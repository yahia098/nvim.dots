-- lua/plugins.lua
-- lazy.nvim bootstrap + plugin list. Missing plugins are installed in
-- parallel at startup; everything loads eagerly so the other modules can
-- require() plugins exactly as before.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local out = vim.fn.system({
		"git", "clone", "--filter=blob:none", "--branch=stable",
		"https://github.com/folke/lazy.nvim.git", lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
		return
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ "neovim/nvim-lspconfig" },
	{ "rafamadriz/friendly-snippets" },
	{ "saghen/blink.lib" },
	{ "saghen/blink.cmp", dependencies = { "saghen/blink.lib" } },
	{ "romgrk/barbar.nvim" },
	{ "NvChad/nvim-colorizer.lua" },
	{ "mason-org/mason.nvim" },
	{ "CRAG666/code_runner.nvim" },
	{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ "daedlock/matugen.nvim" },
	{ "mason-org/mason-lspconfig.nvim" },
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release"
			.. " && cmake --build build --config Release --target install",
	},
	{ "nvim-tree/nvim-web-devicons" },
	{ "nvim-lua/plenary.nvim" },
	{ "nvim-lualine/lualine.nvim" },
	{ "folke/which-key.nvim" },
	{ "stevearc/oil.nvim" },
	{ "mfussenegger/nvim-lint" },
	{ "windwp/nvim-autopairs" },
	{ "stevearc/conform.nvim" },
	{ "lewis6991/gitsigns.nvim" },
	{ "folke/tokyonight.nvim" },
	{ "folke/snacks.nvim" },
	{ "Aietes/esp32.nvim" },
	{ "yuukiflow/Arduino-Nvim" },
	{ "mfussenegger/nvim-jdtls" },
	{ "folke/trouble.nvim" },
	{ "MagicDuck/grug-far.nvim" },
}, {
	defaults = { lazy = false },
	install = { missing = true },
	checker = { enabled = false },
	change_detection = { notify = false },
  concurrency = 4,
	rocks = { enabled = false },
	performance = {
		rtp = {
			disabled_plugins = { "netrwPlugin", "tohtml", "tutor", "zipPlugin", "tarPlugin" },
		},
	},
})
