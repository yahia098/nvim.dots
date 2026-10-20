-- lua/runner.lua
--
-- Code Runner handles individual files and projects detected through
-- root markers. CMake Tools handles CMake configuration, building,
-- target selection, and launching C/C++ applications.

-- CMake Tools:
-- Export compile_commands.json for clangd and other tooling.
-- Use the build/ directory for generated build files.
require("cmake-tools").setup({
	cmake_generate_options = {
		"-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
	},
	cmake_build_directory = "build",
})

require("code_runner").setup({
	-- Execute commands in a floating terminal.
	mode = "float",

	float = {
		border = "rounded",
		width = 0.8,
		x = 0.5,
		y = 0.5,
	},

	-- Commands used by :RunFile.
	--
	-- Code Runner expands these variables:
	--   $file                Absolute path to the current file.
	--   $fileName            Filename, including its extension.
	--   $fileNameWithoutExt  Filename without its extension.
	--   $dir                 Directory containing the current file.
	--
	-- The capitalization is significant.

	filetype = {
		-- Standalone C: compile and execute beside the source file.
		c = {
			'cd "$dir" &&',
			'gcc -Wall -Wextra -g -O0 "$fileName" -o "$fileNameWithoutExt" &&',
			'./"$fileNameWithoutExt"',
		},

		-- Standalone C++: same approach, using C++17.
		cpp = {
			'cd "$dir" &&',
			'g++ -Wall -Wextra -g -O0 -std=c++17 "$fileName" -o "$fileNameWithoutExt" &&',
			'./"$fileNameWithoutExt"',
		},

		-- Basic standalone Java program.
		java = {
			'cd "$dir" &&',
			'javac "$fileName" &&',
			'java "$fileNameWithoutExt"',
		},

		-- Run Python through UV so project dependencies and the
		-- project's Python environment are available.
		-- -u makes Python output unbuffered.
		python = {
			'cd "$dir" &&',
			'uv run -- python -u "$file"',
		},

		-- Standalone Rust source file.
		-- Cargo projects are detected separately below.
		rust = {
			'cd "$dir" &&',
			'rustc -g "$fileName" -o "$fileNameWithoutExt" &&',
			'./"$fileNameWithoutExt"',
		},

		sh = "bash",
	},

	-- Project auto-detection.
	--
	-- Code Runner searches upward from the current file for these
	-- markers and executes the matching command from the project root.
	--
	-- When multiple markers exist in the same root, their order can
	-- affect which command is selected. UV markers are placed before
	-- Makefile markers intentionally.
	--
	-- CMakeLists.txt is omitted: keymaps.lua routes CMake projects
	-- through CMake Tools so :CMakeRun launches the selected target.

	root_markers = {
		{ "pom.xml", "mvn compile exec:java" },
		{ "build.gradle", "./gradlew run" },

		-- Cargo manages Rust project dependencies and binaries.
		{ "Cargo.toml", "cargo run" },

		{ "go.mod", "go run ." },
		{ "package.json", "npm start" },

		-- Treat pyproject.toml projects as UV projects.
		-- $file expands to the absolute path of the current buffer.
		{ "uv.lock", 'uv run "$file"' },
		{ "pyproject.toml", 'uv run "$file"' },

		-- Plain `make` runs the Makefile's default target.
		-- Use <leader>mt to select another target dynamically.
		{ "GNUmakefile", "make" },
		{ "Makefile", "make" },
		{ "makefile", "make" },
	},
})
