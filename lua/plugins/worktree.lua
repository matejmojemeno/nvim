-- Switch between git worktrees (including the `.claude/worktrees/*` ones
-- Claude Code creates) without leaving Neovim. A worktree is just another
-- checkout directory, so "switching" is a `:cd` -- the work is picking one and
-- not being left with buffers pointing into the old tree. auto-session's
-- `cwd_change_handling` (see auto-sessions.lua) handles the second half: it
-- saves the current session and restores the target directory's on every `cd`.
--
-- Attached to the telescope spec rather than its own plugin: the picker goes
-- through `vim.ui.select`, which telescope-ui-select owns.

-- Parses `git worktree list --porcelain`. Each worktree is a paragraph led by
-- a `worktree <path>` line, followed by `HEAD <sha>` and either
-- `branch refs/heads/<name>` or a bare `detached` line. Bare repos also emit a
-- `bare` line and have no working tree to cd into, so they're dropped.
local function list_worktrees()
    local out = vim.fn.systemlist({ "git", "worktree", "list", "--porcelain" })
    if vim.v.shell_error ~= 0 then
        return nil
    end

    local items, cur = {}, nil
    for _, line in ipairs(out) do
        local path = line:match("^worktree (.+)")
        if path then
            cur = { path = path }
            table.insert(items, cur)
        elseif cur then
            local branch = line:match("^branch refs/heads/(.+)")
            if branch then
                cur.branch = branch
            elseif line == "detached" then
                cur.branch = "(detached)"
            elseif line == "bare" then
                cur.bare = true
            end
        end
    end

    return vim.tbl_filter(function(w)
        return not w.bare
    end, items)
end

-- `.claude/worktrees/foo` -> `foo`; anything else -> its last path component.
-- The branch name is shown alongside, so the full path would be mostly noise.
local function short_name(path)
    return path:match("%.claude/worktrees/(.+)$") or vim.fn.fnamemodify(path, ":t")
end

local function switch_worktree()
    local items = list_worktrees()
    if not items then
        return vim.notify("Not in a git repository", vim.log.levels.WARN)
    end
    if #items < 2 then
        return vim.notify("No other worktrees", vim.log.levels.INFO)
    end

    -- Resolve both sides: cwd may reach the worktree through a symlink (on
    -- macOS /tmp and /var are symlinked), which would break a raw compare.
    local cwd = vim.fn.resolve(vim.uv.cwd() or "")
    for _, w in ipairs(items) do
        w.current = vim.fn.resolve(w.path) == cwd
    end

    vim.ui.select(items, {
        prompt = "Git worktree",
        format_item = function(w)
            return string.format(
                "%s %-28s %s",
                w.current and "*" or " ",
                short_name(w.path),
                w.branch or ""
            )
        end,
    }, function(w)
        if not w or w.current then
            return
        end
        vim.cmd("cd " .. vim.fn.fnameescape(w.path))
        vim.notify("cwd -> " .. w.path)
    end)
end

return {
    "nvim-telescope/telescope.nvim",
    keys = {
        { "<leader>gw", switch_worktree, desc = "Git: switch worktree" },
    },
}
