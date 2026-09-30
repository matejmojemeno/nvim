# Neovim config

A kickstart-derived config on the native **Neovim 0.11+** LSP API. Plugins are
managed by [lazy.nvim] and pinned in `lazy-lock.json`, so a fresh machine
reproduces the exact same versions.

## Requirements (must have)

| Dependency | Why | Notes |
|---|---|---|
| **Neovim ≥ 0.11** | Config uses the native `vim.lsp.config`/`vim.lsp.enable` API | Won't work on 0.10 or older |
| **git** | lazy.nvim clones every plugin | |
| **A C compiler** (`gcc`/`clang`) | nvim-treesitter compiles parsers on install | Xcode CLT on macOS covers this |
| **`make`** | Builds `telescope-fzf-native` | Guarded — Telescope still works without it, just slower sorting |
| **ripgrep** (`rg`) | Telescope live-grep / grep-word | Grep pickers are dead without it |
| **Node.js** | mason installs `pyright` (a Node app); the `claude` CLI is Node-based | |
| **A Nerd Font** | Powerline separators + icons in lualine, devicons, diagnostics | Terminal must be set to a Nerd Font, e.g. via kitty/Ghostty config |

On the **first launch**, mason auto-installs the language servers/formatters
(`pyright`, `ruff`, `lua_ls`, `clangd`, `black`) — needs network; let it finish
before judging LSP behaviour. Run `:checkhealth` if anything looks off.

## Fresh-machine setup checklist

1. Clone into `~/.config/nvim`, then launch `nvim` once and let lazy.nvim +
   mason finish installing (watch `:Lazy` and `:Mason`).
2. **Create the Obsidian vault dir:** `mkdir -p ~/Personal/notes`
   — otherwise opening any markdown file errors (obsidian.nvim hard-fails on a
   missing vault path).
3. Install the **`claude` CLI** if you want the Claude Code integration
   (`<leader>a…` keymaps → `claudecode.nvim`).

## Optional / feature-specific

These degrade gracefully — the config loads fine without them, you just lose the
matching feature:

| Dependency | Enables |
|---|---|
| **tmux** | `smart-splits` pane navigation across Neovim ↔ tmux (`<C-hjkl>`). Integration is set to `tmux` in `lua/plugins/smart-splits.lua` — switch to `"kitty"`/`"wezterm"` there if you use a different multiplexer |
| **Julia** (`~/.julia/environments/nvim-lspconfig/bin/julia`) | `julials` LSP + `julia-format`. Auto-detected; skipped if absent |
| **kitty** | Font-zoom in the typing game (`<leader>T`) and zen-mode |
| **LaTeX** (`latexmk`/`pdflatex`) | `vimtex` compilation for `.tex` files |
| **Deno** | `peek.nvim` live markdown preview |

## Layout

- `init.lua` — entry point, bootstraps lazy.nvim
- `lua/options.lua`, `lua/remap.lua`, `lua/autocmds.lua` — core settings
- `lua/plugins/*.lua` — one file per plugin (or small group)
- `after/ftplugin/*.lua` — per-filetype overrides

[lazy.nvim]: https://github.com/folke/lazy.nvim
