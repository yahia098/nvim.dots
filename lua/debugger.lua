local dap = require("dap")
local dapui = require("dapui")
-- UI configuration
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end
-- GDB's built-in Debug Adapter Protocol interface
dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap" },
}
-- Configuration for launching a C/C++ program
local cpp_launch = {
    name = "Launch with GDB",
    type = "gdb",
    request = "launch",
    program = function()
        return vim.fn.input(
            "Executable: ",
            vim.fn.getcwd() .. "/",
            "file"
        )
    end,
    cwd = vim.fn.getcwd(),
    args = {},
    stopAtBeginningOfMainSubprogram = true,
}
dap.configurations.c = { cpp_launch }
dap.configurations.cpp = { cpp_launch }
