-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

-- Make line numbers default
vim.wo.number = true

-- Enable line numbers
vim.o.relativenumber = true

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = 'unnamedplus'

--Copy indent from current line when starting new one
vim.o.autoindent = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- The number of spaces inserted for each indentation
vim.o.shiftwidth = 2

-- Insert n spaces for a tab
vim.o.tabstop = 2

-- No of spaces that a tab counts for a while
vim.o.softtabstop = 4

-- Converts tabs to spaces
vim.o.expandtab = true

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Creates a swapfile
vim.o.swapfile = false

-- The encoding written to a file
-- vim.opt.fileencoding = 'utf-8'

-- More space in the nvim command line
vim.o.cmdheight = 1

vim.g.netrw_keepdir = 1

