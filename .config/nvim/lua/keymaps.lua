local map = vim.keymap.set

-- [[ vim Remaps ]]
-- -- Move to window using the <ctrl> hjkl keys
map('n', '<C-l>', '<C-w>l', { desc = 'Go to right window', remap = true })
map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window', remap = true })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window', remap = true })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window', remap = true })

-- [[ Basic Keymaps ]]
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- General Remaps
map({ 'n', 'v' }, '<C-d>', '<C-d>zz', { desc = 'Ceneter after C-d', remap = true })
map({ 'n', 'v' }, '<C-u>', '<C-u>zz', { desc = 'Ceneter after C-d', remap = true })
map({ 'n', 'v' }, '<leader>cu', ':!cursor %', { desc = 'Open cursor in current buffer' })
