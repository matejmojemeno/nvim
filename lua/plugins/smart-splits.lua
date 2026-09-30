return {
	{
		"mrjones2014/smart-splits.nvim",
		-- No `build` step: that installs Kitty terminal "kittens", which are
		-- unused here since multiplexer_integration is "tmux", not "kitty".
		-- Must not be lazy loaded: the plugin sets the '@pane-is-vim' tmux
		-- variable on load, which is what tmux's C-hjkl bindings check.
		lazy = false,
		opts = {
			multiplexer_integration = "tmux",
			at_edge = "wrap",
		},
	},
}
