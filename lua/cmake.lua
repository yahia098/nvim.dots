local cmake = require("cmake-tools")

cmake.setup({
	cmake_command = "cmake",
	ctest_command = "ctest",

	cmake_use_preset = true,
	cmake_regenerate_on_save = true,

	cmake_generate_options = {
		"-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
	},

	cmake_build_directory = function()
		return "build"
	end,

	cmake_compile_commands_options = {
		action = "soft_link",
		target = function()
			return vim.fn.getcwd()
		end,
	},
})
