return {
	{
		"lukas-reineke/headlines.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = true, -- or `opts = {}`
	},
	{
		"jmbuhr/otter.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
	},

	{
		"HakonHarnes/img-clip.nvim",
		event = "VeryLazy",
		opts = {
			default = {
				use_absolute_path = false,
				relative_to_current_file = true,
				dir_path = function()
					return vim.fn.expand("%:t:r") .. "-img"
				end,
				prompt_for_file_name = false,
				file_name = "%Y-%m-%d-at-%H-%M-%S",
			},
		},
		filetypes = {
			markdown = {
				url_encode_path = true, ---@type boolean
				template = "![Image]($FILE_PATH)", ---@type string
			},
		},
		keys = {
			{ "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
		},
	},
	{
		"toppair/peek.nvim",
		event = { "VeryLazy" },
		build = "deno task --quiet build:fast",
		config = function()
			require("peek").setup()
			vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
			vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
		end,
	},
	{
		"sotte/presenting.nvim",
		opts = {
			width = 120,
		},
		cmd = { "Presenting" },
	},
}
