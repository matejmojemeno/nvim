local function run()
	vim.cmd("w")
	local cmd = "python " .. vim.fn.expand("%")
	vim.cmd("!" .. cmd)
end

local function closeTerminal()
	local buffers = vim.api.nvim_list_bufs()
	for _, buffer in ipairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buffer) then
			local bufname = vim.api.nvim_buf_get_name(buffer)
			if string.match(bufname, "term://") then
				vim.api.nvim_buf_delete(buffer, { force = true })
			end
		end
	end
end

local function runSplit()
	closeTerminal()
	vim.cmd("w")
	vim.cmd("vsplit | terminal python " .. vim.fn.expand("%"))
end

local function runNotif()
	vim.cmd("w")
	local cmd = "python " .. vim.fn.expand("%")
	local output = vim.fn.system(cmd)

	require("notify")(output)
end

vim.keymap.set("n", "<leader>rr", runNotif, { desc = "Run Python file" })
vim.keymap.set("n", "<leader>rs", runSplit, { desc = "Run Python file in terminal split" })
