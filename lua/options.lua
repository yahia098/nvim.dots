local opt = vim.opt

-- Clipboard
opt.clipboard = ""

-- Interface
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.mouse = "a"
opt.cursorline = true

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.wrap = false

-- Searching
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Windows
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Performance
opt.updatetime = 200
opt.timeoutlen = 300

-- Prompts
opt.confirm = true

-- Persistent undo
local undo_dir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undo_dir, "p")
opt.undodir = undo_dir
opt.undofile = true

-- Usability extras
opt.inccommand = "split" -- live preview of :s substitutions
opt.breakindent = true -- wrapped lines keep their indentation
opt.linebreak = true -- when wrap is on, break at words, not mid-word
opt.showmode = false -- lualine already shows the mode
opt.pumheight = 12 -- cap the completion menu height
opt.splitkeep = "screen" -- stop text jumping when splits open/close
opt.jumpoptions = "view" -- restore scroll position on <C-o>/<C-i>
opt.smoothscroll = true
opt.undolevels = 10000
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars:append({ eob = " " }) -- hide the ~ on empty lines
opt.shortmess:append("cI") -- no completion spam / intro message
opt.virtualedit = "block" -- visual-block can go past end of line
opt.formatoptions:remove({ "o" }) -- <CR>/o on a comment doesn't continue it
opt.completeopt = { "menu", "menuone", "noselect" }

-- Rounded borders for every floating window (hover, signature, etc.).
if vim.fn.has("nvim-0.11") == 1 then
	opt.winborder = "rounded"
end

-- Use ripgrep for :grep when available.
if vim.fn.executable("rg") == 1 then
	opt.grepprg = "rg --vimgrep --smart-case --hidden"
	opt.grepformat = "%f:%l:%c:%m"
end

-- Lean: smaller shada file, and don't highlight absurdly long lines.
opt.shada = "!,'100,<50,s10,h"
opt.synmaxcol = 240

-- Folds: start fully open; LSP-based folds are enabled per buffer on attach.
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Command-line completion ignores case.
opt.wildignorecase = true

-- Neovide (GUI) settings. Neovide sets vim.g.neovide, so none of this applies
-- in a terminal.
if vim.g.neovide then
	-- A Nerd Font is needed for the icons (barbar, lualine, oil, which-key).
	opt.guifont = "JetBrainsMono Nerd Font Mono:h14"

	-- Short, subtle animations. Set any of these to 0 to turn it off.
	vim.g.neovide_scroll_animation_length = 0.15
	vim.g.neovide_cursor_animation_length = 0.06
	vim.g.neovide_cursor_trail_size = 0.3
	vim.g.neovide_position_animation_length = 0.1
	vim.g.neovide_cursor_vfx_mode = ""

	vim.g.neovide_hide_mouse_when_typing = true
	vim.g.neovide_remember_window_size = true
	vim.g.neovide_padding_top = 6
	vim.g.neovide_padding_bottom = 6
	vim.g.neovide_padding_left = 8
	vim.g.neovide_padding_right = 8
	vim.g.neovide_scale_factor = 1.0
end
