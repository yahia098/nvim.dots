local blink = require("blink.cmp")
local autopairs = require("nvim-autopairs")
local lsp_signature = require("lsp_signature")
if not blink.library_available() then
    blink.build():pwait()
end
blink.setup({
    keymap = {
        preset = "default",
    },
    completion = {
        documentation = {
            auto_show = false,
        },
    },
    sources = {
        default = {
            "lsp",
            "path",
            "snippets",
            "buffer",
        },
    },
    fuzzy = {
        implementation = "rust",
    },
})
autopairs.setup({})
lsp_signature.setup({
    bind = true,
    floating_window = false,
    floating_window_above_cur_line = false,
    hint_enable = true,

    handler_opts = {
        border = "rounded",
    },
    toggle_key = "<M-x>",
    max_height = 12,
    max_width = 80,
})
