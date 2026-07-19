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
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
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
