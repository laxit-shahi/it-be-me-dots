return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    dashboard.section.header.val = {
      [[                                                                       ]],
      [[                           /\_/\                                       ]],
      [[                          ( o.o )                                      ]],
      [[                           > ^ <                                       ]],
      [[                          /|   |\                                      ]],
      [[                         (_|   |_)                                     ]],
      [[                                                                       ]],
      [[                          serious                                      ]],
      [[                                                                       ]],
    }

    dashboard.section.buttons.val = {
      dashboard.button('f', '  Find file', '<cmd>lua Snacks.picker.files()<CR>'),
      dashboard.button('e', '  New file', ':ene <BAR> startinsert <CR>'),
      dashboard.button('r', '  Recently used files', '<cmd>lua Snacks.picker.recent()<CR>'),
      dashboard.button('t', '  Find text', '<cmd>lua Snacks.picker.grep()<CR>'),
      dashboard.button('c', '  Configuration', ':e ~/.config/nvim/init.lua <CR>'),
      dashboard.button('q', '  Quit Neovim', ':qa<CR>'),
    }

    local function footer()
      return 'Don\'t Stop Until You\'re Proud'
    end

    dashboard.section.footer.val = footer()

    dashboard.section.footer.opts.hl = 'Type'
    dashboard.section.header.opts.hl = 'Include'
    dashboard.section.buttons.opts.hl = 'Keyword'

    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)
  end,
}
