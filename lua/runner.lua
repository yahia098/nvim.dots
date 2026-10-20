-- Code runner configuration.

-- CMake projects need target selection; cmake-tools handles that part.
require("cmake-tools").setup({
	cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
	cmake_build_directory = "build",
})

require("code_runner").setup({
	mode = "float",
	float = {
		border = "rounded",
		width = 0.8,
		x = 0.5,
		y = 0.5,
	},

	filetype = {
		c = {
			'cd "$dir" &&',
			'gcc -Wall -Wextra -g -O0 "$fileName" -o "$fileNameWithoutExt" &&',
			'./"$fileNameWithoutExt"',
		},
		cpp = {
			'cd "$dir" &&',
			'g++ -Wall -Wextra -g -O0 -std=c++17 "$fileName" -o "$fileNameWithoutExt" &&',
			'./"$fileNameWithoutExt"',
		},
		java = {
			'cd "$dir" &&',
			'javac "$fileName" &&',
			'java "$fileNameWithoutExt"',
		},
		python = {
			'cd "$dir" &&',
			'uv run -- python -u "$fileName"',
		},
		rust = {
			'cd "$dir" &&',
			'rustc -g "$fileName" -o "$fileNameWithoutExt" &&',
			'./"$fileNameWithoutExt"',
		},
		sh = "bash",
	},

	-- The first matching marker in the nearest project root wins.
	root_markers = {
		{ "pom.xml", "mvn compile exec:java" },
		{ "build.gradle", "./gradlew run" },
		{ "Cargo.toml", "cargo run" },
		{ "go.mod", "go run ." },
		{ "package.json", "npm start" },
		{ "CMakeLists.txt", "cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build" },
		{ "uv.lock", 'uv run -- python -u "$file"' },
		{ "pyproject.toml", 'uv run -- python -u "$file"' },
		{ "Makefile", "make" },
		{ "GNUmakefile", "make" },
		{ "makefile", "make" },
	},
})
