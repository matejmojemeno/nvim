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

-- Terminal conveniences (e.g. the Claude Code pane)
local term_group = vim.api.nvim_create_augroup("terminal-conveniences", { clear = true })

-- Always enter terminal mode when a terminal window is focused, so keys like
-- <Space> go straight to the program instead of waiting on the <leader> timeout.
vim.api.nvim_create_autocmd({ "TermOpen", "WinEnter", "BufEnter" }, {
	group = term_group,
	callback = function()
		if vim.bo.buftype == "terminal" then
			vim.cmd("startinsert")
		end
	end,
})

-- Let <C-hjkl> jump out of a terminal to the adjacent split straight from
-- terminal mode (no need to <Esc> first). Mirrors the normal-mode smart-splits
-- maps and stays kitty-aware.
vim.api.nvim_create_autocmd("TermOpen", {
	group = term_group,
	callback = function(args)
		local ss = require("smart-splits")
		local function jump(move)
			return function()
				vim.cmd("stopinsert")
				move()
			end
		end
		local opts = { buffer = args.buf, silent = true }
		vim.keymap.set("t", "<C-h>", jump(ss.move_cursor_left), opts)
		vim.keymap.set("t", "<C-j>", jump(ss.move_cursor_down), opts)
		vim.keymap.set("t", "<C-k>", jump(ss.move_cursor_up), opts)
		vim.keymap.set("t", "<C-l>", jump(ss.move_cursor_right), opts)
	end,
})
