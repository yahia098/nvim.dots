local dap = require("dap")
local dapui = require("dapui")

-- Mason integration for optional debug adapters
require("mason-nvim-dap").setup({
	ensure_installed = {},
	automatic_installation = false,
})

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

-- GDB: C, C++, and Rust
dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "--interpreter=dap" },
}

-- Find the executable produced by Code Runner in /tmp
local function find_native_executable()
	local filename = vim.fn.expand("%:t:r")
	local executable = "/tmp/" .. filename

	if vim.fn.executable(executable) == 1 then
		return executable
	end

	vim.notify("Executable not found: " .. executable .. "\nCompile the current file first.", vim.log.levels.ERROR)

	return vim.fn.input("Executable path: ", vim.fn.getcwd() .. "/", "file")
end

local native_launch = {
	name = "Launch with GDB",
	type = "gdb",
	request = "launch",
	program = find_native_executable,
	cwd = function()
		return vim.fn.expand("%:p:h")
	end,
	args = {},
	stopAtBeginningOfMainSubprogram = true,
}

dap.configurations.c = { native_launch }
dap.configurations.cpp = { native_launch }
dap.configurations.rust = { native_launch }

-- Python: requires debugpy installed for python3
dap.adapters.python = {
	type = "executable",
	command = "python3",
	args = { "-m", "debugpy.adapter" },
	options = {
		source_filetype = "python",
	},
}

dap.configurations.python = {
	{
		name = "Launch Python file",
		type = "python",
		request = "launch",
		program = "${file}",
		cwd = function()
			return vim.fn.expand("%:p:h")
		end,
		pythonPath = function()
			local cwd = vim.fn.getcwd()

			if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
				return cwd .. "/.venv/bin/python"
			elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
				return cwd .. "/venv/bin/python"
			end

			return "python3"
		end,
		console = "integratedTerminal",
	},
}
