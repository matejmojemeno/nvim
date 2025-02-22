return {
	"mfussenegger/nvim-lint",
	event = "BufWritePost",
	config = function()
		-- Define a table of linters for each filetype (not extension).
		-- Additional linters can be found here: https://github.com/mfussenegger/nvim-lint#available-linters
		require("lint").linters_by_ft = {
			python = {
				-- "flake8",
				-- "mypy",
				-- "ruff",
				-- "pylint",
			},
		}

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			pattern = { "*.py" },
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
