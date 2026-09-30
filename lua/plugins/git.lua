return {
    {
        "tpope/vim-fugitive",
        cmd = {
            "G", "Git", "Gedit", "Gread", "Gwrite", "Gdiff", "Gdiffsplit",
            "Gvdiffsplit", "Ghdiffsplit", "Gclog", "Gllog", "Gstatus",
            "Gblame", "Gbrowse", "GBrowse", "Gmove", "Grename", "Gdelete",
            "Gremove", "Ggrep", "Glgrep", "Gpedit", "Gsplit", "Gvsplit",
            "Gtabedit", "GDelete", "GMove", "GRename", "GRemove", "GUnlink",
        },
        ft = { "fugitive", "fugitiveblame", "git", "gitcommit", "gitrebase" },
    },
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    { "lewis6991/gitsigns.nvim", opts = {} },

    {
        "f-person/git-blame.nvim",
        -- Loaded lazily: the keymap below is what pulls it in.
        cmd = { "GitBlameToggle", "GitBlameEnable", "GitBlameCopySHA", "GitBlameOpenCommitURL" },
        keys = {
            { "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Git: toggle blame virtual text" },
        },
        opts = {
            -- Off by default; <leader>gb toggles the virtual text on/off.
            enabled = false,
            message_template = " <summary> • <date> • <author> • <<sha>>", -- template for the blame message, check the Message template section for more options
            date_format = "%m-%d-%Y %H:%M:%S", -- template for the date, check Date format section for more options
            virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
        },

    },

    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffCode", "DiffTests" },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff: working tree" },
            { "<leader>gc", "<cmd>DiffviewOpen HEAD^!<cr>", desc = "Diff: last commit" },
            { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diff: branch history" },
            { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff: file history" },
            { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diff: close" },
            -- test/non-test split; take an optional rev, e.g. :DiffCode HEAD^!
            { "<leader>gD", "<cmd>DiffCode<cr>", desc = "Diff: code only (no tests)" },
            { "<leader>gT", "<cmd>DiffTests<cr>", desc = "Diff: tests only" },
        },
        opts = {
            enhanced_diff_hl = true,
            file_panel = {
                listing_style = "tree",
                win_config = { width = 40 },
            },
            keymaps = {
                view = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
                file_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } } },
            },
        },
        config = function(_, opts)
            require("diffview").setup(opts)

            -- Anything matching these is considered a test file.
            local test_globs = {
                "**/tests/**",
                "**/test/**",
                "**/*_test.*",
                "**/test_*.*",
                "**/*_spec.*",
                "**/conftest.py",
            }

            -- ":(glob)" makes a leading "**/" mean "any depth, including none",
            -- so a top-level tests/ matches too. All-negative pathspecs mean
            -- "everything except these" to git.
            local function pathspec(include)
                local magic = include and ":(glob)" or ":(exclude,glob)"
                local parts = {}
                for _, g in ipairs(test_globs) do
                    table.insert(parts, magic .. g)
                end
                return table.concat(parts, " ")
            end

            local function open(include_tests, rev)
                local cmd = "DiffviewOpen " .. (rev or "") .. " -- " .. pathspec(include_tests)
                vim.cmd(cmd)
            end

            vim.api.nvim_create_user_command("DiffCode", function(a)
                open(false, a.args)
            end, { nargs = "?", desc = "Diffview excluding test files" })

            vim.api.nvim_create_user_command("DiffTests", function(a)
                open(true, a.args)
            end, { nargs = "?", desc = "Diffview limited to test files" })
        end,
    },

    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
        },
        cmd = "Neogit",
        keys = {
            { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit: status" },
            { "<leader>gC", "<cmd>Neogit commit<cr>", desc = "Neogit: commit" },
            { "<leader>gl", "<cmd>Telescope git_commits<cr>", desc = "Git: log (telescope)" },
            { "<leader>gL", "<cmd>Telescope git_bcommits<cr>", desc = "Git: file log (telescope)" },
            { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Neogit: push" },
        },
        opts = {
            -- "d" on a commit/file in the status buffer opens it in diffview
            integrations = { diffview = true, telescope = true },
            graph_style = "unicode",
            kind = "tab",
            commit_editor = { kind = "split" },
            -- Branches created by Claude Code worktrees have no upstream, so
            -- neogit's "Unmerged into ..." section is always empty for them and
            -- it falls back to "Recent Commits" (buffers/status/ui.lua:811).
            -- That section is folded by default; unfold it so the commits are
            -- visible at a glance. Note it lists the last N commits regardless
            -- of push state -- use :Unpushed for a true unpushed list.
            sections = { recent = { folded = false } },
            status = { recent_commit_count = 20 },
        },
    },
}
