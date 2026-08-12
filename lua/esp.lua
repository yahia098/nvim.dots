require("esp32")
vim.lsp.config("clangd", require("esp32").lsp_config())
vim.lsp.enable("clangd")
