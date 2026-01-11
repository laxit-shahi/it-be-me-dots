-- Lazy allows you to automatically merge all plugins under a specific dir

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  -- Lazy runs require("nameofplugin").setup() automatically; this allows you keep plugins and their setup seperate
  -- this functiona allows you to write any setup that you may need for a specific plugin
  config = function()
    -- No need to call setup because of lazy?
    vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal right<CR>')
    require('neo-tree').setup {
      auto_open = false,
      window = {
        position = 'right',
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
        },
      },
    }
  end,
}
