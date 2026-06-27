return {
	"epwalsh/obsidian.nvim",
	enabled = true,
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
					name = "notes",
					path = "~/Personal/notes/",
				},
			},

			disable_frontmatter = true,

			completion = {
				min_chars = 2,
				blink_cmp = true,
			},
			ui = {
				checkboxes = {},
				bullets = {},
			},
		})
	end,
}
