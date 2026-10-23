-- lua/runner.lua
--
-- Code Runner handles individual files and projects detected through
-- root markers. CMake Tools handles CMake configuration, building,
-- target selection, and launching C/C++ applications.

-- CMake Tools is configured in cmake.lua.

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
	--
	-- Don't wrap the variables in quotes: Code Runner already quotes
	-- them when it expands them, and adding your own breaks `cd`.

	filetype = {
		-- Standalone C: compile and execute beside the source file.
		c = {
			"cd $dir &&",
			"gcc -Wall -Wextra -g -O0 $fileName -o $fileNameWithoutExt &&",
			"./$fileNameWithoutExt",
		},

		-- Standalone C++: same approach, using C++17.
		cpp = {
			"cd $dir &&",
			"g++ -Wall -Wextra -g -O0 -std=c++17 $fileName -o $fileNameWithoutExt &&",
			"./$fileNameWithoutExt",
		},

		-- Basic standalone Java program.
		java = {
			"cd $dir &&",
			"javac $fileName &&",
			"java $fileNameWithoutExt",
		},

		-- Run Python through UV so project dependencies and the
		-- project's Python environment are available.
		-- -u makes Python output unbuffered.
		python = {
			"cd $dir &&",
			"uv run -- python -u $file",
		},

		-- Standalone Rust source file.
		-- Cargo projects are detected separately below.
		rust = {
			"cd $dir &&",
			"rustc -g $fileName -o $fileNameWithoutExt &&",
			"./$fileNameWithoutExt",
		},

		sh = "bash",
	},

	root_markers = {
		{ "pom.xml", "mvn compile exec:java" },
		{ "build.gradle", "./gradlew run" },

		-- Cargo manages Rust project dependencies and binaries.
		{ "Cargo.toml", "cargo run" },

		{ "go.mod", "go run ." },
		{ "package.json", "npm start" },

		-- Plain `make` runs the Makefile's default target.
		-- Use <leader>mt to select another target dynamically.
		{ "GNUmakefile", "make" },
		{ "Makefile", "make" },
		{ "makefile", "make" },
	},
})
