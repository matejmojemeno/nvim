return {
	"folke/zen-mode.nvim",
	opts = {
		window = {
			width = 0.8,

			options = {
				number = false,
				relativenumber = false,
				signcolumn = "no",
			},
		},
		plugins = {
			options = {
				enabled = true,
				ruler = true,
				showcmd = true,
			},
			gitsigns = { enabled = false },
			wezterm = { enabled = true, font = "+5" },
			kitty = { enabled = true, font = "+5" },
			twilight = { enabled = true },
		},
	},
}
