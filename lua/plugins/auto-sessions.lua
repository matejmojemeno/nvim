return {
	"rmagatti/auto-session",
	lazy = false,
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		-- Will use Telescope if installed or a vim.ui.select picker otherwise
		{ "<leader>wr", "<cmd>SessionSearch<CR>", desc = "Session search" },
		{ "<leader>ws", "<cmd>SessionSave<CR>", desc = "Save session" },
		{ "<leader>wa", "<cmd>SessionToggleAutoSave<CR>", desc = "Toggle autosave" },
	},
	config = function()
		require("auto-session").setup({
			-- Save the current session and restore the target directory's one
			-- on every `:cd`. Pairs with <leader>gw (plugins/worktree.lua):
			-- switching checkouts then swaps the whole buffer/window set too,
			-- instead of leaving buffers pointing into the tree you just left.
			cwd_change_handling = true,

			-- A tab whose cwd was deleted (e.g. an :MR worktree removed from a
			-- shell) saves as `tcd <missing dir>`, which aborts the restore.
			pre_save_cmds = {
				function()
					for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
						local nr = vim.api.nvim_tabpage_get_number(tab)
						if #vim.api.nvim_list_tabpages() > 1 and not vim.uv.fs_stat(vim.fn.getcwd(-1, nr)) then
							vim.cmd.tabclose(nr)
						end
					end
				end,
			},

			-- ⚠️ This will only work if Telescope.nvim is installed
			-- The following are already the default values, no need to provide them if these are already the settings you want.
			session_lens = {
				-- If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
				load_on_setup = true,
				theme_conf = { border = true },
				previewer = false,
			},
		})
	end,
}
