return {
	"ThePrimeagen/vim-be-good",
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	"mg979/vim-visual-multi",
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
	"folke/twilight.nvim",
	{
		"j-hui/fidget.nvim",
		opts = {
			-- options
		},
	},

	{
		"dstein64/vim-startuptime",
	},
}
