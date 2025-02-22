-- Easy pane navigation
-- vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
-- vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
-- vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
-- vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

-- Turn off highlight from search
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "i", "i<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- :terminal puts you into terminal mode, double <Esc> to exit
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Insert new line in normal mode
vim.keymap.set("n", "<C-CR>", "o<Esc>", { desc = "Insert new line" })
vim.keymap.set("n", "<S-CR>", "O<Esc>", { desc = "Insert new line above" })
-- vim.keymap.set("i", "<M-Backspace>", "C-W", { desc = "Delete word before cursor" })

-- Map <leader>w to save
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- -- Pasting and deleting without overwriting the system clipboard
-- vim.keymap.set("x", "p", [["_dP]])
-- vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Navigation
-- Resizing splits
vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
-- Moving between splits
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
vim.keymap.set("n", "<C-\\>", require("smart-splits").move_cursor_previous)
-- Swapping buffers between windows
-- vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
-- vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
-- vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
-- vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right)

-- Previews for markdown math
vim.keymap.set("n", "<leader>p", function()
	require("nabla").popup({ border = "single" })
end, { noremap = true, silent = true })

-- Obsidian
-- convert note to template and remove leading white space
vim.keymap.set("n", "<leader>on", ":ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- strip date from note title and replace dashes with spaces
-- must have cursor on title
vim.keymap.set("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")

-- Source
vim.keymap.set("n", "<leader>x", ":source %<CR>", { desc = "Source current file" })
