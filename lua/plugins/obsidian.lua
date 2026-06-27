return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		require("obsidian").setup({
			-- Use the unified `:Obsidian <subcommand>` interface (the old
			-- `:ObsidianTemplate` style is deprecated and removed in 4.0).
			legacy_commands = false,

			workspaces = {
				{
					name = "notes",
					path = "~/Personal/notes/",
				},
			},

			-- Fork renamed `disable_frontmatter = true` to `frontmatter.enabled`.
			frontmatter = {
				enabled = false,
			},

			completion = {
				-- The completion backend (blink.cmp / nvim-cmp) is auto-detected.
				min_chars = 2,
			},

			-- Disable obsidian's in-buffer rendering; headlines.nvim handles that.
			ui = {
				enable = false,
			},
		})
	end,
}
