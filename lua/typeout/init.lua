local M = {}

local namespace_id = vim.api.nvim_create_namespace("typeout")
local started = false
local start_time = 0
local keypresses = 0
local misses = 0
local endscreen = false

-- changes the kitty font size
-- it's a bit glitchy, but it works
function M.kitty(disable, opts)
	if not vim.fn.executable("kitty") then
		return
	end
	local cmd = "kitty @ --to %s set-font-size %s"
	local socket = vim.fn.expand("$KITTY_LISTEN_ON")
	if disable then
		vim.fn.system(cmd:format(socket, opts.font))
	else
		vim.fn.system(cmd:format(socket, "0"))
	end
	vim.cmd([[redraw]])
end

-- Utility function to clear the extmark for a single character
function M.clear_extmark(buf, line, col)
	vim.api.nvim_buf_del_extmark(buf, namespace_id, M.get_extmark_id(buf, line, col))
end

-- Function to set an extmark with highlight
function M.set_extmark(buf, line, col, hl_group)
	vim.api.nvim_buf_set_extmark(buf, namespace_id, line, col, {
		hl_group = hl_group,
		id = col + 1,
		end_col = col + 1,
	})
end

-- Generate a unique extmark ID based on position (line and column)
function M.get_extmark_id(buf, line, col)
	print(line)
	return col + 1
end

function M.read_random_word(f, line)
	f:seek("set", 0) -- Reset the file pointer to the start of the file
	local i = 1 -- line counter
	for l in f:lines() do -- lines iterator, "l" returns the line
		if i == line then
			return l
		end -- we found this line, return it
		i = i + 1 -- counting lines
	end
	return "" -- Doesn't have that line
end

function M.create_random_text(number_of_words)
	local text = ""
	local words = io.open("/Users/matej/.config/nvim/lua/typeout/words.txt", "r")
	if not words then
		print("File not found")
		return
	end

	for i = 1, 1000 do
		local line_number = math.random(1, number_of_words)
		local word = M.read_random_word(words, line_number)
		text = text .. word .. " "
	end

	return text
end

function M.handle_keypress(key)
	local buf = vim.api.nvim_get_current_buf()
	local position = vim.api.nvim_win_get_cursor(0)[2]
	local letter = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]:sub(position + 1, position + 1)

	if started == false then
		started = true
		start_time = os.time()
	end

	keypresses = keypresses + 1

	if key == letter then
		M.set_extmark(buf, 0, position, "Tag")
	else
		misses = misses + 1
		M.set_extmark(buf, 0, position, "Error")
	end

	vim.api.nvim_win_set_cursor(0, { 1, position + 1 })
end

function M.handle_backspace()
	local buf = vim.api.nvim_get_current_buf()
	local position = vim.api.nvim_win_get_cursor(0)[2]

	if position == 0 then
		return
	end

	M.set_extmark(buf, 0, position - 1, "Normal")
	vim.api.nvim_win_set_cursor(0, { 1, position - 1 })
end

function M.delete_word()
	-- NOTE: works only for words separated by one space, not for custom texts
	local buf = vim.api.nvim_get_current_buf()
	local position = vim.api.nvim_win_get_cursor(0)[2]

	if position == 0 then
		return
	end

	repeat
		M.handle_backspace()
		position = vim.api.nvim_win_get_cursor(0)[2]
		local letter = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]:sub(position, position)
	until letter == " " or position == 0
end

function M.reset()
	started = false
	start_time = 0
	keypresses = 0
	misses = 0
	endscreen = false
end

function M.set_keymaps()
	for letter = 32, 255 do
		local char = string.char(letter)
		vim.api.nvim_buf_set_keymap(0, "n", char, "", {
			noremap = true,
			nowait = true,
			callback = function()
				M.handle_keypress(char)
			end,
		})
	end

	vim.api.nvim_buf_set_keymap(0, "n", "<Space>", "", {
		noremap = true,
		nowait = true,
		callback = function()
			M.handle_keypress(" ")
		end,
	})

	vim.api.nvim_buf_set_keymap(0, "n", "<BS>", "", {
		noremap = true,
		nowait = true,
		callback = function()
			M.handle_backspace()
		end,
	})

	vim.api.nvim_buf_set_keymap(0, "n", "<C-BS>", "", {
		noremap = true,
		nowait = true,
		callback = function()
			M.delete_word()
		end,
	})

	vim.api.nvim_buf_set_keymap(0, "n", "<Esc>", "", {
		noremap = true,
		nowait = true,
		callback = function()
			if endscreen == true then
				vim.api.nvim_win_close(0, true)
				M.kitty(false, {})
				M.reset()
			else
				endscreen = true
			end

			local position = vim.api.nvim_win_get_cursor(0)[2]
			local end_time = os.time()
			local time = os.difftime(end_time, start_time) / 60
			local wpm = position / 5 / time
			local wpms = string.format("%.2f", wpm)
			local accuracy = (keypresses - misses) / keypresses * 100
			local accuracys = string.format("%.2f", accuracy)

			vim.api.nvim_buf_set_lines(0, 0, -1, false, { "WPM: " .. wpms })
			vim.api.nvim_buf_set_lines(0, 1, -1, false, { "Accuracy: " .. accuracys .. "%" })
			-- vim.api.nvim_buf_set_option(0, "modifiable", false)

			vim.defer_fn(function()
				vim.api.nvim_win_close(0, true)
				M.kitty(false, {})
				M.reset()
				-- end, 3000)
			end, 3000)
		end,
	})
end

function M.open_float()
	local ui = vim.api.nvim_list_uis()[1]
	local width = ui.width
	local height = ui.height

	local win_width = math.floor(width * 0.5)
	local win_height = math.floor(height * 0.3)

	local col = math.floor((width - win_width) / 2)
	local row = math.floor((height - win_height) / 2)

	local opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, opts)

	return buf, win
end

function M.play_game()
	M.kitty(true, { font = "+6" })

	-- sleep for a bit to make sure the font size is changed
	vim.cmd("sleep 10m")

	local buf, win = M.open_float()
	local text = M.create_random_text(1000)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "linebreak", true)

	-- -- set first line to be comment
	-- for i = 0, #text - 1 do
	-- 	M.set_extmark(buf, 0, i, "Comment")
	-- end

	M.set_keymaps()
end

-- Map the function to a key
vim.api.nvim_set_keymap("n", "<leader>t", ':lua require("typeout").play_game()<CR>', { noremap = true, silent = true })

return M
