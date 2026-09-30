-- Highlight text that is yanked
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highligh-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Set `colorcolumn` for Python buffers from the project's own configured line
-- length (never a hardcoded global), as a visual guide only: `textwidth`/
-- `formatoptions+=t` are deliberately never touched here, so nothing
-- auto-wraps as you type and fights `ruff format` (see plugins/format.lua).
do
	-- Ruff resolves `ruff.toml`/`.ruff.toml` before `pyproject.toml` when both
	-- exist, and reads `pyproject.toml`'s line-length only from `[tool.ruff]`
	-- (a `[tool.black]`/other table's `line-length` in the same file must not
	-- count). This is a light regex scrape, not a full TOML parser, but it
	-- covers the common single-line `line-length = N` form either config uses.
	local RUFF_DEFAULT_LINE_LENGTH = 88

	local function read_line_length(path, section_pattern)
		local ok, lines = pcall(vim.fn.readfile, path)
		if not ok then
			return nil
		end
		local text = table.concat(lines, "\n")
		if section_pattern then
			text = text:match(section_pattern)
			if not text then
				return nil
			end
		end
		local n = text:match("[Ll]ine%-[Ll]ength%s*=%s*(%d+)")
		return n and tonumber(n) or nil
	end

	local function project_line_length(start_path)
		local ruff_toml = vim.fs.find({ "ruff.toml", ".ruff.toml" }, { path = start_path, upward = true })[1]
		if ruff_toml then
			local n = read_line_length(ruff_toml)
			if n then
				return n
			end
		end

		local pyproject = vim.fs.find("pyproject.toml", { path = start_path, upward = true })[1]
		if pyproject then
			-- Scope to the `[tool.ruff]` table: up to the next top-level/nested
			-- `[...]` header, or end of file if `[tool.ruff]` is the last table.
			local n = read_line_length(pyproject, "%[tool%.ruff%][^\n]*\n(.-)\n%[")
				or read_line_length(pyproject, "%[tool%.ruff%][^\n]*\n(.*)$")
			if n then
				return n
			end
		end

		return RUFF_DEFAULT_LINE_LENGTH
	end

	vim.api.nvim_create_autocmd("FileType", {
		desc = "Set colorcolumn from the project's ruff line-length (visual guide only)",
		group = vim.api.nvim_create_augroup("python-ruff-colorcolumn", { clear = true }),
		pattern = "python",
		callback = function(args)
			local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf))
			local line_length = project_line_length(dirname)
			-- Mark the column just past the limit, matching how black/ruff
			-- describe "line length": the Nth column is still allowed.
			vim.opt_local.colorcolumn = tostring(line_length + 1)
		end,
	})
end

-- Use spellcheck for markdown files
vim.api.nvim_create_autocmd("FileType", {
	desc = "Enable spellcheck for markdown files",
	group = vim.api.nvim_create_augroup("spellcheck-markdown", { clear = true }),
	pattern = { "markdown", "tex" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

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
		-- Give bare `:terminal` buffers a filetype so lualine's terminal
		-- extension styles them (snacks terminals already set their own).
		if vim.bo[args.buf].filetype == "" then
			vim.bo[args.buf].filetype = "terminal"
		end

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
