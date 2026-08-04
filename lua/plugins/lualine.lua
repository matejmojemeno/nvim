return {
	"nvim-lualine/lualine.nvim",
	config = function()
		-- A tidy label for terminal windows instead of the mangled `term://…`
		-- path that the `filename` component produces. Pulls the command out of
		-- the terminal buffer name (`term://<cwd>//<pid>:<cmd>`) and shows its
		-- basename, e.g. "claude" or "zsh".
		local function term_name()
			local name = vim.api.nvim_buf_get_name(0)
			local cmd = name:match(":([^:]*)$") or name -- part after the last ':'
			cmd = cmd:match("[^/]+$") or cmd -- basename only
			return " " .. (cmd ~= "" and cmd or "terminal")
		end

		-- Slim statusline for terminals (Claude Code pane, `:terminal`, …): just
		-- the mode and a clean terminal label, keeping the powerline look.
		local terminal_extension = {
			sections = {
				lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
				lualine_b = { term_name },
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
			inactive_sections = {
				lualine_a = { term_name },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			filetypes = { "snacks_terminal", "terminal" },
		}

		require("lualine").setup({
			options = {
				theme = "tokyonight",
				component_separators = "",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
				lualine_b = { { "filename", path = 1 }, "branch" },
				lualine_c = {},
				lualine_x = {},
				lualine_y = { "filetype", "progress" },
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			tabline = {},
			extensions = { terminal_extension },
		})
	end,
}
