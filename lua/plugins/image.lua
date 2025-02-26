package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"

return {
	{
		"vhyrro/luarocks.nvim",
		enabled = false,
		priority = 1001,
		opts = {
			rocks = { "magick" },
		},
	},
	{
		"3rd/image.nvim",
		enabled = false,
		dependencies = { "luarocks.nvim" },
		config = function()
			require("image").setup({
				backend = "kitty",
				kitty_method = "normal",
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = true,
						only_render_image_at_cursor = false,
						--TODO: markdown extensions (ie. quarto) can go here
						filetypes = { "markdown", "vimwiki" },
					},
					neorg = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = true,
						only_render_image_at_cursor = false,
						filetypes = { "norg" },
					},
					html = {
						enabled = true,
					},
					css = {
						enabled = true,
					},
				},
				max_width = nil,
				max_height = nil,
				max_width_window_percentage = nil,

				max_height_window_percentage = 40,

				window_overlap_clear_enabled = false,
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },

				editor_only_render_when_focused = true,

				tmux_show_only_in_active_window = true,

				hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
			})
		end,
	},
}

-- return {
-- 	{
-- 		"vhyrro/luarocks.nvim",
-- 		priority = 1001, -- this plugin needs to run before anything else
-- 		opts = {
-- 			rocks = { "magick" },
-- 		},
-- 	},
-- 	{
-- 		"3rd/image.nvim",
-- 		dependencies = { "luarocks.nvim" },
-- 		opts = {},
-- 	},
-- }
