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
			"cd $dir &&",
			"gcc -Wall -Wextra -g -O0 $fileName -o /tmp/$fileNameWithoutExt &&",
			"/tmp/$fileNameWithoutExt",
		},

		cpp = {
			"cd $dir &&",
			"g++ -Wall -Wextra -g -O0 $fileName -o /tmp/$fileNameWithoutExt &&",
			"/tmp/$fileNameWithoutExt",
		},

		java = {
			"cd $dir &&",
			"javac -g $fileName &&",
			"java $fileNameWithoutExt",
		},

		python = "python3 -u",
		sh = "bash",
	},
})
