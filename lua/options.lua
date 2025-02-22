-- Map leader and local leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Relative line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Mouse mode, can resize splits with mouse, "a" means that it is available in all modes
-- vim.opt.mouse = "a"

-- Don't show current mode, because it is already in lualine
vim.opt.showmode = false

-- Sync neovim and system clipboard
vim.opt.clipboard = "unnamedplus"

-- Show the sign column - the column to the left of the line numbers
vim.opt.signcolumn = "yes"

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Search options
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Tab is 4 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Neovim tries to be smart about indenting
-- NOTE: changed to see if it is better without it
vim.opt.smartindent = true

-- Lines don't split if too long
vim.opt.wrap = false

-- Don't create swap and backup files
vim.opt.swapfile = false
vim.opt.backup = false

-- Set the directory where undo files are stored
vim.opt.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"
vim.opt.undofile = true

-- Search shows matches real time as you type
vim.opt.incsearch = true

-- Enable true color support
vim.opt.termguicolors = true

-- Add @ to the list of characters that can be in a file name
vim.opt.isfname:append("@-@")

-- Set the time in milliseconds to wait for a mapped sequence to complete
vim.opt.updatetime = 50

-- Show a different colored column at 120 characters
vim.opt.colorcolumn = "80"

-- Minimum number of screen lines to keep above and below the cursor
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

-- Set the default language for spell checking
vim.opt.spelllang = "en_us"

-- Set obsidian conceal level
vim.opt.conceallevel = 2

-- ignore capitalization mistakes
vim.cmd("ca W w")
vim.cmd("ca Q q")
vim.cmd("ca WQ wq")
vim.cmd("ca Wq wq")
vim.cmd("ca wQ wq")

-- Python provider ?
vim.g.python3_host_prog = vim.fn.exepath("python3")
vim.g.loaded_python3_provider = nil

vim.opt.formatoptions:remove("o")
