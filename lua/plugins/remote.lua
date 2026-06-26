return {
	"amitds1997/remote-nvim.nvim",
	version = "*", -- Pin to GitHub releases
	dependencies = {
		"nvim-lua/plenary.nvim", -- For standard functions
		"MunifTanjim/nui.nvim", -- To build the plugin UI
		"nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
	},

	config = function()
		require("remote-nvim").setup({
			-- Only use the Docker provider
			providers = { "docker" },

			-- Disable any DevPod functionality
			devpod = {
				enabled = false,
			},

			-- Remote copying settings
			remote = {
				copy_dirs = {
					config = {
						base = vim.fn.stdpath("config"),
						dirs = "*",
					},
					-- Add other dirs if needed (e.g., plugins)
				},
			},

			-- Optional: force the Docker binary path if colima’s docker is not on $PATH
			provider_config = {
				docker = {
					binary = "docker", -- change if your docker command is different
					connection_type = "container",
				},
			},
		})
	end,
}
