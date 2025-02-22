return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",

	config = function()
		require("nvim-treesitter.configs").setup({
			auto_install = true,
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"python",
				"lua",
				"json",
			},
			autopairs = { enable = true },
			sync_install = true,
			indent = { enable = true },
			highlight = { enable = true },
			disable = { "latex" },
			additional_vim_regex_highlighting = { "latex", "markdown" },
		})
	end,
}
