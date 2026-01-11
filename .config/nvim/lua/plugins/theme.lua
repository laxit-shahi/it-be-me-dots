return {
  {
    -- Theme
    -- 'navarasu/onedark.nvim',
    -- 'catppuccin/nvim',
    -- 'rebelot/kanagawa.nvim',
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    -- You need this config to "call" and setup the theme
    config = function()
      vim.cmd.colorscheme 'gruvbox'
    end,
  },

  {
    -- Statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        -- theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
}
