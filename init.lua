vim.g.mapleader = " "

-- Lean startup: cache compiled Lua modules, and skip providers and bundled
-- plugins this config never uses.
vim.loader.enable()
for _, provider in ipairs({ "python3", "node", "ruby", "perl" }) do
	vim.g["loaded_" .. provider .. "_provider"] = 0
end
for _, builtin in ipairs({ "netrw", "netrwPlugin", "tohtml", "tutor", "zipPlugin", "tarPlugin" }) do
	vim.g["loaded_" .. builtin] = 1
end

require("options")

-- automatic.lua registers the PackChanged build hook, so it must be loaded
-- BEFORE plugins.lua downloads anything.
require("automatic")

-- Downloads happen first, before any plugin is configured.
require("plugins")

-- Everything below needs the plugins. Each module is loaded in protected mode,
-- so one failure (offline, a missing repo, a broken module) is reported
-- instead of aborting the rest of the config.
for _, module in ipairs({
	"ui",
	"explorer",
	"completion",
	"languages",
	"linting",
	"formatting",
	"runner",
	"tools",
	"keymaps",
}) do
	local ok, err = pcall(require, module)
	if not ok then
		vim.schedule(function()
			vim.notify(("Failed to load '%s':\n%s"):format(module, err), vim.log.levels.ERROR)
		end)
	end
end
