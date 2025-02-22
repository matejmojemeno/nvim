return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"whoissethdaniel/mason-tool-installer.nvim",
	},
	ft = {
		"lua",
		"python",
		"c",
		"cpp",
		"bash",
		"json",
		"markdown",
		"yaml",
		"toml",
		"vim",
		"julia",
		"tex",
	},
	-- add lazy loading
	lazy = true,

	config = function()
		vim.api.nvim_create_autocmd("lspattach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "lsp: " .. desc })
				end

				map("gd", require("telescope.builtin").lsp_definitions, "[g]oto [d]efinition")
				map("gr", require("telescope.builtin").lsp_references, "[g]oto [r]eferences")
				map("gi", require("telescope.builtin").lsp_implementations, "[g]oto [i]mplementation")
				map("<leader>d", require("telescope.builtin").lsp_type_definitions, "type [d]efinition")
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[d]ocument [s]ymbols")
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[w]orkspace [s]ymbols")
				map("<leader>rn", vim.lsp.buf.rename, "[r]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")
				map("K", vim.lsp.buf.hover, "hover documentation")
				map("gd", vim.lsp.buf.declaration, "[g]oto [d]eclaration")

				-- when you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.server_capabilities.documenthighlightprovider then
					vim.api.nvim_create_autocmd({ "cursorhold", "cursorholdi" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "cursormoved", "cursormovedi" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		local servers = {
			clangd = {},
			pyright = {},
			lua_ls = {},
			bashls = {},
			jsonls = {},
			marksman = {},
			julials = {},
			texlab = {},
		}

		require("mason").setup()

		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua",
			"isort",
			"black",
			-- "debugpy",
			-- "flake8",
			-- "mypy",
			-- "pylint",
			"ruff",
		})
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})

		local lspconfig = require("lspconfig")
		lspconfig.lua_ls.setup({
			settings = {
				lua = {
					diagnostics = {
						globals = { "vim", "use" },
					},
				},
			},
		})

		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		lspconfig.clangd.setup({
			capabilities = cmp_nvim_lsp.default_capabilities(),
			cmd = {
				"clangd",
				"--offset-encoding=utf-16",
			},
		})

		lspconfig.pyright.setup({
			capabilities = capabilities,
			root_dir = lspconfig.util.root_pattern(".git", ".venv"),
		})

		lspconfig.julials.setup({
			on_new_config = function(new_config, _)
				local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
				if require("lspconfig").util.path.is_file(julia) then
					new_config.cmd[1] = julia
				end
			end,
			single_file_support = true,
		})
	end,
}
