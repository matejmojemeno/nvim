-- Resolve the `ruff` binary to run for formatting/linting. Prefers the
-- project's own environment (active venv, conda env, or a project-local
-- `.venv`/`venv`) so we run whatever version the project pins, falling back
-- to a bare `ruff` on $PATH (e.g. the one mason.nvim installs globally).
local function ruff_cmd(self, ctx)
	local env_prefix = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
	if env_prefix then
		local bin = env_prefix .. "/bin/ruff"
		if vim.fn.executable(bin) == 1 then
			return bin
		end
	end
	return require("conform.util").find_executable({ ".venv/bin/ruff", "venv/bin/ruff" }, "ruff")(self, ctx)
end

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			local disable_filetypes = { c = true, cpp = true }
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 500,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			-- ruff is the ONLY Python formatter/linter (see plugins/lsp.lua for
			-- why black/yapf/autopep8/isort/flake8/pylint are never wired up).
			-- `ruff_fix` runs `ruff check --fix` (lint autofixes, including
			-- import sorting if the project's ruff config enables it),
			-- `ruff_format` runs `ruff format`. Neither passes --line-length,
			-- --config, or --target-version: conform's builtin definitions
			-- pass `--stdin-filename $FILENAME`, so ruff discovers ruff.toml /
			-- pyproject.toml by walking up from the *file*, and `cwd` is set
			-- to the discovered project root (not the file's directory), so
			-- discovery also works several levels deep in a monorepo.
			python = { "ruff_fix", "ruff_format" },
			cpp = { "clang-format" },
			c = { "clang-format" },
			julia = { "julia-format" },
		},
		formatters = {
			ruff_fix = { command = ruff_cmd },
			ruff_format = { command = ruff_cmd },
		},
	},
}
