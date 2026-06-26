return {
	"lervag/vimtex",
	init = function()
		vim.g.vimtex_mappings_enabled = 1
		vim.g.vimtex_view_method = "skim" -- Skim is a popular PDF viewer for macOS
		vim.g.vimtex_quickfix_mode = 0 -- suppress error reporting on save and build
		vim.g.vimtex_indent_enabled = 0 -- Auto Indent
		vim.g.tex_flavor = "latex" -- how to read tex files (modern standard is 'latex')
	end,
}
