-- Sets leader to Space
vim.g.mapleader = ' '

-- Disable the space key's default behavior in normal and visual modes
vim.keymap.set({'n', 'v'}, '<Space>', '<Nop>', {silent = true})

-- Shared options for keymaps
local opts = { noremap = true, silent = true }

-- Remap 'jj' in insert mode to escape
vim.keymap.set('i', 'jj', '<Esc>', opts)

-- Save file with Ctrl + S
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', opts)

-- Delete single character without copying it into register (keeps yanked text intact)
vim.keymap.set('n', 'x', '"_x', opts)

-- Center search results when jumping to next/previous match
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Move selected line(s) up and reselect with visual mode
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", opts)

-- Move selected line(s) down and reselect
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", opts)

-- Scroll half a page up and center
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Scroll half a page down and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)

-- Open new line below without entering insert mode
vim.keymap.set('n', '<leader>o', 'o<Esc>', opts)

-- Clear search highlights with Esc
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', opts)

-- Toggle netria explorer
vim.keymap.set('n', '<leader>e', function()
  require("netria").toggle()
end, opts)

-- Reloads the current lua file
vim.keymap.set('n', '<leader>lf', function()
  vim.cmd("luafile %") -- Source the currently open lua file
  vim.notify("Lua file sourced ✔", vim.log.levels.INFO, { title = "Config Reloaded" })
end, opts)

-- vim.keymap.set('n', '<leader>cd', require('telescope').extensions.zoxide.list, opts)

-- local builtin = require('telescope.builtin')

-- vim.keymap.set('n', '<leader>ff', builtin.find_files, {})

-- vim.keymap.set('n', '<leader>fc', function()
  -- require('telescope.builtin').live_grep({
    -- prompt_title = '🔍 Grep Neovim Config',
  -- })
-- end, { desc = 'Search string in files' })
