vim.g.mapleader = " "

require("options")
require("plugins")

require("ui")
require("explorer")
require("completion")

require("languages")
require("formatting")
require("debugger")

if vim.env.IDF_PATH then
    require("esp")
end

require("runner")
require("keymaps")
