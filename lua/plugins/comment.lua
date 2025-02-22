return {
	"numToStr/Comment.nvim",
	opts = {
		-- add any options here
	},
	lazy = false,

	config = function()
		require("Comment").setup()

		-- vim.keymap.set("n", "<C-/>", function() require('Comment.api').toggle.linewise.current() end, { noremap = true, silent = true })
		-- vim.keymap.set("v", "<C-/>", function() require('Comment.api').toggle.linewise.current() end, { noremap = true, silent = true })
	end,
}
