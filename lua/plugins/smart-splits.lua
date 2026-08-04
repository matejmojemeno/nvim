return {
	{
		"mrjones2014/smart-splits.nvim",
		build = "./kitty/install-kittens.bash",
		-- Must not be lazy loaded: the plugin sets the '@pane-is-vim' tmux
		-- variable on load, which is what tmux's C-hjkl bindings check.
		lazy = false,
		opts = {
			multiplexer_integration = "tmux",
			at_edge = "wrap",
		},
	},
}
