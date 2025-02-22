return {
	"epwalsh/obsidian.nvim",
	enabled = false,
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		require("obsidian").setup({
			workspaces = {
				{
					name = "Vault",
					path = "~/Vault/repo",
				},
			},

			disable_frontmatter = true,
			templates = {
				subdir = "templates",
				date_format = "%Y-%m-%d",
				time_format = "%H:%M:%S",
			},

			mappings = {
				["gf"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
				-- toggle check-boxes
				-- ["<leader>ch"] = {
				--   action = function()
				--     return require("obsidian").util.toggle_checkbox()
				--   end,
				--   opts = { buffer = true },
				-- },
			},
			completion = {
				nvim_cmp = true,
				min_chars = 2,
			},
			ui = {
				-- Disable some things below here because I set these manually for all Markdown files using treesitter
				checkboxes = {},
				bullets = {},
			},
		})
	end,
}
