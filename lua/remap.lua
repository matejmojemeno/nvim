-- Turn off highlight from search
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "i", "i<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- :terminal puts you into terminal mode, double <Esc> to exit
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Insert new line in normal mode
vim.keymap.set("n", "<C-CR>", "o<Esc>", { desc = "Insert new line" })
vim.keymap.set("n", "<S-CR>", "O<Esc>", { desc = "Insert new line above" })

-- Map <leader>w to save
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- Navigation
-- Resizing splits
vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
-- Moving between splits
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
vim.keymap.set("n", "<C-\\>", require("smart-splits").move_cursor_previous)

-- Obsidian
-- convert note to template and remove leading white space
vim.keymap.set("n", "<leader>on", ":Obsidian template note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- strip date from note title and replace dashes with spaces
-- must have cursor on title
vim.keymap.set("n", "<leader>of", ":s/\\(# \\)[^_]*_/\\1/ | s/-/ /g<cr>")

-- Source
vim.keymap.set("n", "<leader>x", ":source %<CR>", { desc = "Source current file" })

vim.keymap.set("n", "<leader>ib", "f)i")

-- macOS-native text editing in insert and cmdline mode.
-- ghostty already sends the right bytes for cmd+backspace (<C-u>, which neovim
-- maps to delete-to-line-start) and cmd+left/right (Home/End, bound in
-- ~/.config/ghostty/config); option+<key> arrives as <M-...> because of
-- macos-option-as-alt = true, but neovim has no defaults for these.
--
-- remap = true so <M-BS> resolves through the <C-w> mapping below rather than
-- jumping straight to the built-in.
vim.keymap.set({ "i", "c" }, "<M-BS>", "<C-w>", { remap = true, desc = "Delete word before cursor" })
vim.keymap.set({ "i", "c" }, "<M-Left>", "<S-Left>", { desc = "Move a word left" })
vim.keymap.set({ "i", "c" }, "<M-Right>", "<S-Right>", { desc = "Move a word right" })

-- Insert-mode <C-w> is a no-op in prompt buffers (telescope's search box,
-- vim.ui.input, ...): vim refuses the delete rather than clamping it at the
-- prompt prefix. Fall back to a normal-mode `db`, which the prompt buffer does
-- clamp. Everywhere else this is neovim's own default (:h i_CTRL-W-default),
-- including the <C-g>u undo break-point.
vim.keymap.set("i", "<C-w>", function()
	return vim.bo.buftype == "prompt" and "<C-\\><C-o>db" or "<C-g>u<C-w>"
end, { expr = true, desc = "Delete word before cursor" })

-- Commits that exist on no remote-tracking ref at all. Unlike neogit's
-- "Unmerged into <upstream>" section this needs no upstream configured, so it
-- also works on the never-pushed branches Claude Code creates in worktrees.
-- Same query fugitive uses for its own "Unpushed to *" section.
vim.api.nvim_create_user_command("Unpushed", function()
	if vim.fn.systemlist("git remote")[1] == nil then
		vim.notify("No remotes configured", vim.log.levels.WARN)
		return
	end
	vim.cmd("Git log --oneline --decorate HEAD --not --remotes")
end, { desc = "Commits not present on any remote" })

-- Review a GitLab merge request in diffview.
--
--   :MR 15264   open the MR's diff
--   :MR! 15264  same, but with test files filtered out (:DiffCode)
--   :MR         pick from MRs assigned to, or awaiting review by, you
--
-- The diff uses the MR's own diff_refs (base_sha..head_sha) rather than
-- `origin/develop...`: that is exactly what GitLab's web UI renders, and it
-- stays correct when the MR is already merged or the target branch has moved.
local function gitlab_project()
	local url = vim.fn.systemlist("git remote get-url origin")[1]
	if vim.v.shell_error ~= 0 or not url or url == "" then
		return nil
	end
	local path = url:gsub("^git@[^:]+:", ""):gsub("^https?://[^/]+/", ""):gsub("%.git$", "")
	return (path:gsub("/", "%%2F"))
end

local function glab_json(endpoint)
	local out = vim.fn.system(string.format("glab api %q", endpoint))
	if vim.v.shell_error ~= 0 then
		-- glab prints the API body and its own error; keep just the message
		local ok, body = pcall(vim.json.decode, out:match("^%b{}") or "")
		return nil, ok and body.message or vim.trim(vim.split(out, "\n")[1])
	end
	local ok, decoded = pcall(vim.json.decode, out)
	return ok and decoded or nil, ok and nil or "could not parse glab output"
end

-- Where MR worktrees live. Deliberately outside the repo: worktrees nested in
-- the tree get walked by telescope/grep, and .claude/worktrees is Claude Code's.
local function mr_worktree_root()
	return vim.fs.joinpath(vim.fn.stdpath("cache"), "mr-worktrees")
end

-- diffview's `gf` opens the path on disk. Reviewing an MR from your own branch
-- therefore lands on YOUR version of the file -- silently, when the file exists
-- but differs. So check the MR head out into a throwaway detached worktree and
-- run the diff from there, where disk state matches the MR.
local function mr_worktree(iid, head_sha)
	-- Name after the main checkout, not --show-toplevel: run from inside an MR
	-- worktree, that would be `rir-123` and yield `rir-123-456`.
	local common = vim.fn.systemlist("git rev-parse --path-format=absolute --git-common-dir")[1]
	local root = vim.fs.dirname(common)
	local path = vim.fs.joinpath(mr_worktree_root(), vim.fs.basename(root) .. "-" .. iid)

	local cmd
	if vim.uv.fs_stat(path) then
		cmd = string.format("git -C %q checkout --detach %s", path, head_sha)
	else
		vim.fn.mkdir(mr_worktree_root(), "p")
		cmd = string.format("git worktree add --detach %q %s", path, head_sha)
	end

	local out = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		return nil, vim.trim(out)
	end
	return path
end

local function mr_open(iid, exclude_tests)
	local project = gitlab_project()
	if not project then
		return vim.notify("No 'origin' remote", vim.log.levels.ERROR)
	end

	local mr, err = glab_json(string.format("projects/%s/merge_requests/%s", project, iid))
	if not mr or not mr.diff_refs then
		return vim.notify(string.format("MR %s: %s", iid, err or "no diff_refs"), vim.log.levels.ERROR)
	end

	-- The MR head is not covered by the default refspec, so fetch it into
	-- refs/mr/<iid>. -f because a force-pushed MR moves the ref.
	local fetch = string.format("git fetch -f origin refs/merge-requests/%s/head:refs/mr/%s", iid, iid)
	local out = vim.fn.system(fetch)
	if vim.v.shell_error ~= 0 then
		return vim.notify("fetch failed: " .. vim.trim(out), vim.log.levels.ERROR)
	end

	local path, wt_err = mr_worktree(iid, mr.diff_refs.head_sha)
	if not path then
		return vim.notify("worktree failed: " .. wt_err, vim.log.levels.ERROR)
	end

	vim.cmd("tabnew")
	vim.cmd.tcd(vim.fn.fnameescape(path))
	vim.cmd(string.format(
		"%s %s..%s",
		exclude_tests and "DiffCode" or "DiffviewOpen",
		mr.diff_refs.base_sha,
		mr.diff_refs.head_sha
	))
	vim.notify(string.format("!%s %s", iid, mr.title or ""))
end

local function mr_pick(exclude_tests)
	local seen, items = {}, {}
	for _, role in ipairs({ "--reviewer=@me", "--assignee=@me" }) do
		local out = vim.fn.system("glab mr list " .. role .. " -F json")
		local ok, list = pcall(vim.json.decode, out)
		for _, mr in ipairs(ok and list or {}) do
			if not seen[mr.iid] then
				seen[mr.iid] = true
				table.insert(items, mr)
			end
		end
	end

	if #items == 0 then
		return vim.notify("No merge requests assigned to you", vim.log.levels.WARN)
	end

	vim.ui.select(items, {
		prompt = "merge request:",
		format_item = function(mr)
			return string.format("!%d  %s", mr.iid, mr.title)
		end,
	}, function(mr)
		if mr then
			mr_open(mr.iid, exclude_tests)
		end
	end)
end

vim.api.nvim_create_user_command("MR", function(a)
	if a.args == "" then
		mr_pick(a.bang)
	else
		mr_open(a.args, a.bang)
	end
end, { nargs = "?", bang = true, desc = "Review a GitLab merge request in diffview" })

-- Close the tabs :MR opened into `path` and wipe buffers under it. Left open,
-- auto-session saves their `tcd` and the next restore fails on the missing dir.
local function mr_forget(path)
	local function inside(p)
		return p == path or vim.startswith(p, path .. "/")
	end

	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		if inside(vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab))) then
			if #vim.api.nvim_list_tabpages() == 1 then
				vim.cmd("tabnew")
			end
			vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tab))
		end
	end

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if inside(vim.api.nvim_buf_get_name(buf)) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end

-- Remove the worktrees :MR created. Without an argument, all of them.
vim.api.nvim_create_user_command("MRClean", function(a)
	local root = mr_worktree_root()
	for name, kind in vim.fs.dir(root) do
		if kind == "directory" and (a.args == "" or name:match("%-" .. a.args .. "$")) then
			local path = vim.fs.joinpath(root, name)
			mr_forget(path)
			vim.fn.system(string.format("git worktree remove --force %q", path))
			vim.notify("removed " .. name)
		end
	end
	vim.fn.system("git worktree prune")
end, { nargs = "?", desc = "Remove worktrees created by :MR" })
