-- Highlight text that is yanked
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highligh-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
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

-- -- Set keymap only for markdown files
-- vim.api.nvim_create_autocmd("FileType", {
-- 	desc = "Set keymap for markdown files",
-- 	group = vim.api.nvim_create_augroup("keymap-markdown", { clear = true }),
-- 	pattern = { "markdown", "tex" },
-- 	callback = function()
-- 		vim.api.nvim_buf_set_keymap(
-- 			0,
-- 			"i",
-- 			"<Esc>",
-- 			"<Esc>: lua require('nabla').toggle_virt()<CR>: lua require('nabla').toggle_virt()<CR>",
-- 			{ noremap = true, silent = true, expr = false }
-- 		)
-- 	end,
-- })

-- vim.api.nvim_create_autocmd("FileType", {
-- 	desc = "Set wrap and number of columns for markdown files",
-- 	group = vim.api.nvim_create_augroup("wrap-markdown", { clear = true }),
-- 	pattern = { "markdown", "tex" },
-- 	callback = function()
-- 		vim.opt_local.wrap = true
-- 		vim.opt.colums = 86
-- 	end,
-- })
--
--

-- vim.api.nvim_create_augroup("TermOpen", {
-- 	desc = "Set keymap for small terminal",
-- 	group = vim.api.nvim_create_augroup("custom-termopen", { clear = true }),
-- 	callbac = function()
-- 		vim.opt.number = false
-- 		vim.opt.relativenumber = false
-- 	end,
-- })

vim.keymap.set("n", "<leader>st", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 5)
end)
