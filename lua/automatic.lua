vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name

		if name ~= "telescope-fzf-native.nvim" then
			return
		end

		local path = ev.data.path

		local commands = {
			{
				"cmake",
				"-S.",
				"-Bbuild",
				"-DCMAKE_BUILD_TYPE=Release",
			},
			{
				"cmake",
				"--build",
				"build",
				"--config",
				"Release",
				"--target",
				"install",
			},
		}

		for _, command in ipairs(commands) do
			local result = vim.system(command, {
				cwd = path,
				text = true,
			}):wait()

			if result.code ~= 0 then
				local output = result.stderr or ""

				if output == "" then
					output = result.stdout or ""
				end

				vim.notify("telescope-fzf-native build failed:\n" .. output, vim.log.levels.ERROR)

				return
			end
		end

		vim.notify("telescope-fzf-native built successfully", vim.log.levels.INFO)
	end,
})
