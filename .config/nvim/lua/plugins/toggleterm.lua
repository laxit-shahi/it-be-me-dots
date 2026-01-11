return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    -- direction = 'bottom',
    vim.keymap.set('n', '<C-/>', ':ToggleTerm size=10<CR>'),
  },
}
