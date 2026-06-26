return {
	"mg979/vim-visual-multi",
	"folke/twilight.nvim",
	"dstein64/vim-startuptime",
	"NMAC427/guess-indent.nvim", -- Detect tabstop and shiftwidth automatically

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
}
