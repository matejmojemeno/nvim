return {
	"rcarriga/nvim-notify",

	config = function()
		vim.notify = require("notify")

		vim.notify.setup({
			stages = "fade_in_slide_out",

			timeout = 5000,

			opacity = 100,

			icons = {
				ERROR = "",
				WARN = "",
				INFO = "",
				DEBUG = "",
				TRACE = "✎",
			},
		})
	end,
}
