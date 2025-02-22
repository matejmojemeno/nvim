return {
	{
		"n-crespo/nvim-markdown",
		lazy = true,
		ft = "markdown",
		config = function()
			vim.g.vim_markdown_toc_autofit = 1
			vim.keymap.set(
				"n",
				"<leader>m",
				"<cmd>setlocal syn=markdown<cr>",
				{ silent = false, desc = "Conceal Math", buffer = true }
			)
		end,
		init = function()
			vim.api.nvim_create_autocmd({ "FileType", "BufReadPost" }, {
				pattern = { "*.md" },
				callback = function()
					vim.cmd([[
        setlocal syn=markdown
        ]])
				end,
			})
		end,
	},

	-- {
	-- 	"jbyuki/nabla.nvim",
	-- 	keys = {
	-- 		{ "<leader>ee", ':lua require"nabla".toggle_virt()<cr>' },
	-- 		{ "<leader>eh", ':lua require"nabla",popup()<cr>' },
	-- 	},
	-- },

	{ "ixru/nvim-markdown" },

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
}
