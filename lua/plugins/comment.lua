return {
	"numToStr/Comment.nvim",
	opts = {
		-- add any options here
	},
	lazy = false,

	config = function()
		require("Comment").setup({
			-- Comment.nvim's default treesitter-based commentstring lookup
			-- (Comment/ft.lua's `calculate`) crashes on shell files: the bash
			-- parser (used for both bash and zsh filetypes) can produce an
			-- injected child tree that comes back nil, and Comment.nvim
			-- doesn't guard against that (see numToStr/Comment.nvim, ft.lua:280,
			-- "attempt to index local 'tree' (a nil value)"). Skip the
			-- treesitter lookup for shell filetypes and just use Neovim's
			-- native 'commentstring' instead.
			pre_hook = function()
				local ft = vim.bo.filetype
				if ft == "sh" or ft == "bash" or ft == "zsh" then
					return vim.bo.commentstring
				end
			end,
		})

		-- vim.keymap.set("n", "<C-/>", function() require('Comment.api').toggle.linewise.current() end, { noremap = true, silent = true })
		-- vim.keymap.set("v", "<C-/>", function() require('Comment.api').toggle.linewise.current() end, { noremap = true, silent = true })
	end,
}
