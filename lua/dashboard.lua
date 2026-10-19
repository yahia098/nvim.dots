local M = {}

local state_dir = vim.fn.stdpath("state")
local session_file = state_dir .. "/session.vim"
local W_header = [[
  ██╗   ██╗ █████╗ ██╗  ██╗██╗ █████╗   
  ╚██╗ ██╔╝██╔══██╗██║  ██║██║██╔══██╗  
   ╚████╔╝ ███████║███████║██║███████║  
    ╚██╔╝  ██╔══██║██╔══██║██║██╔══██║  
     ██║   ██║  ██║██║  ██║██║██║  ██║  
     ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝  
            Добро пожаловать            
                 Яхия                   ]]
vim.api.nvim_create_user_command("SessionSave", function()
	vim.fn.mkdir(state_dir, "p")
	vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
	vim.notify("Session saved")
end, { desc = "Save Neovim session" })

local function restore_session()
	if vim.fn.filereadable(session_file) ~= 1 then
		vim.notify("No saved session. Run :SessionSave first.", vim.log.levels.WARN)
		return
	end

	vim.cmd("source " .. vim.fn.fnameescape(session_file))
end

M.config = {
	enabled = true,
	width = 72,

	preset = {
		header = W_header,

		keys = {
			{
				icon = " ",
				key = "f",
				desc = "Find Files",
				action = ":lua Snacks.dashboard.pick('files')",
			},
			{
				icon = " ",
				key = "r",
				desc = "Recent Files",
				action = ":lua Snacks.dashboard.pick('oldfiles')",
			},
			{
				icon = " ",
				key = "p",
				desc = "Projects",
				action = ":lua Snacks.picker.projects()",
			},
			{
				icon = " ",
				key = "n",
				desc = "New File",
				action = ":ene | startinsert",
			},
			{
				icon = "󰒲 ",
				key = "s",
				desc = "Restore Session",
				action = restore_session,
			},
		},
	},

	sections = {
		{ section = "header" },
		{ section = "keys", gap = 1, padding = 1 },
		{
			title = "Recent Files",
			section = "recent_files",
			limit = 5,
			indent = 2,
			padding = 1,
		},
		{
			title = "Projects",
			section = "projects",
			limit = 5,
			indent = 2,
			padding = 1,
		},
	},
}

return M.config
