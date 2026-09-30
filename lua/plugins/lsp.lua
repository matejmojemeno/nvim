return {
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by blink.cmp
			"saghen/blink.cmp",
		},
		config = function()
			-- Resolve the `ruff` binary to launch the LSP with: prefer the active
			-- venv/conda env, then a project-local `.venv`/`venv` under root_dir,
			-- and fall back to whatever `ruff` mason.nvim put on $PATH. Mirrors the
			-- resolver conform.nvim uses for `ruff format`/`ruff check --fix` in
			-- plugins/format.lua, so the LSP diagnostics and the on-save
			-- formatting always come from the same ruff install.
			local function ruff_lsp_bin(root_dir)
				local env_prefix = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
				if env_prefix then
					local bin = env_prefix .. "/bin/ruff"
					if vim.fn.executable(bin) == 1 then
						return bin
					end
				end
				if root_dir then
					for _, dir in ipairs({ ".venv", "venv" }) do
						local bin = root_dir .. "/" .. dir .. "/bin/ruff"
						if vim.fn.executable(bin) == 1 then
							return bin
						end
					end
				end
				return "ruff"
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", require("telescope.builtin").lsp_definitions, "[g]oto [d]efinition")

					-- Both restrict/filter LSP references by whether the file looks
					-- like a test (path contains "test"/"spec"). `on_list` (nvim
					-- 0.10+) lets us filter before display instead of the default
					-- quickfix/telescope handler.
					local function is_test_file(filename)
						local fname = (filename or ""):lower()
						return fname:find("test", 1, true) ~= nil or fname:find("spec", 1, true) ~= nil
					end

					local function references_matching(keep, empty_msg, title)
						return function()
							vim.lsp.buf.references(nil, {
								on_list = function(list)
									local items = vim.tbl_filter(function(item)
										return keep(is_test_file(item.filename))
									end, list.items)

									if #items == 0 then
										vim.notify(empty_msg, vim.log.levels.WARN)
										return
									end

									vim.fn.setqflist({}, " ", { title = title, items = items })
									require("telescope.builtin").quickfix({ prompt_title = title })
								end,
							})
						end
					end

					map("gr", references_matching(function(is_test)
						return not is_test
					end, "[g]oto [r]eferences: none found (outside tests)", "References"), "[g]oto [r]eferences")

					map(
						"gt",
						references_matching(function(is_test)
							return is_test
						end, "[g]et [t]est references: none found", "Test References"),
						"[g]et [t]est references"
					)
					map("gi", require("telescope.builtin").lsp_implementations, "[g]oto [i]mplementation")
					map("<leader>d", require("telescope.builtin").lsp_type_definitions, "type [d]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[d]ocument [s]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[w]orkspace [s]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[r]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")
					map("K", vim.lsp.buf.hover, "hover documentation")
					map("gD", vim.lsp.buf.declaration, "[g]oto [d]eclaration")
					map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
					-- Note: `<leader>f` (format) is owned by conform.nvim (see plugins/format.lua)

					local client = vim.lsp.get_client_by_id(event.data.client_id)

					-- Highlight references of the word under the cursor (if supported)
					if
						client
						and client:supports_method(
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- Toggle inlay hints, if the server supports them
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Diagnostic Config
			-- See :help vim.diagnostic.Opts
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})

			-- Apply blink.cmp's completion capabilities to every server (Neovim 0.11+).
			-- Per-server configs below merge on top of this.
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			--  Per-server overrides. These are deep-merged with the base config that
			--  nvim-lspconfig ships in its `lsp/<name>.lua` runtime files. Available keys:
			--  - cmd (table): Override the command used to start the server
			--  - filetypes (table): Override the filetypes the server attaches to
			--  - capabilities (table): Override/disable specific LSP capabilities
			--  - settings (table): Server-specific settings (e.g. lua_ls -> https://luals.github.io/wiki/settings/)
			--  - root_markers (table): Files/dirs that mark the project root
			local servers = {
				pyright = {
					-- pyright handles type-checking only; ruff lints, conform formats.
					--
					-- Marker order is priority order (highest first). `.git` leads on
					-- purpose: in a monorepo where every subdir has its own
					-- pyproject.toml, rooting at the subdir limits workspace/symbol
					-- (<leader>sc) to that one package. Rooting at the git root makes
					-- the whole repo searchable, at the cost of indexing more.
					root_markers = { ".git", "pyproject.toml", "setup.py", "setup.cfg", ".venv" },
				},

				-- ruff is the single source of Python *linting* (diagnostics + code
				-- actions). Running ruff only here (and not also via nvim-lint) is what
				-- prevents duplicate diagnostics. Formatting itself runs through
				-- conform.nvim (see plugins/format.lua), not this server.
				ruff = {
					-- Same priority order as pyright above, and the same set of files
					-- `ruff` itself would walk up to find (ruff.toml/.ruff.toml take
					-- precedence over pyproject.toml when both exist).
					root_markers = { ".git", "ruff.toml", ".ruff.toml", "pyproject.toml" },
					-- Run the project's own `ruff` (active venv/conda env, or a
					-- project-local .venv/venv), falling back to the global one on
					-- $PATH, and start it with cwd = the resolved project root so
					-- its own config discovery walks up from there. `root_dir` on
					-- `config` here is already resolved from `root_markers` above by
					-- the time this runs (see :h lsp-config-merge / :h vim.lsp.Config).
					cmd = function(dispatchers, config)
						local bin = ruff_lsp_bin(config.root_dir)
						return vim.lsp.rpc.start({ bin, "server" }, dispatchers, { cwd = config.root_dir })
					end,
					on_attach = function(client)
						-- Let pyright own hover so we don't get two hover popups.
						client.server_capabilities.hoverProvider = false
					end,
				},

				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							diagnostics = { disable = { "missing-fields" } },
						},
					},
				},

				julials = {},

				clangd = {
					capabilities = {
						offsetEncoding = { "utf-16" },
					},
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
				},
			}

			for name, config in pairs(servers) do
				vim.lsp.config(name, config)
			end

			-- Julia: prefer a precompiled julia (with a custom sysimage) if present.
			-- We read the resolved `cmd` and swap only the executable.
			local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
			if vim.fn.filereadable(julia) == 1 then
				local julials = vim.lsp.config.julials
				if julials and julials.cmd then
					local cmd = vim.deepcopy(julials.cmd)
					cmd[1] = julia
					vim.lsp.config("julials", { cmd = cmd })
				end
			end

			-- Install the servers/tools that come from Mason (julials is installed
			-- via Julia's own package manager, so it's excluded here). isort/mypy/black
			-- were dropped: ruff is the only Python formatter and linter (it handles
			-- import sorting too, when a project's config enables that rule), pyright
			-- handles type-checking.
			require("mason-tool-installer").setup({
				ensure_installed = { "pyright", "ruff", "lua_ls", "clangd" },
			})

			-- mason-lspconfig only manages installation here; we enable servers
			-- ourselves below so this works on both v1 and v2 of the plugin.
			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_enable = false,
			})

			-- Start the servers (auto-attaches on each server's filetypes).
			vim.lsp.enable(vim.tbl_keys(servers))
		end,
	},
}
