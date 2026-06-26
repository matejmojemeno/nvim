-- Highlight text that is yanked
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highligh-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Use spellcheck for markdown files
vim.api.nvim_create_autocmd("FileType", {
	desc = "Enable spellcheck for markdown files",
	group = vim.api.nvim_create_augroup("spellcheck-markdown", { clear = true }),
	pattern = { "markdown", "tex" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- Open a small terminal split below
vim.keymap.set("n", "<leader>st", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 5)
end)
