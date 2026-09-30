-- nvim-treesitter's `main` branch had a breaking rewrite (2024/2025): the old
-- `require("nvim-treesitter.configs").setup({ ensure_installed = ..., highlight
-- = { enable = true }, ... })` API is gone. Parser install and feature
-- enablement (highlighting/indent) are now separate, explicit steps — see
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md
local PARSERS = { "bash", "c", "cpp", "python", "lua", "json" }

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",

	config = function()
		require("nvim-treesitter").setup()
		require("nvim-treesitter").install(PARSERS)

		-- Highlighting: enabled per-buffer via vim.treesitter.start(), not a
		-- config table anymore. Skip latex, matching the old `disable` list.
		-- `bash`/`c`/etc. are *parser* names, not filetype names (e.g. sh,
		-- bash and zsh files all use the `bash` parser), so rather than
		-- matching a filetype list, just try to start treesitter for every
		-- buffer and let it silently no-op where no parser is installed.
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local ft = vim.bo[args.buf].filetype
				if ft == "latex" then
					return
				end
				-- Only start if a parser is actually installed for this filetype;
				-- vim.treesitter.start() errors otherwise.
				local ok = pcall(vim.treesitter.start, args.buf)
				if not ok then
					return
				end

				-- Old config also kept vim regex highlighting active alongside
				-- treesitter for latex/markdown; latex is skipped above, so this
				-- only still applies to markdown.
				if ft == "markdown" then
					vim.bo[args.buf].syntax = "on"
				end

				-- Indentation (still provided by this plugin, marked
				-- experimental upstream). Only wire it up where treesitter
				-- highlighting actually started.
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
