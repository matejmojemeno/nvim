return {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    commit = "b4da76be54691e854d3e0e02c36b0245f945c2c7",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",

            build = "make",

            cond = function()
                return vim.fn.executable("make") == 1
            end,
        },
        { "nvim-telescope/telescope-ui-select.nvim" },
        { "nvim-tree/nvim-web-devicons" },
        { "smartpde/telescope-recent-files" },
    },
    config = function()
        local actions = require("telescope.actions")

        -- Kept out of `defaults` on purpose: telescope applies
        -- file_ignore_patterns to *every* picker that yields filenames, LSP
        -- symbol pickers included, where these patterns silently swallow real
        -- source (e.g. a `storage/data/` package matches "data/"). Applied
        -- per-picker below instead of globally.
        local file_ignore_patterns = {
            ".git/",
            ".cache",
            ".idea",
            "%.o",
            "%.a",
            "%.out",
            "%.class",
            "%.pdf",
            "%.mkv",
            "%.mp4",
            "%.zip",
            ".venv/",
            "data/",
        }

        -- Patterns identifying test files/dirs across common conventions:
        -- Python (test_foo.py, foo_test.py, tests/), JS/TS (foo.test.js,
        -- foo.spec.ts, __tests__/), Lua (foo_spec.lua, spec/), Go (foo_test.go).
        local test_file_patterns = {
            "test_",
            "_test%.",
            "%.test%.",
            "_spec%.",
            "%.spec%.",
            "/tests?/",
            "/__tests__/",
            "/spec/",
        }

        -- Returns `patterns` plus the test-file patterns above, for pickers
        -- that should omit tests. Copies `patterns` so callers' tables (e.g.
        -- the shared `file_ignore_patterns` above) aren't mutated.
        local function without_tests(patterns)
            return vim.list_extend(vim.deepcopy(patterns), test_file_patterns)
        end

        -- Single regex (fd's default matching mode), combining the patterns
        -- above, used to find *only* test files/dirs for <leader>st below.
        local test_file_regex = "(test_|_test\\.|\\.test\\.|_spec\\.|\\.spec\\.|[/\\\\](tests?|__tests__|spec)[/\\\\])"

        -- Same idea as `test_file_regex`, but as an rg `--glob` (brace
        -- alternation) for <leader>sG below, since live_grep's glob_pattern
        -- goes straight to rg rather than fd.
        local test_file_glob =
            "**/{test_*,*_test.*,*.test.*,*_spec.*,*.spec.*,tests/**,test/**,__tests__/**,spec/**}"

        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,

                        -- Telescope binds both of these in the prompt: <C-u>
                        -- scrolls the preview and <C-w> is swallowed by a
                        -- window-command stub. That breaks macOS-native line
                        -- editing, since ghostty sends <C-u> for cmd+backspace
                        -- and <M-BS> (mapped to <C-w> in remap.lua) for
                        -- option+backspace. `false` disables telescope's
                        -- mapping so neovim's insert-mode defaults apply:
                        -- delete-to-line-start and delete-word-before-cursor.
                        ["<C-u>"] = false,
                        ["<C-w>"] = false,
                    },
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                    file_ignore_patterns = file_ignore_patterns,
                },
                live_grep = { file_ignore_patterns = file_ignore_patterns },
                grep_string = { file_ignore_patterns = file_ignore_patterns },
                oldfiles = { file_ignore_patterns = file_ignore_patterns },
                buffers = { file_ignore_patterns = file_ignore_patterns },
            },

            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown(),
                },
                fzf = {},
            },
        })

        -- Enable telescope extensions, if they are installed
        pcall(require("telescope").load_extension, "fzf")
        pcall(require("telescope").load_extension, "ui-select")
        pcall(require("telescope").load_extension, "recent_files")

        -- See `:help telescope.builtin`
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
        vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
        vim.keymap.set("n", "<leader>sf", function()
            builtin.find_files({ file_ignore_patterns = without_tests(file_ignore_patterns) })
        end, { desc = "[S]earch [F]iles" })
        vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
        vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
        vim.keymap.set("n", "<leader>sg", function()
            builtin.live_grep({ file_ignore_patterns = without_tests(file_ignore_patterns) })
        end, { desc = "[S]earch by [G]rep" })

        -- Grep, but only within test files/dirs — the live_grep counterpart
        -- to <leader>st below.
        vim.keymap.set("n", "<leader>sG", function()
            builtin.live_grep({
                prompt_title = "[S]earch by [G]rep (tests only)",
                glob_pattern = test_file_glob,
                file_ignore_patterns = file_ignore_patterns,
            })
        end, { desc = "[S]earch by [G]rep (tests only)" })

        -- Only test files/dirs, using fd directly since telescope's
        -- file_ignore_patterns can only exclude, not restrict to a match.
        vim.keymap.set("n", "<leader>st", function()
            builtin.find_files({
                prompt_title = "[S]earch [T]est Files",
                hidden = true,
                find_command = { "fd", "--type", "f", "--hidden", "--full-path", test_file_regex },
                file_ignore_patterns = file_ignore_patterns,
            })
        end, { desc = "[S]earch [T]est files" })
        vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
        vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
        vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })

        -- search the data/ directory ([S]earch [D]ata) — capital D to avoid
        -- clashing with <leader>sd ([S]earch [D]iagnostics) above
        vim.keymap.set("n", "<leader>sD", function()
            builtin.find_files({ cwd = "data/" })
        end, { desc = "[S]earch [D]ata" })

        -- vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
        vim.api.nvim_set_keymap(
            "n",
            "<Leader><Leader>",
            [[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
            { noremap = true, silent = true }
        )
        -- Slightly advanced example of overriding default behavior and theme
        vim.keymap.set("n", "<leader>/", function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, { desc = "[/] Fuzzily search in current buffer" })

        -- Also possible to pass additional configuration options.
        --  See `:help telescope.builtin.live_grep()` for information about particular keys
        vim.keymap.set("n", "<leader>s/", function()
            builtin.live_grep({
                grep_open_files = true,
                prompt_title = "Live Grep in Open Files",
            })
        end, { desc = "[S]earch [/] in Open Files" })

        -- Shortcut for searching your neovim configuration files
        vim.keymap.set("n", "<leader>sn", function()
            builtin.find_files({ cwd = vim.fn.stdpath("config") })
        end, { desc = "[S]earch [N]eovim files" })

        -- Like live_grep, but restricted to definitions (classes/functions/etc.)
        -- rather than every text match. Uses the attached LSP server's
        -- workspace/symbol request instead of grep, so it understands what's
        -- actually a definition instead of pattern-matching keywords.
        --
        -- Always queries pyright, whatever the current buffer is: from a
        -- non-Python file it reuses a running pyright client, or loads one
        -- Python file from the project (hidden, unlisted) and starts pyright
        -- on it so there's something to send workspace/symbol to.
        local function pyright_bufnr()
            local current = vim.lsp.get_clients({ bufnr = 0, name = "pyright" })[1]
            if current then
                return 0
            end

            local config = vim.lsp.config.pyright
            local root = vim.fs.root(vim.fn.getcwd(), config.root_markers or { ".git" }) or vim.fn.getcwd()

            -- Prefer a running client rooted at this project, else any running one.
            local clients = vim.lsp.get_clients({ name = "pyright" })
            table.sort(clients, function(a, b)
                return (a.root_dir == root) and not (b.root_dir == root)
            end)
            for _, client in ipairs(clients) do
                local buf = next(client.attached_buffers)
                if buf then
                    return buf
                end
            end

            local py = vim.fs.find(function(name)
                return name:match("%.py$") ~= nil
            end, { path = root, type = "file", limit = 1 })[1]
            if not py then
                return nil
            end

            local buf = vim.fn.bufadd(py)
            vim.fn.bufload(buf)
            local client_id = vim.lsp.start(vim.tbl_extend("force", config, { root_dir = root }), { bufnr = buf })
            if not client_id then
                return nil
            end
            -- Telescope only sees initialized clients; give pyright a moment.
            vim.wait(5000, function()
                local client = vim.lsp.get_client_by_id(client_id)
                return client ~= nil and client.initialized == true
            end, 50)
            return buf
        end

        vim.keymap.set("n", "<leader>sc", function()
            local bufnr = pyright_bufnr()
            if not bufnr then
                vim.notify("[S]earch [C]ode: couldn't find a Python project to start pyright in", vim.log.levels.WARN)
                return
            end

            builtin.lsp_dynamic_workspace_symbols({
                bufnr = bufnr,
                prompt_title = "[S]earch [C]ode (definitions)",
                file_ignore_patterns = without_tests(file_ignore_patterns),
                symbols = {
                    "class",
                    "struct",
                    "interface",
                    "enum",
                    "function",
                    "method",
                    "constructor",
                },
            })
        end, { desc = "[S]earch [C]ode (definitions)" })
    end,
}
