local oil = require("oil")
oil.setup({
    default_file_explorer = true,
    delete_to_trash = true,

    view_options = {
        show_hidden = true,
    },

    keymaps = {
        ["<leader>."] = "actions.toggle_hidden",
    },
})
